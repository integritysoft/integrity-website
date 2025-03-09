import os
import sys
import logging
from datetime import datetime
from typing import Optional

class IntegrityLogger:
    _instance: Optional['IntegrityLogger'] = None
    
    def __init__(self):
        if IntegrityLogger._instance is not None:
            raise RuntimeError("Use IntegrityLogger.get_logger() instead")
        
        self.log_dir = os.path.join(os.path.expanduser('~'), 'IntegrityAssistant', 'logs')
        os.makedirs(self.log_dir, exist_ok=True)
        
        # Set up file handler
        log_file = os.path.join(self.log_dir, f'integrity_{datetime.now().strftime("%Y%m%d_%H%M%S")}.log')
        file_handler = logging.FileHandler(log_file, encoding='utf-8')
        file_handler.setLevel(logging.DEBUG)
        file_formatter = logging.Formatter(
            '%(asctime)s - %(name)s - [%(levelname)s] - %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
        file_handler.setFormatter(file_formatter)
        
        # Set up console handler
        console_handler = logging.StreamHandler(sys.stdout)
        console_handler.setLevel(logging.INFO)
        console_formatter = logging.Formatter('%(levelname)s: %(message)s')
        console_handler.setFormatter(console_formatter)
        
        # Configure root logger
        self.logger = logging.getLogger('IntegrityAssistant')
        self.logger.setLevel(logging.DEBUG)
        self.logger.addHandler(file_handler)
        self.logger.addHandler(console_handler)
        
        IntegrityLogger._instance = self
    
    @staticmethod
    def get_logger() -> logging.Logger:
        if IntegrityLogger._instance is None:
            IntegrityLogger()
        return IntegrityLogger._instance.logger
    
    @staticmethod
    def get_log_dir() -> str:
        if IntegrityLogger._instance is None:
            IntegrityLogger()
        return IntegrityLogger._instance.log_dir 