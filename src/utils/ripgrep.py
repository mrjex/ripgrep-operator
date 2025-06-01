#!/usr/bin/env python3
# Copyright 2025 Joel Mattsson
# See LICENSE file for licensing details.

"""Wrapper for ripgrep functionality."""

import json
import logging
import subprocess
from typing import Dict, List, Optional, Union

logger = logging.getLogger(__name__)

class RipgrepWrapper:
    """Wrapper for ripgrep search functionality."""

    def __init__(self):
        """Initialize the wrapper."""
        self._search_path = "."
        self._verify_ripgrep()

    def _verify_ripgrep(self) -> None:
        """Verify ripgrep is installed."""
        try:
            subprocess.run(["rg", "--version"], check=True, capture_output=True)
        except subprocess.CalledProcessError as e:
            logger.error("Failed to verify ripgrep installation")
            raise RuntimeError("Ripgrep not found or not working properly") from e

    def set_search_path(self, path: str) -> None:
        """Set the default search path."""
        self._search_path = path

    def search(
        self,
        pattern: str,
        path: Optional[str] = None,
        output_format: str = "text",
        context_lines: int = 2,
        case_sensitive: bool = False,
        file_pattern: Optional[str] = None,
    ) -> Union[str, Dict]:
        """Execute a ripgrep search.
        
        Args:
            pattern: The search pattern
            path: Path to search in (overrides default search path)
            output_format: Output format ('text' or 'json')
            context_lines: Number of context lines to include
            case_sensitive: Whether to use case-sensitive search
            file_pattern: Optional file pattern to filter search
            
        Returns:
            Search results as text or JSON
        """
        search_path = path or self._search_path
        
        cmd = ["rg"]
        
        # Add options
        if not case_sensitive:
            cmd.append("-i")
        
        if output_format == "json":
            cmd.append("--json")
        
        cmd.extend(["-C", str(context_lines)])  # Context lines
        
        if file_pattern:
            cmd.extend(["-g", file_pattern])
        
        # Add pattern and path
        cmd.extend([pattern, search_path])
        
        try:
            result = subprocess.run(
                cmd,
                check=True,
                capture_output=True,
                text=True
            )
            
            if output_format == "json":
                # Parse JSON lines into a list of results
                json_results = []
                for line in result.stdout.splitlines():
                    if line.strip():
                        json_results.append(json.loads(line))
                return {"results": json_results}
            
            return result.stdout
            
        except subprocess.CalledProcessError as e:
            if e.returncode == 1:  # No matches found
                return "" if output_format == "text" else {"results": []}
            logger.error(f"Search failed: {e.stderr}")
            raise RuntimeError(f"Search failed: {e.stderr}") from e
        
    def get_stats(self, path: Optional[str] = None) -> Dict[str, int]:
        """Get search statistics for a path.
        
        Returns:
            Dictionary with statistics (file count, total size, etc.)
        """
        search_path = path or self._search_path
        
        try:
            # Count files
            file_count = subprocess.run(
                ["rg", "--files", search_path],
                check=True,
                capture_output=True,
                text=True
            ).stdout.count("\n")
            
            return {
                "file_count": file_count,
                "search_path": search_path
            }
            
        except subprocess.CalledProcessError as e:
            logger.error(f"Failed to get stats: {e.stderr}")
            raise RuntimeError(f"Failed to get stats: {e.stderr}") from e 