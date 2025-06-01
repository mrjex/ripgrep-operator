#!/usr/bin/env python3
# Copyright 2025 Joel Mattsson
# See LICENSE file for licensing details.

"""Wrapper for ripgrep functionality."""

import json
import logging
import subprocess
from typing import Any, Dict, List, Optional, Union

logger = logging.getLogger(__name__)

class RipgrepWrapper:
    """Wrapper for ripgrep functionality."""

    def __init__(self):
        """Initialize ripgrep wrapper."""
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
        """Set the search path."""
        self._search_path = path

    def search(
        self,
        pattern: str,
        path: Optional[str] = None,
        output_format: str = "text",
        context_lines: Optional[int] = None,
        max_results: Optional[int] = None,
    ) -> Union[str, List[Dict[str, Any]]]:
        """Execute ripgrep search.
        
        Args:
            pattern: Search pattern
            path: Path to search in (overrides search_path if provided)
            output_format: Output format ('text' or 'json')
            context_lines: Number of context lines to include
            max_results: Maximum number of results to return
            
        Returns:
            Search results as string or JSON object
            
        Raises:
            ValueError: If output format is invalid
            RuntimeError: If search fails
        """
        if output_format not in ["text", "json"]:
            raise ValueError(f"Invalid output format: {output_format}")

        search_path = path or self._search_path
        cmd = ["rg", pattern]

        if output_format == "json":
            cmd.extend(["--json"])

        if context_lines is not None:
            cmd.extend(["-C", str(context_lines)])

        if max_results is not None:
            cmd.extend(["-m", str(max_results)])

        cmd.append(search_path)

        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                check=True
            )
            
            if output_format == "json":
                # Parse JSON output
                lines = result.stdout.strip().split("\n")
                json_results = [json.loads(line) for line in lines if line]
                return json_results
            
            return result.stdout

        except Exception as e:
            raise RuntimeError(f"Failed to execute search: {str(e)}")

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