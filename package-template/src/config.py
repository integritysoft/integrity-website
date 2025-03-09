"""
Configuration management for the Integrity Assistant application.
"""

import os
import json
from pathlib import Path
from typing import Any, Dict, Optional

from .utils import get_app_dir, ensure_dir
from .logger import IntegrityLogger

DEFAULT_CONFIG = {
    "appearance": {
        "theme": "system",  # system, light, dark
        "color_theme": "blue"
    },
    "general": {
        "language": "en",
        "auto_update": True,
        "save_logs": True
    },
    "analysis": {
        "thread_count": 4,
        "timeout": 30,
        "max_file_size": 100  # MB
    }
}

class ConfigManager:
    """
    Singleton configuration manager for the Integrity Assistant application.
    Handles loading, saving, and accessing configuration settings.
    """
    _instance: Optional['ConfigManager'] = None
    _initialized = False

    def __init__(self):
        if ConfigManager._initialized:
            raise RuntimeError("Use get_instance() instead")
        ConfigManager._initialized = True
        
        self.logger = IntegrityLogger.get_instance()
        self._config_dir = ensure_dir(get_app_dir() / "config")
        self._config_file = self._config_dir / "config.json"
        self._config = self._load_config()

    @classmethod
    def get_instance(cls) -> 'ConfigManager':
        """Get or create the singleton configuration manager instance."""
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance

    def _load_config(self) -> Dict[str, Any]:
        """Load configuration from file or create default."""
        if self._config_file.exists():
            try:
                with open(self._config_file, 'r') as f:
                    config = json.load(f)
                # Update with any missing default values
                return self._deep_update(DEFAULT_CONFIG.copy(), config)
            except Exception as e:
                self.logger.error(f"Error loading config: {e}")
                return DEFAULT_CONFIG.copy()
        else:
            # Create new config file with defaults
            self._save_config(DEFAULT_CONFIG)
            return DEFAULT_CONFIG.copy()

    def _save_config(self, config: Dict[str, Any]) -> None:
        """Save configuration to file."""
        try:
            with open(self._config_file, 'w') as f:
                json.dump(config, f, indent=4)
        except Exception as e:
            self.logger.error(f"Error saving config: {e}")

    def _deep_update(self, base: Dict[str, Any], update: Dict[str, Any]) -> Dict[str, Any]:
        """Recursively update a dictionary with another."""
        for key, value in update.items():
            if key in base and isinstance(base[key], dict) and isinstance(value, dict):
                base[key] = self._deep_update(base[key], value)
            else:
                base[key] = value
        return base

    def get(self, key: str, default: Any = None) -> Any:
        """
        Get a configuration value by key.
        Supports nested keys using dot notation (e.g., 'appearance.theme').
        """
        try:
            value = self._config
            for k in key.split('.'):
                value = value[k]
            return value
        except (KeyError, TypeError):
            return default

    def set(self, key: str, value: Any) -> None:
        """
        Set a configuration value by key.
        Supports nested keys using dot notation (e.g., 'appearance.theme').
        """
        try:
            keys = key.split('.')
            target = self._config
            for k in keys[:-1]:
                target = target[k]
            target[keys[-1]] = value
            self._save_config(self._config)
        except Exception as e:
            self.logger.error(f"Error setting config value: {e}")

    def reset(self) -> None:
        """Reset configuration to default values."""
        self._config = DEFAULT_CONFIG.copy()
        self._save_config(self._config)

    @property
    def config_path(self) -> Path:
        """Get the configuration file path."""
        return self._config_file 