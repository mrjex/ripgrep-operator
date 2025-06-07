#!/usr/bin/env python3
# Copyright 2025 Joel Mattsson joel.mattsson@hotmail.se
# See LICENSE file for licensing details.

"""Charm for the Ripgrep operator."""

import logging
from typing import Dict, Optional
import subprocess

import ops
from ops.charm import CharmBase, ConfigChangedEvent
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
        self.framework.observe(self.on.analyze_action, self._on_analyze)

        # Interface observers
        self._search_provider = SearchProvider(self)
        self.framework.observe(
            self.on.search_api_relation_joined,
            self._on_search_relation_joined
        )

        # Initialize ripgrep wrapper
        self._ripgrep = RipgrepWrapper()

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
            
        # Update search path in ripgrep wrapper
        self._ripgrep.set_search_path(search_path)
        self.unit.status = ActiveStatus()

    def _on_search_pattern(self, event: ops.ActionEvent) -> None:
        """Handle search pattern action."""
        try:
            pattern = event.params["pattern"]
            path = event.params.get("path", ".")
            output_format = event.params.get("format", "text")
            
            self.unit.status = MaintenanceStatus("Executing search")
            
            # Execute search
            result = self._ripgrep.search(
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
        """Install required snaps during charm installation."""
        try:
            # Install both ripgrep and your analyzer
            subprocess.run(["snap", "install", "ripgrep", "--classic"], check=True)
            subprocess.run(["snap", "install", "debian-pkg-analyzer"], check=True)
            self.unit.status = ActiveStatus()
        except subprocess.CalledProcessError as e:
            logger.error(f"Failed to install required snaps: {e}")
            self.unit.status = BlockedStatus("Failed to install required snaps")

    def _on_analyze(self, event):
        """Handle the analyze action."""
        try:
            # First, use debian-pkg-analyzer to get package info
            pkg_name = event.params["package"]
            analysis = subprocess.run(
                ["debian-pkg-analyzer", "compare", pkg_name],
                capture_output=True,
                text=True,
                check=True
            )
            
            # Then use ripgrep to search through the results
            search_pattern = event.params.get("pattern", "")
            if search_pattern:
                rg_results = subprocess.run(
                    ["rg", search_pattern, analysis.stdout],
                    capture_output=True,
                    text=True
                )
                event.set_results({"matches": rg_results.stdout.splitlines()})
            else:
                event.set_results({"analysis": analysis.stdout})
                
        except subprocess.CalledProcessError as e:
            event.fail(f"Analysis failed: {e}")

if __name__ == "__main__":
    main(RipgrepOperatorCharm)
