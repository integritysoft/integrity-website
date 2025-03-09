import requests
from typing import Dict, Any, Optional
import json
import os
from supabase import create_client, Client
from integrity_logger import IntegrityLogger

class IntegrityAPI:
    def __init__(self):
        self.logger = IntegrityLogger.get_logger()
        self.base_url = "https://integrity-server.up.railway.app"
        self.config_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "config")
        self.session = requests.Session()
        self._load_config()
        self._init_supabase()
    
    def _load_config(self):
        """Load configuration from config file"""
        config_file = os.path.join(self.config_dir, "config.json")
        try:
            with open(config_file, 'r') as f:
                self.config = json.load(f)
        except FileNotFoundError:
            self.config = {}
            self._save_config()
        
        self.logger.debug("Configuration loaded")
    
    def _save_config(self):
        """Save configuration to config file"""
        config_file = os.path.join(self.config_dir, "config.json")
        os.makedirs(self.config_dir, exist_ok=True)
        with open(config_file, 'w') as f:
            json.dump(self.config, f)
        
        self.logger.debug("Configuration saved")
    
    def _init_supabase(self):
        """Initialize Supabase client"""
        try:
            supabase_url = self.config.get('supabase_url', 'https://qamcmtaupcztangqvhkz.supabase.co')
            supabase_key = self.config.get('supabase_key', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFhbWNtdGF1cGN6dGFuZ3F2aGt6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDEyMzc0MTMsImV4cCI6MjA1NjgxMzQxM30.UWinrT5vTh0P7GcXRL2dgP6IEkPQ83Ur1kghe-lm1Mg')
            self.supabase: Client = create_client(supabase_url, supabase_key)
            self.logger.info("Supabase client initialized")
        except Exception as e:
            self.logger.error(f"Failed to initialize Supabase client: {e}")
            raise
    
    async def login(self, email: str, password: str) -> Dict[str, Any]:
        """Login to Integrity Assistant using Supabase"""
        try:
            # Attempt Supabase login
            auth_response = await self.supabase.auth.sign_in_with_password({
                "email": email,
                "password": password
            })
            
            if auth_response.user:
                # Store the session
                self.config["auth_token"] = auth_response.session.access_token
                self.config["user_id"] = auth_response.user.id
                self._save_config()
                
                # Set up session headers for Railway API
                self.session.headers.update({
                    "Authorization": f"Bearer {auth_response.session.access_token}"
                })
                
                self.logger.info(f"User {email} logged in successfully")
                return {"status": "success", "data": auth_response.user}
            
            raise Exception("Authentication failed")
            
        except Exception as e:
            self.logger.error(f"Login failed: {e}")
            return {"status": "error", "message": str(e)}
    
    async def verify_session(self) -> bool:
        """Verify if the current session is valid"""
        try:
            if not self.config.get("auth_token"):
                return False
            
            user = await self.supabase.auth.get_user()
            return bool(user)
        except:
            return False
    
    async def get_user_profile(self) -> Dict[str, Any]:
        """Get the current user's profile from Supabase"""
        try:
            if not await self.verify_session():
                raise Exception("Not authenticated")
            
            response = await self.supabase.from_('user_profiles').select("*").single()
            return {"status": "success", "data": response}
        except Exception as e:
            self.logger.error(f"Failed to get user profile: {e}")
            return {"status": "error", "message": str(e)}
    
    async def update_question_count(self) -> Dict[str, Any]:
        """Update the user's daily question count"""
        try:
            if not await self.verify_session():
                raise Exception("Not authenticated")
            
            profile = await self.get_user_profile()
            if profile["status"] != "success":
                raise Exception("Failed to get user profile")
            
            # Update the question count
            response = await self.supabase.from_('user_profiles').update({
                "questions_used": profile["data"]["questions_used"] + 1,
                "last_question_time": "now()"
            }).eq("user_id", self.config["user_id"])
            
            return {"status": "success", "data": response}
        except Exception as e:
            self.logger.error(f"Failed to update question count: {e}")
            return {"status": "error", "message": str(e)}
    
    async def send_analysis(self, analysis_data: Dict[str, Any]) -> Dict[str, Any]:
        """Send screen analysis data to Railway server"""
        if not await self.verify_session():
            return {"status": "error", "message": "Not authenticated"}
        
        try:
            # First update question count
            update_result = await self.update_question_count()
            if update_result["status"] != "success":
                raise Exception("Failed to update question count")
            
            # Send analysis to Railway
            response = self.session.post(
                f"{self.base_url}/analysis",
                json=analysis_data
            )
            response.raise_for_status()
            
            # Track usage in Supabase
            await self.supabase.from_('usage_tracking').insert({
                "user_id": self.config["user_id"],
                "action_type": "analysis",
                "action_details": analysis_data
            })
            
            return {"status": "success", "data": response.json()}
        except Exception as e:
            self.logger.error(f"Failed to send analysis: {e}")
            return {"status": "error", "message": str(e)}
    
    async def analyze_screen(self, image_data: bytes) -> Dict[str, Any]:
        """Send screen data for analysis to Railway server"""
        if not await self.verify_session():
            return {"status": "error", "message": "Not authenticated"}
        
        try:
            files = {"image": ("screenshot.png", image_data, "image/png")}
            response = self.session.post(
                f"{self.base_url}/analyze",
                files=files
            )
            response.raise_for_status()
            
            # Track usage in Supabase
            await self.supabase.from_('usage_tracking').insert({
                "user_id": self.config["user_id"],
                "action_type": "screen_analysis",
                "action_details": {"size": len(image_data)}
            })
            
            return {"status": "success", "data": response.json()}
        except Exception as e:
            self.logger.error(f"Failed to analyze screen: {e}")
            return {"status": "error", "message": str(e)}
    
    async def logout(self):
        """Logout from both Supabase and clear local session"""
        try:
            if self.config.get("auth_token"):
                await self.supabase.auth.sign_out()
            
            self.config["auth_token"] = None
            self.config["user_id"] = None
            self._save_config()
            self.session.headers.pop("Authorization", None)
            self.session.cookies.clear()
            
            self.logger.info("User logged out successfully")
        except Exception as e:
            self.logger.error(f"Logout error: {e}")
            raise 