#!/usr/bin/env python3
# Copyright 2025 Joel Mattsson joel.mattsson@hotmail.se
# See LICENSE file for licensing details.
#
# Learn more about testing at: https://juju.is/docs/sdk/testing

"""Unit tests for Ripgrep operator charm."""

import pytest
from unittest.mock import Mock, patch

import ops
from ops import testing
from ops.model import ActiveStatus, BlockedStatus, MaintenanceStatus, WaitingStatus

from charm import RipgrepOperatorCharm

@pytest.fixture
def harness():
    """Create and return a test harness with RipgrepOperatorCharm."""
    harness = testing.Harness(RipgrepOperatorCharm)
    try:
        yield harness
    finally:
        harness.cleanup()

def test_config_changed_missing_path(harness):
    """Test config changed with missing search path."""
    # Initialize without hooks
    harness.begin()
    
    # Set initial state
    harness.disable_hooks()
    harness.update_config({})  # Clear any existing config
    harness.enable_hooks()
    
    # Trigger config changed explicitly
    harness.charm._on_config_changed(ops.ConfigChangedEvent(Mock()))
    
    # Verify status
    assert harness.model.unit.status == BlockedStatus("search_path configuration required")

def test_config_changed_valid_path(harness):
    """Test config changed with valid search path."""
    harness.begin()
    # Add config option before testing
    harness.update_config({"search_path": "/test/path"})
    # Trigger config changed
    harness.charm._on_config_changed(ops.ConfigChangedEvent(Mock()))
    assert harness.model.unit.status == ActiveStatus()

def test_ripgrep_pebble_ready(harness):
    """Test ripgrep pebble ready event."""
    # Initialize container
    harness.begin_with_initial_hooks()
    harness.set_can_connect("ripgrep", True)
    
    # Simulate pebble ready
    container = harness.model.unit.get_container("ripgrep")
    harness.charm._on_ripgrep_pebble_ready(ops.PebbleReadyEvent(
        handle=Mock(),
        workload=container
    ))

    # Check the plan is valid
    plan = harness.get_container_pebble_plan("ripgrep")
    assert plan.services == {
        "ripgrep": {
            "override": "replace",
            "summary": "ripgrep service",
            "command": "sleep infinity",
            "startup": "enabled"
        }
    }

    # Check status
    assert harness.model.unit.status == ActiveStatus()

@patch("charm.RipgrepWrapper")
def test_search_pattern_action(mock_ripgrep, harness):
    """Test search pattern action."""
    harness.begin()
    # Mock ripgrep search
    mock_instance = mock_ripgrep.return_value
    mock_instance.search.return_value = "test result"
    
    # Create mock action event
    mock_event = Mock()
    mock_event.params = {"pattern": "test", "path": "/test", "format": "text"}
    mock_event.fail = Mock()
    mock_event.set_results = Mock()
    
    # Run action
    harness.charm._on_search_pattern(mock_event)
    
    # Check results
    mock_event.set_results.assert_called_once_with({"result": "test result"})
    mock_event.fail.assert_not_called()
    assert harness.model.unit.status == ActiveStatus()

@patch("charm.RipgrepWrapper")
def test_search_pattern_action_failure(mock_ripgrep, harness):
    """Test search pattern action failure."""
    harness.begin()
    # Mock ripgrep search failure
    mock_instance = mock_ripgrep.return_value
    mock_instance.search.side_effect = RuntimeError("test error")
    
    # Create mock action event
    mock_event = Mock()
    mock_event.params = {"pattern": "test"}
    mock_event.fail = Mock()
    mock_event.set_results = Mock()
    
    # Run action
    harness.charm._on_search_pattern(mock_event)
    
    # Check failure handling
    mock_event.fail.assert_called_once_with("Search failed: test error")
    mock_event.set_results.assert_not_called()
    assert harness.model.unit.status == BlockedStatus("Search failed: test error")

def test_search_relation_joined(harness):
    """Test search relation joined event."""
    # Initialize without hooks
    harness.begin()
    
    # Set up relation
    harness.set_leader(True)  # Ensure we're the leader
    relation_id = harness.add_relation("search-api", "remote-app")
    remote_unit_id = "remote-app/0"
    harness.add_relation_unit(relation_id, remote_unit_id)
    
    # Get the relation and remote unit
    relation = harness.model.get_relation("search-api")
    remote_unit = harness.model.get_unit(remote_unit_id)
    
    # Create and trigger relation joined event
    relation_event = ops.RelationJoinedEvent(
        handle=Mock(relation_name="search-api"),
        relation=relation,
        app=relation.app,
        unit=remote_unit
    )
    
    # Trigger the event
    harness.charm._on_search_relation_joined(relation_event)
    
    # Check status
    assert harness.model.unit.status == WaitingStatus("Waiting for search relation data")

def test_start(harness):
    """Test the start event."""
    harness.begin_with_initial_hooks()
    assert harness.model.unit.status == ActiveStatus()
