#!/usr/bin/env python3
"""Unit tests for Ripgrep wrapper."""

import json
import pytest
from unittest.mock import Mock, patch

from utils.ripgrep import RipgrepWrapper

@pytest.fixture
def ripgrep():
    """Create a RipgrepWrapper instance."""
    return RipgrepWrapper()

def test_set_search_path(ripgrep):
    """Test setting search path."""
    test_path = "/test/path"
    ripgrep.set_search_path(test_path)
    assert ripgrep._search_path == test_path

@patch("subprocess.run")
def test_search_text_format(mock_run, ripgrep):
    """Test search with text format."""
    mock_run.return_value = Mock(stdout="test result", returncode=0)
    
    result = ripgrep.search("pattern", "/test/path", "text")
    
    mock_run.assert_called_once()
    assert result == "test result"

@patch("subprocess.run")
def test_search_with_error(mock_run, ripgrep):
    """Test search with error."""
    mock_run.side_effect = Exception("test error")
    
    with pytest.raises(RuntimeError) as exc_info:
        ripgrep.search("pattern", "/test/path")
    
    assert "Failed to execute search" in str(exc_info.value)

@patch("subprocess.run")
def test_search_with_invalid_format(mock_run, ripgrep):
    """Test search with invalid format."""
    with pytest.raises(ValueError) as exc_info:
        ripgrep.search("pattern", "/test/path", "invalid")
    
    assert "Invalid output format" in str(exc_info.value)
    mock_run.assert_not_called()

@patch("subprocess.run")
def test_search_with_context(mock_run, ripgrep):
    """Test search with context lines."""
    mock_run.return_value = Mock(stdout="test result", returncode=0)
    
    ripgrep.search("pattern", "/test/path", context_lines=2)
    
    mock_run.assert_called_once()
    cmd_args = mock_run.call_args[0][0]
    assert "-C" in cmd_args
    assert "2" in cmd_args

@patch("subprocess.run")
def test_search_with_max_results(mock_run, ripgrep):
    """Test search with max results limit."""
    mock_run.return_value = Mock(stdout="test result", returncode=0)
    
    ripgrep.search("pattern", "/test/path", max_results=100)
    
    mock_run.assert_called_once()
    cmd_args = mock_run.call_args[0][0]
    assert "-m" in cmd_args
    assert "100" in cmd_args 