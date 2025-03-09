import os
import json
from typing import Any, Dict, Optional
from integrity_logger import IntegrityLogger

class ConfigManager:
    _instance: Optional['ConfigManager'] = None
    DEFAULT_CONFIG = {
        "theme": "dark",
        "language": "en",
        "auto_update": True,
        "save_logs": True,
        "max_log_files": 10,
        "analysis": {
            "threads": 4,
            "timeout": 300,
            "max_file_size": 1024 * 1024 * 100  # 100MB
        }
    }
    
    def __init__(self):
        if ConfigManager._instance is not None:
            raise RuntimeError("Use ConfigManager.get_instance() instead")
        
        self.logger = IntegrityLogger.get_logger()
        self.config_dir = os.path.join(os.path.expanduser('~'), 'IntegrityAssistant', 'config')
        self.config_file = os.path.join(self.config_dir, 'config.json')
        self.config: Dict[str, Any] = {}
        
        self._ensure_config_exists()
        self._load_config()
        
        ConfigManager._instance = self
    
    @staticmethod
    def get_instance() -> 'ConfigManager':
        if ConfigManager._instance is None:
            ConfigManager()
        return ConfigManager._instance
    
    def _ensure_config_exists(self):
        """Create config directory and file if they don't exist"""
        os.makedirs(self.config_dir, exist_ok=True)
        
        if not os.path.exists(self.config_file):
            self.logger.info("Creating default configuration file")
            self.config = self.DEFAULT_CONFIG.copy()
            self._save_config()
    
    def _load_config(self):
        """Load configuration from file"""
        try:
            with open(self.config_file, 'r', encoding='utf-8') as f:
                loaded_config = json.load(f)
                
            # Merge with defaults to ensure all keys exist
            self.config = self.DEFAULT_CONFIG.copy()
            self._deep_update(self.config, loaded_config)
            
            self.logger.info("Configuration loaded successfully")
            
        except Exception as e:
            self.logger.error(f"Failed to load configuration: {e}", exc_info=True)
            self.config = self.DEFAULT_CONFIG.copy()
            self._save_config()
    
    def _save_config(self):
        """Save current configuration to file"""
        try:
            with open(self.config_file, 'w', encoding='utf-8') as f:
                json.dump(self.config, f, indent=4)
            
            self.logger.info("Configuration saved successfully")
            
        except Exception as e:
            self.logger.error(f"Failed to save configuration: {e}", exc_info=True)
    
    def _deep_update(self, target: Dict, source: Dict):
        """Recursively update nested dictionaries"""
        for key, value in source.items():
            if key in target and isinstance(target[key], dict) and isinstance(value, dict):
                self._deep_update(target[key], value)
            else:
                target[key] = value
    
    def get(self, key: str, default: Any = None) -> Any:
        """Get a configuration value"""
        try:
            keys = key.split('.')
            value = self.config
            for k in keys:
                value = value[k]
            return value
        except (KeyError, TypeError):
            return default
    
    def set(self, key: str, value: Any):
        """Set a configuration value"""
        try:
            keys = key.split('.')
            target = self.config
            
            # Navigate to the correct nested dictionary
            for k in keys[:-1]:
                if k not in target or not isinstance(target[k], dict):
                    target[k] = {}
                target = target[k]
            
            # Set the value
            target[keys[-1]] = value
            self._save_config()
            
            self.logger.info(f"Configuration updated: {key} = {value}")
            
        except Exception as e:
            self.logger.error(f"Failed to set configuration {key}: {e}", exc_info=True)
    
    def reset(self):
        """Reset configuration to defaults"""
        self.config = self.DEFAULT_CONFIG.copy()
        self._save_config()
        self.logger.info("Configuration reset to defaults") 