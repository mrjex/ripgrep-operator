#!/usr/bin/env python3
# Copyright 2025 Joel Mattsson joel.mattsson@hotmail.se
# See LICENSE file for licensing details.

"""Charm for the Ripgrep operator."""

import logging
from typing import Dict, Optional
import subprocess
import os
from pathlib import Path

import ops
from ops.charm import CharmBase, ConfigChangedEvent, ActionEvent
from ops.main import main
from ops.model import ActiveStatus, BlockedStatus, MaintenanceStatus, WaitingStatus

from interfaces.search_provider import SearchProvider
from utils.ripgrep import RipgrepWrapper

logger = logging.getLogger(__name__)

class RipgrepOperatorCharm(CharmBase):
    """Charm for operating ripgrep as a service."""

    def __init__(self, *args):
        super().__init__(*args)

        # Core charm observers
        self.framework.observe(self.on.config_changed, self._on_config_changed)
        self.framework.observe(self.on.ripgrep_pebble_ready, self._on_ripgrep_pebble_ready)       
        self.framework.observe(self.on.search_pattern_action, self._on_search_pattern)
        self.framework.observe(self.on.install, self._on_install)
        self.framework.observe(self.on.analyze_debian_action, self._on_analyze_debian)
        self.framework.observe(self.on.compare_debian_action, self._on_compare_debian)

        # Storage observers
        self.framework.observe(self.on.data_storage_attached, self._on_storage_attached)

        # Interface observers
        self._search_provider = SearchProvider(self)
        self.framework.observe(
            self.on.search_api_relation_joined,
            self._on_search_relation_joined
        )

        # Initialize ripgrep wrapper as None - will be created when needed
        self._ripgrep = None

    def _ensure_ripgrep(self):
        """Ensure ripgrep is installed and wrapper is initialized."""
        if self._ripgrep is None:
            # First ensure ripgrep is installed
            try:
                subprocess.run(["snap", "install", "ripgrep", "--classic"], check=True)
            except subprocess.CalledProcessError as e:
                logger.error(f"Failed to install ripgrep: {e}")
                raise RuntimeError("Failed to install ripgrep") from e

            # Now initialize the wrapper
            self._ripgrep = RipgrepWrapper()

        return self._ripgrep

    def _on_storage_attached(self, event):
        """Handle storage attachment."""
        if isinstance(event, ops.StorageAttachedEvent):
            storage_name = event.storage.name
            storage_location = event.storage.location

            # Ensure storage directory exists and is writable
            os.makedirs(storage_location, mode=0o755, exist_ok=True)

            logger.info(f"Storage {storage_name} attached at {storage_location}")
            self.unit.status = ActiveStatus()

    def _on_ripgrep_pebble_ready(self, event: ops.PebbleReadyEvent) -> None:
        """Handle pebble ready event."""
        container = event.workload

        # Define an initial Pebble layer configuration
        pebble_layer = {
            "summary": "ripgrep layer",
            "description": "pebble config layer for ripgrep",
            "services": {
                "ripgrep": {
                    "override": "replace",
                    "summary": "ripgrep service",
                    "command": "sleep infinity",  # Placeholder to keep container running
                    "startup": "enabled",
                }
            },
        }

        # Add initial Pebble config layer
        container.add_layer("ripgrep", pebble_layer, combine=True)
        container.autostart()

        self.unit.status = ActiveStatus()

    def _on_config_changed(self, event: ConfigChangedEvent) -> None:
        """Handle changed configuration."""
        # Fetch current config
        search_path = self.config.get("search_path")

        # Always check config and set status accordingly
        if not search_path or search_path == ".":  # Check for default value too
            self.unit.status = BlockedStatus("search_path configuration required")
            return

        try:
            # Update search path in ripgrep wrapper
            self._ensure_ripgrep().set_search_path(search_path)
            self.unit.status = ActiveStatus()
        except Exception as e:
            self.unit.status = BlockedStatus(str(e))

    def _on_search_pattern(self, event: ActionEvent) -> None:
        """Handle search pattern action."""
        try:
            pattern = event.params["pattern"]
            path = event.params.get("path", ".")
            output_format = event.params.get("format", "text")

            self.unit.status = MaintenanceStatus("Executing search")

            # Execute search
            result = self._ensure_ripgrep().search(
                pattern=pattern,
                path=path,
                output_format=output_format
            )

            event.set_results({"result": result})
            self.unit.status = ActiveStatus()

        except Exception as e:
            logger.error(f"Search failed: {str(e)}")
            event.fail(f"Search failed: {str(e)}")
            self.unit.status = BlockedStatus(f"Search failed: {str(e)}")

    def _on_search_relation_joined(self, event: ops.RelationJoinedEvent) -> None:
        """Handle new search relation."""
        # Always start in waiting status for new relations
        self.unit.status = WaitingStatus("Waiting for search relation data")

        # Only change to active if we have all required data
        if self._search_provider.is_ready():
            relation = self.model.get_relation(self._search_provider._relation_name)
            if relation and relation.data.get(self.app):
                self.unit.status = ActiveStatus()

    def _on_install(self, _):
        """Handle installation of required components."""
        self.unit.status = MaintenanceStatus("Installing debian-pkg-analyzer")
        
        try:
            # Get the Snap resource
            resource_path = self.model.resources.fetch('debian-pkg-analyzer')
            
            if not resource_path:
                self.unit.status = BlockedStatus("Missing debian-pkg-analyzer snap resource")
                return
            
            # Install the Snap package
            subprocess.run(
                ['snap', 'install', str(resource_path), '--dangerous'],
                check=True
            )
            
            self.unit.status = ActiveStatus("Ready")
            
        except subprocess.CalledProcessError as e:
            logger.error(f"Failed to install snap: {e}")
            self.unit.status = BlockedStatus("Failed to install debian-pkg-analyzer")

    def _run_cli_command(self, cmd: list) -> Dict[str, str]:
        """Run a CLI command and return the result."""
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                check=True
            )
            return {
                "output": result.stdout,
                "return-code": "0"
            }
        except subprocess.CalledProcessError as e:
            logger.error(f"Command failed: {e}")
            return {
                "error": e.stderr,
                "return-code": str(e.returncode)
            }

    def _on_analyze_debian(self, event: ActionEvent):
        """Handle the analyze-debian action."""
        # Build command from parameters
        cmd = ["debian-pkg-analyzer"]
        
        # Add architecture
        cmd.append(event.params["architecture"])
        
        # Add optional parameters
        if "count" in event.params:
            cmd.extend(["-n", str(event.params["count"])])
        
        if "country" in event.params:
            cmd.extend(["-c", event.params["country"]])
            
        if "release" in event.params:
            cmd.extend(["-r", event.params["release"]])
            
        if event.params.get("format") == "json":
            cmd.append("--format")
            cmd.append("json")
            
        # Run command and set results
        result = self._run_cli_command(cmd)
        event.set_results(result)

    def _on_compare_debian(self, event: ActionEvent):
        """Handle the compare-debian action."""
        cmd = ["debian-pkg-analyzer", "compare"]
        
        # Add comparison type and values
        cmd.extend([
            event.params["comparison_type"],
            event.params["value1"],
            event.params["value2"]
        ])
        
        # Add architecture if specified
        if "architecture" in event.params:
            cmd.extend(["--architecture", event.params["architecture"]])
            
        # Run command and set results
        result = self._run_cli_command(cmd)
        event.set_results(result)

if __name__ == "__main__":
    main(RipgrepOperatorCharm) 