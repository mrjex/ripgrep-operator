#!/usr/bin/env python3
# Copyright 2025 Joel Mattsson joel.mattsson@hotmail.se
# See LICENSE file for licensing details.
#
# Learn more about testing at: https://juju.is/docs/sdk/testing

"""Unit tests for Ripgrep operator charm."""

import unittest
from unittest.mock import Mock, patch

import ops
import ops.testing
from ops.model import ActiveStatus, BlockedStatus, MaintenanceStatus, WaitingStatus
from ops.testing import Harness

from charm import RipgrepOperatorCharm


def test_start():
    # Arrange:
    ctx = testing.Context(RipgrepOperatorCharm)
    # Act:
    state_out = ctx.run(ctx.on.start(), testing.State())
    # Assert:
    assert state_out.unit_status == testing.ActiveStatus()


class TestCharm(unittest.TestCase):
    """Unit tests for Ripgrep operator charm."""

    def setUp(self):
        """Set up test environment."""
        self.harness = Harness(RipgrepOperatorCharm)
        self.addCleanup(self.harness.cleanup)
        self.harness.begin()

    def test_ripgrep_pebble_ready(self):
        """Test ripgrep pebble ready event."""
        # Simulate pebble ready
        container = self.harness.model.unit.get_container("ripgrep")
        self.harness.charm._on_ripgrep_pebble_ready(ops.PebbleReadyEvent(
            handle=Mock(),
            relation=None,
            workload=container
        ))

        # Check the plan is valid
        plan = self.harness.get_container_pebble_plan("ripgrep")
        self.assertEqual(plan.services, {
            "ripgrep": {
                "override": "replace",
                "summary": "ripgrep service",
                "command": "sleep infinity",
                "startup": "enabled"
            }
        })

        # Check status
        self.assertEqual(self.harness.model.unit.status, ActiveStatus())

    def test_config_changed_missing_path(self):
        """Test config changed with missing search path."""
        self.harness.update_config({"search_path": ""})
        self.assertEqual(
            self.harness.model.unit.status,
            BlockedStatus("search_path configuration required")
        )

    def test_config_changed_valid_path(self):
        """Test config changed with valid search path."""
        self.harness.update_config({"search_path": "/test/path"})
        self.assertEqual(self.harness.model.unit.status, ActiveStatus())

    @patch("charm.RipgrepWrapper")
    def test_search_pattern_action(self, mock_ripgrep):
        """Test search pattern action."""
        # Mock ripgrep search
        mock_ripgrep.return_value.search.return_value = "test result"
        
        # Run action
        action_event = self.harness.get_action_event(
            "search-pattern",
            {"pattern": "test", "path": "/test", "format": "text"}
        )
        self.harness.charm._on_search_pattern(action_event)
        
        # Check results
        self.assertEqual(action_event.results, {"result": "test result"})
        self.assertEqual(self.harness.model.unit.status, ActiveStatus())

    @patch("charm.RipgrepWrapper")
    def test_search_pattern_action_failure(self, mock_ripgrep):
        """Test search pattern action failure."""
        # Mock ripgrep search failure
        mock_ripgrep.return_value.search.side_effect = RuntimeError("test error")
        
        # Run action
        action_event = self.harness.get_action_event(
            "search-pattern",
            {"pattern": "test"}
        )
        self.harness.charm._on_search_pattern(action_event)
        
        # Check status reflects failure
        self.assertEqual(
            self.harness.model.unit.status,
            BlockedStatus("Search failed: test error")
        )

    def test_search_relation_joined(self):
        """Test search relation joined event."""
        relation_id = self.harness.add_relation("search-api", "remote-app")
        self.harness.add_relation_unit(relation_id, "remote-app/0")
        
        # Check status
        self.assertEqual(
            self.harness.model.unit.status,
            WaitingStatus("Waiting for search relation data")
        )
