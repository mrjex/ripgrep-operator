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


class TestCharm(unittest.TestCase):
    """Unit tests for Ripgrep operator charm."""

    def setUp(self):
        """Set up test environment."""
        self.harness = Harness(RipgrepOperatorCharm)
        self.addCleanup(self.harness.cleanup)

    def test_start(self):
        """Test the start event."""
        self.harness.begin_with_initial_hooks()
        self.assertEqual(self.harness.model.unit.status, ActiveStatus())

    def test_ripgrep_pebble_ready(self):
        """Test ripgrep pebble ready event."""
        # Initialize container
        self.harness.begin_with_initial_hooks()
        self.harness.set_can_connect("ripgrep", True)
        
        # Simulate pebble ready
        container = self.harness.model.unit.get_container("ripgrep")
        self.harness.charm._on_ripgrep_pebble_ready(ops.PebbleReadyEvent(
            handle=Mock(),
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
        self.harness.begin()
        # Add config option before testing
        self.harness.update_config({})  # Reset config
        # Trigger config changed
        self.harness.charm._on_config_changed(ops.ConfigChangedEvent(Mock()))
        self.assertEqual(
            self.harness.model.unit.status,
            BlockedStatus("search_path configuration required")
        )

    def test_config_changed_valid_path(self):
        """Test config changed with valid search path."""
        self.harness.begin()
        # Add config option before testing
        self.harness.update_config({"search_path": "/test/path"})
        # Trigger config changed
        self.harness.charm._on_config_changed(ops.ConfigChangedEvent(Mock()))
        self.assertEqual(self.harness.model.unit.status, ActiveStatus())

    @patch("charm.RipgrepWrapper")
    def test_search_pattern_action(self, mock_ripgrep):
        """Test search pattern action."""
        self.harness.begin()
        # Mock ripgrep search
        mock_instance = mock_ripgrep.return_value
        mock_instance.search.return_value = "test result"
        
        # Create mock action event
        mock_event = Mock()
        mock_event.params = {"pattern": "test", "path": "/test", "format": "text"}
        mock_event.fail = Mock()
        mock_event.set_results = Mock()
        
        # Run action
        self.harness.charm._on_search_pattern(mock_event)
        
        # Check results
        mock_event.set_results.assert_called_once_with({"result": "test result"})
        mock_event.fail.assert_not_called()
        self.assertEqual(self.harness.model.unit.status, ActiveStatus())

    @patch("charm.RipgrepWrapper")
    def test_search_pattern_action_failure(self, mock_ripgrep):
        """Test search pattern action failure."""
        self.harness.begin()
        # Mock ripgrep search failure
        mock_instance = mock_ripgrep.return_value
        mock_instance.search.side_effect = RuntimeError("test error")
        
        # Create mock action event
        mock_event = Mock()
        mock_event.params = {"pattern": "test"}
        mock_event.fail = Mock()
        mock_event.set_results = Mock()
        
        # Run action
        self.harness.charm._on_search_pattern(mock_event)
        
        # Check failure handling
        mock_event.fail.assert_called_once_with("Search failed: test error")
        mock_event.set_results.assert_not_called()
        self.assertEqual(
            self.harness.model.unit.status,
            BlockedStatus("Search failed: test error")
        )

    def test_search_relation_joined(self):
        """Test search relation joined event."""
        self.harness.begin()
        # Add relation
        relation_id = self.harness.add_relation("search-api", "remote-app")
        self.harness.add_relation_unit(relation_id, "remote-app/0")
        
        # Get the relation
        relation = self.harness.model.get_relation("search-api")
        
        # Create and trigger relation joined event
        relation_event = ops.RelationJoinedEvent(
            handle=Mock(relation_name="search-api"),
            relation=relation,
            app=relation.app,
            unit=relation.app.get_unit("remote-app/0")
        )
        self.harness.charm._on_search_relation_joined(relation_event)
        
        # Check status
        self.assertEqual(
            self.harness.model.unit.status,
            WaitingStatus("Waiting for search relation data")
        )
