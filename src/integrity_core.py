import os
import sys
import logging
from typing import Dict, Any, Optional, Tuple
from datetime import datetime, timedelta
import numpy as np
import cv2
from PIL import ImageGrab, Image
import easyocr
import time
import shutil

class ScreenAnalyzer:
    def __init__(self):
        self.last_screenshot: Optional[np.ndarray] = None
        self.reader = None  # Initialize OCR reader only when needed
        self.logger = logging.getLogger("IntegrityCore.ScreenAnalyzer")
        self.last_save_time = 0
        self.images_dir = os.path.join(os.path.expanduser('~'), 'IntegrityAssistant', 'images')
        os.makedirs(self.images_dir, exist_ok=True)
        self.cleanup_old_images()
    
    def capture_screen(self) -> np.ndarray:
        """Capture the current screen optimized for OCR"""
        try:
            # Use PIL's ImageGrab for efficient screen capture
            screenshot = ImageGrab.grab()
            
            # Convert to numpy array efficiently
            frame = np.asarray(screenshot)
            
            # Store in BGR format for OpenCV processing
            self.last_screenshot = cv2.cvtColor(frame, cv2.COLOR_RGB2BGR)
            
            # Save periodic snapshot if needed
            self._save_periodic_snapshot()
            
            return self.last_screenshot
            
        except Exception as e:
            self.logger.error(f"Screen capture failed: {str(e)}")
            raise

    def _save_periodic_snapshot(self):
        """Save screenshot every minute"""
        current_time = time.time()
        if current_time - self.last_save_time >= 60:  # 1 minute interval
            try:
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                filename = os.path.join(self.images_dir, f"snapshot_{timestamp}.jpg")
                
                # Save as JPEG with good quality (95) - better size/quality trade-off for screenshots
                cv2.imwrite(filename, self.last_screenshot, [cv2.IMWRITE_JPEG_QUALITY, 95])
                
                self.last_save_time = current_time
                self.logger.debug(f"Saved periodic snapshot: {filename}")
                
                # Cleanup old images after saving new one
                self.cleanup_old_images()
                
            except Exception as e:
                self.logger.error(f"Failed to save periodic snapshot: {str(e)}")
    
    def cleanup_old_images(self):
        """Remove images older than one week"""
        try:
            current_time = datetime.now()
            week_ago = current_time - timedelta(days=7)
            
            for filename in os.listdir(self.images_dir):
                if not filename.startswith("snapshot_"):
                    continue
                
                filepath = os.path.join(self.images_dir, filename)
                file_time = datetime.strptime(filename.split("_")[1].split(".")[0], "%Y%m%d_%H%M%S")
                
                if file_time < week_ago:
                    os.remove(filepath)
                    self.logger.debug(f"Removed old snapshot: {filename}")
            
            # Check directory size and clean up if too large (e.g., > 1GB)
            dir_size = sum(os.path.getsize(os.path.join(self.images_dir, f)) 
                          for f in os.listdir(self.images_dir))
            if dir_size > 1_000_000_000:  # 1GB
                self.logger.warning("Images directory exceeds 1GB, performing cleanup")
                files = sorted(
                    [(f, os.path.getmtime(os.path.join(self.images_dir, f))) 
                     for f in os.listdir(self.images_dir) if f.startswith("snapshot_")],
                    key=lambda x: x[1]
                )
                # Keep only the newest 10000 files
                for filename, _ in files[:-10000]:
                    os.remove(os.path.join(self.images_dir, filename))
                
        except Exception as e:
            self.logger.error(f"Failed to cleanup old images: {str(e)}")

    def preprocess_for_ocr(self, image: np.ndarray) -> np.ndarray:
        """
        Preprocess image to improve OCR accuracy
        """
        try:
            # Convert to grayscale
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
            
            # Apply adaptive thresholding to handle different lighting conditions
            binary = cv2.adaptiveThreshold(
                gray, 
                255, 
                cv2.ADAPTIVE_THRESH_GAUSSIAN_C, 
                cv2.THRESH_BINARY, 
                11, 
                2
            )
            
            # Denoise to remove small artifacts
            denoised = cv2.fastNlMeansDenoising(binary)
            
            # Enhance contrast
            clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8,8))
            enhanced = clahe.apply(denoised)
            
            return enhanced
            
        except Exception as e:
            self.logger.error(f"Image preprocessing failed: {str(e)}")
            raise
    
    def _ensure_ocr_reader(self):
        """Initialize the OCR reader if not already initialized"""
        if self.reader is None:
            try:
                self.logger.info("Initializing EasyOCR reader...")
                self.reader = easyocr.Reader(['en'])
                self.logger.info("EasyOCR reader initialized successfully")
            except Exception as e:
                self.logger.error(f"Failed to initialize OCR reader: {str(e)}")
                raise
    
    def get_screen_text(self) -> Tuple[str, float]:
        """
        Extract text from the last captured screenshot
        Returns:
            Tuple of (extracted_text, confidence_score)
        """
        if self.last_screenshot is None:
            self.logger.warning("No screenshot available for text extraction")
            return "", 0.0
        
        try:
            self._ensure_ocr_reader()
            
            # Preprocess image for better OCR
            processed_image = self.preprocess_for_ocr(self.last_screenshot)
            
            # Perform OCR with confidence scores
            start_time = time.time()
            results = self.reader.readtext(processed_image)
            duration = time.time() - start_time
            
            # Extract text and calculate average confidence
            if results:
                texts = []
                total_confidence = 0.0
                
                for bbox, text, confidence in results:
                    texts.append(text)
                    total_confidence += confidence
                
                extracted_text = ' '.join(texts)
                avg_confidence = total_confidence / len(results)
                
                self.logger.info(
                    f"Text extraction completed in {duration:.2f} seconds "
                    f"with {avg_confidence:.2%} confidence"
                )
                self.logger.debug(f"Extracted text: {extracted_text[:100]}...")
                
                return extracted_text, avg_confidence
            
            return "", 0.0
            
        except Exception as e:
            self.logger.error(f"Text extraction failed: {str(e)}")
            raise

class ConfigManager:
    def __init__(self):
        self.config_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "config")
        os.makedirs(self.config_dir, exist_ok=True)
    
    def save_config(self, key: str, value: str):
        """Save a configuration value"""
        with open(os.path.join(self.config_dir, f"{key}.txt"), "w") as f:
            f.write(value)
    
    def load_config(self, key: str, default: str = "") -> str:
        """Load a configuration value"""
        try:
            with open(os.path.join(self.config_dir, f"{key}.txt"), "r") as f:
                return f.read().strip()
        except FileNotFoundError:
            return default 

class IntegrityCore:
    def __init__(self):
        self.config_dir = os.path.join(os.path.expanduser('~'), 'IntegrityAssistant', 'config')
        os.makedirs(self.config_dir, exist_ok=True)
        self.setup_logging()
        self.screen_analyzer = ScreenAnalyzer()
        
    def setup_logging(self):
        """Set up logging configuration"""
        log_file = os.path.join(self.config_dir, "integrity.log")
        
        # Ensure log directory exists
        os.makedirs(os.path.dirname(log_file), exist_ok=True)
        
        # Configure logging with rotation
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(log_file, encoding='utf-8'),
                logging.StreamHandler(sys.stdout)
            ]
        )
        self.logger = logging.getLogger("IntegrityCore")
        self.logger.info("Logging initialized")
    
    def analyze_screen(self) -> Dict[str, Any]:
        """Analyze current screen content"""
        self.logger.info("Starting screen analysis")
        start_time = time.time()
        
        try:
            # Capture and process screen
            self.screen_analyzer.capture_screen()
            
            # Extract text with confidence score
            text, confidence = self.screen_analyzer.get_screen_text()
            
            duration = time.time() - start_time
            self.logger.info(f"Screen analysis completed in {duration:.2f} seconds")
            
            return {
                "status": "success",
                "message": "Screen analysis completed",
                "text": text,
                "confidence": confidence,
                "timestamp": time.time(),
                "duration": duration
            }
            
        except Exception as e:
            self.logger.error(f"Screen analysis failed: {str(e)}", exc_info=True)
            return {
                "status": "error",
                "message": str(e),
                "timestamp": time.time()
            }
    
    def get_version(self) -> str:
        """Get current version of Integrity Assistant"""
        return "2.0.0" 