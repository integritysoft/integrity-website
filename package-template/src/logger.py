"""
Logging configuration for the Integrity Assistant application.
"""

import os
import logging
from pathlib import Path
from typing import Optional
from datetime import datetime

from .utils import get_app_dir, format_timestamp, ensure_dir

class IntegrityLogger:
    """
    Singleton logger class for the Integrity Assistant application.
    Handles both file and console logging with different levels.
    """
    _instance: Optional['IntegrityLogger'] = None
    _initialized = False

    def __init__(self):
        if IntegrityLogger._initialized:
            raise RuntimeError("Use get_instance() instead")
        IntegrityLogger._initialized = True
        self._setup_logger()

    @classmethod
    def get_instance(cls) -> 'IntegrityLogger':
        """Get or create the singleton logger instance."""
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance

    def _setup_logger(self):
        """Set up the logger with file and console handlers."""
        # Create logger
        self.logger = logging.getLogger('integrity_assistant')
        self.logger.setLevel(logging.DEBUG)

        # Ensure log directory exists
        log_dir = ensure_dir(get_app_dir() / "logs")
        
        # Create log file with timestamp
        timestamp = format_timestamp()
        log_file = log_dir / f"integrity_assistant_{timestamp}.log"

        # File handler (DEBUG level)
        file_handler = logging.FileHandler(log_file)
        file_handler.setLevel(logging.DEBUG)
        file_formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )
        file_handler.setFormatter(file_formatter)
        self.logger.addHandler(file_handler)

        # Console handler (INFO level)
        console_handler = logging.StreamHandler()
        console_handler.setLevel(logging.INFO)
        console_formatter = logging.Formatter(
            '%(levelname)s: %(message)s'
        )
        console_handler.setFormatter(console_formatter)
        self.logger.addHandler(console_handler)

        self.info(f"Log file created at: {log_file}")

    def debug(self, msg: str, *args, **kwargs):
        """Log a debug message."""
        self.logger.debug(msg, *args, **kwargs)

    def info(self, msg: str, *args, **kwargs):
        """Log an info message."""
        self.logger.info(msg, *args, **kwargs)

    def warning(self, msg: str, *args, **kwargs):
        """Log a warning message."""
        self.logger.warning(msg, *args, **kwargs)

    def error(self, msg: str, *args, **kwargs):
        """Log an error message."""
        self.logger.error(msg, *args, **kwargs)

    def critical(self, msg: str, *args, **kwargs):
        """Log a critical message."""
        self.logger.critical(msg, *args, **kwargs)

    @property
    def log_dir(self) -> Path:
        """Get the log directory path."""
        return get_app_dir() / "logs" 