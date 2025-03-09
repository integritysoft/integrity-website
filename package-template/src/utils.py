"""
Utility functions for the Integrity Assistant application.
"""

import os
import sys
import traceback
import logging
from pathlib import Path
from typing import Optional
from datetime import datetime

def setup_exception_handler():
    """
    Set up a global exception handler to catch and log unhandled exceptions.
    """
    def handle_exception(exc_type, exc_value, exc_traceback):
        if issubclass(exc_type, KeyboardInterrupt):
            sys.__excepthook__(exc_type, exc_value, exc_traceback)
            return

        logger = logging.getLogger('integrity_assistant')
        logger.error(
            "Uncaught exception:",
            exc_info=(exc_type, exc_value, exc_traceback)
        )

    sys.excepthook = handle_exception

def get_app_dir() -> Path:
    """
    Get the application directory in the user's home folder.
    Creates the directory if it doesn't exist.
    """
    app_dir = Path.home() / "IntegrityAssistant"
    app_dir.mkdir(parents=True, exist_ok=True)
    return app_dir

def format_timestamp(dt: Optional[datetime] = None) -> str:
    """
    Format a timestamp for use in filenames and logs.
    """
    if dt is None:
        dt = datetime.now()
    return dt.strftime("%Y%m%d_%H%M%S")

def ensure_dir(path: Path) -> Path:
    """
    Ensure a directory exists, creating it if necessary.
    Returns the Path object.
    """
    path.mkdir(parents=True, exist_ok=True)
    return path 