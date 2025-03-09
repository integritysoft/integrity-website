"""
Main entry point for the Integrity Assistant application.
Handles initialization, logging setup, and UI launch.
"""

import os
import sys
import logging
from datetime import datetime
from pathlib import Path

from .config import ConfigManager
from .logger import IntegrityLogger
from .ui import IntegrityUI
from .utils import setup_exception_handler

def main():
    """
    Main entry point for the Integrity Assistant application.
    Initializes all required components and starts the UI.
    """
    try:
        # Initialize logger
        logger = IntegrityLogger.get_instance()
        logger.info("Starting Integrity Assistant v1.0.2")

        # Initialize configuration
        config = ConfigManager.get_instance()
        logger.info(f"Loaded configuration from {config.config_path}")

        # Set up global exception handler
        setup_exception_handler()

        # Create and start UI
        app = IntegrityUI()
        app.mainloop()

    except Exception as e:
        if 'logger' in locals():
            logger.error(f"Fatal error during startup: {str(e)}", exc_info=True)
        print(f"Fatal error: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()
