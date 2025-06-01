#!/usr/bin/env python3
# Copyright 2025 Joel Mattsson
# See LICENSE file for licensing details.

"""Search provider interface."""

import logging
from typing import Dict, Optional

from ops.charm import CharmBase
from ops.framework import Object

logger = logging.getLogger(__name__)

class SearchProvider(Object):
    """Interface for the search provider."""

    def __init__(self, charm: CharmBase):
        """Initialize search provider.
        
        Args:
            charm: The charm that provides this interface
        """
        super().__init__(charm, "search-provider")
        self._charm = charm
        self._relation_name = "search-api"

    def is_ready(self) -> bool:
        """Check if the interface is ready for use.
        
        Returns:
            True if the interface has at least one relation
        """
        return bool(self._charm.model.relations.get(self._relation_name))

    def set_search_data(self, relation_id: int, data: Dict) -> None:
        """Set search data in the relation.
        
        Args:
            relation_id: The ID of the relation
            data: The data to set
        """
        relation = self._charm.model.get_relation(self._relation_name, relation_id)
        if relation:
            relation.data[self._charm.app].update(data)

    def get_search_data(self, relation_id: int) -> Optional[Dict]:
        """Get search data from the relation.
        
        Args:
            relation_id: The ID of the relation
            
        Returns:
            The search data or None if not found
        """
        relation = self._charm.model.get_relation(self._relation_name, relation_id)
        if relation and relation.data.get(self._charm.app):
            return dict(relation.data[self._charm.app]) 