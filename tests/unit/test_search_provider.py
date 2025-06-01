#!/usr/bin/env python3
"""Unit tests for Search Provider interface."""

import pytest
from unittest.mock import Mock, patch

from ops import testing
from ops.charm import CharmBase
from ops.framework import Framework

from interfaces.search_provider import SearchProvider

class DummyCharm(CharmBase):
    """A dummy charm for testing the interface."""
    def __init__(self, framework: Framework):
        super().__init__(framework)
        self.search_provider = SearchProvider(self)

@pytest.fixture
def harness():
    """Create and return a test harness."""
    harness = testing.Harness(DummyCharm)
    try:
        yield harness
    finally:
        harness.cleanup()

def test_is_ready_no_relation(harness):
    """Test is_ready when no relation exists."""
    harness.begin()
    assert not harness.charm.search_provider.is_ready()

def test_is_ready_with_relation(harness):
    """Test is_ready when relation exists."""
    harness.begin()
    harness.set_leader(True)
    relation_id = harness.add_relation("search-api", "remote-app")
    assert harness.charm.search_provider.is_ready()

def test_set_search_data(harness):
    """Test setting search data in relation."""
    harness.begin()
    harness.set_leader(True)
    relation_id = harness.add_relation("search-api", "remote-app")
    
    test_data = {"pattern": "test", "path": "/test"}
    harness.charm.search_provider.set_search_data(relation_id, test_data)
    
    relation_data = harness.get_relation_data(relation_id, harness.charm.app.name)
    assert relation_data == test_data

def test_get_search_data(harness):
    """Test getting search data from relation."""
    harness.begin()
    harness.set_leader(True)
    relation_id = harness.add_relation("search-api", "remote-app")
    
    test_data = {"pattern": "test", "path": "/test"}
    harness.update_relation_data(relation_id, harness.charm.app.name, test_data)
    
    retrieved_data = harness.charm.search_provider.get_search_data(relation_id)
    assert retrieved_data == test_data 