import requests
from typing import Dict, Any, Optional
import json
import os

class IntegrityAPI:
    def __init__(self):
        self.base_url = "https://integrity-server.up.railway.app"
        self.config_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "config")
        self.session = requests.Session()
        self._load_config()
    
    def _load_config(self):
        """Load configuration from config file"""
        config_file = os.path.join(self.config_dir, "config.json")
        try:
            with open(config_file, 'r') as f:
                self.config = json.load(f)
        except FileNotFoundError:
            self.config = {}
    
    def _save_config(self):
        """Save configuration to config file"""
        config_file = os.path.join(self.config_dir, "config.json")
        os.makedirs(self.config_dir, exist_ok=True)
        with open(config_file, 'w') as f:
            json.dump(self.config, f)
    
    def login(self, email: str, password: str) -> Dict[str, Any]:
        """Login to Integrity Assistant"""
        try:
            response = self.session.post(
                f"{self.base_url}/auth/login",
                json={"email": email, "password": password}
            )
            response.raise_for_status()
            data = response.json()
            self.config["auth_token"] = data.get("token")
            self._save_config()
            return {"status": "success", "data": data}
        except requests.RequestException as e:
            return {"status": "error", "message": str(e)}
    
    def send_analysis(self, analysis_data: Dict[str, Any]) -> Dict[str, Any]:
        """Send screen analysis data to server"""
        if not self.config.get("auth_token"):
            return {"status": "error", "message": "Not authenticated"}
        
        try:
            headers = {"Authorization": f"Bearer {self.config['auth_token']}"}
            response = self.session.post(
                f"{self.base_url}/analysis",
                json=analysis_data,
                headers=headers
            )
            response.raise_for_status()
            return {"status": "success", "data": response.json()}
        except requests.RequestException as e:
            return {"status": "error", "message": str(e)}

    def analyze_screen(self, image_data: bytes) -> Dict:
        """Send screen data for analysis"""
        if not self.config.get("auth_token"):
            return {"status": "error", "message": "Not authenticated"}
        
        try:
            headers = {"Authorization": f"Bearer {self.config['auth_token']}"}
            files = {"image": ("screenshot.png", image_data, "image/png")}
            response = self.session.post(
                f"{self.base_url}/analyze",
                files=files,
                headers=headers
            )
            response.raise_for_status()
            return {"status": "success", "data": response.json()}
        except requests.RequestException as e:
            return {"status": "error", "message": str(e)}
    
    def logout(self):
        """Clear the current session"""
        self.config["auth_token"] = None
        self._save_config()
        self.session.cookies.clear() 