#!/usr/bin/env python3
# Copyright 2025 Joel Mattsson
# See LICENSE file for licensing details.

"""Interface for the search provider."""

import logging
from typing import Dict, Optional

import ops
from ops.framework import Object

logger = logging.getLogger(__name__)

class SearchProvider(Object):
    """Interface for providing search capabilities."""

    def __init__(self, charm: ops.CharmBase):
        super().__init__(charm, "search-provider")
        self._charm = charm
        self._relation_name = "search-api"

    def is_ready(self) -> bool:
        """Check if the interface is ready for use."""
        if not self._charm.unit.is_leader():
            return True

        relation = self._charm.model.get_relation(self._relation_name)
        if not relation:
            return False

        return True

    def set_search_data(self, relation_id: int, data: Dict[str, str]) -> None:
        """Set search-related data in the relation."""
        if not self._charm.unit.is_leader():
            return

        relation = self._charm.model.get_relation(self._relation_name, relation_id)
        if not relation:
            logger.warning(f"Relation {self._relation_name}:{relation_id} not found")
            return

        relation.data[self._charm.app].update(data)

    def get_search_data(self, relation_id: int) -> Optional[Dict[str, str]]:
        """Get search-related data from the relation."""
        relation = self._charm.model.get_relation(self._relation_name, relation_id)
        if not relation:
            logger.warning(f"Relation {self._relation_name}:{relation_id} not found")
            return None

        return dict(relation.data[self._charm.app]) 