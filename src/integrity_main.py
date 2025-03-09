import os
import sys
import json
import asyncio
import traceback
import customtkinter as ctk
from integrity_logger import IntegrityLogger
from integrity_ui import IntegrityUI
from integrity_api import IntegrityAPI
from integrity_config import ConfigManager

class IntegrityAssistant:
    def __init__(self):
        self.logger = IntegrityLogger.get_logger()
        self.config = ConfigManager.get_instance()
        self.api = IntegrityAPI()
        
        # Set up exception handler
        sys.excepthook = self.handle_exception
        
        # Initialize UI
        self.setup_ui()
    
    def handle_exception(self, exc_type, exc_value, exc_traceback):
        """Handle uncaught exceptions"""
        if issubclass(exc_type, KeyboardInterrupt):
            sys.__excepthook__(exc_type, exc_value, exc_traceback)
            return
        
        self.logger.error("Uncaught exception:", exc_info=(exc_type, exc_value, exc_traceback))
        error_msg = f"An unexpected error occurred:\n{exc_type.__name__}: {exc_value}"
        
        if hasattr(sys, '_MEIPASS'):
            error_msg += "\n\nPlease check the logs at:\n" + IntegrityLogger.get_log_dir()
        
        # Show error in UI if possible
        try:
            if hasattr(self.ui, 'show_error'):
                self.ui.show_error(error_msg)
            else:
                import tkinter as tk
                from tkinter import messagebox
                root = tk.Tk()
                root.withdraw()
                messagebox.showerror("Error", error_msg)
                root.destroy()
        except:
            self.logger.error("Failed to show error dialog", exc_info=True)
    
    def setup_ui(self):
        """Set up the application UI"""
        try:
            # Set appearance mode from config
            ctk.set_appearance_mode(self.config.get("theme", "dark"))
            ctk.set_default_color_theme("blue")
            
            # Initialize main window
            self.ui = IntegrityUI(self)
            
            # Check for existing session
            asyncio.run(self.check_session())
            
            self.logger.info("UI initialized successfully")
            
        except Exception as e:
            self.logger.error("Failed to initialize UI", exc_info=True)
            raise
    
    async def check_session(self):
        """Check for existing session and verify it"""
        try:
            if await self.api.verify_session():
                # Get user profile
                profile = await self.api.get_user_profile()
                if profile["status"] == "success":
                    self.ui.update_user_info(profile["data"])
                    self.logger.info("Session restored successfully")
                else:
                    self.show_login_dialog()
            else:
                self.show_login_dialog()
        except Exception as e:
            self.logger.error(f"Session check failed: {e}")
            self.show_login_dialog()
    
    def show_login_dialog(self):
        """Show login dialog"""
        self.login_window = ctk.CTkToplevel()
        self.login_window.title("Integrity Assistant Login")
        self.login_window.geometry("400x300")
        
        ctk.CTkLabel(self.login_window, text="Please log in to continue").pack(pady=20)
        
        email_var = ctk.StringVar()
        password_var = ctk.StringVar()
        
        ctk.CTkLabel(self.login_window, text="Email:").pack()
        email_entry = ctk.CTkEntry(self.login_window, textvariable=email_var)
        email_entry.pack(pady=5)
        
        ctk.CTkLabel(self.login_window, text="Password:").pack()
        password_entry = ctk.CTkEntry(self.login_window, textvariable=password_var, show="*")
        password_entry.pack(pady=5)
        
        async def login():
            try:
                response = await self.api.login(email_var.get(), password_var.get())
                if response["status"] == "success":
                    self.login_window.destroy()
                    profile = await self.api.get_user_profile()
                    if profile["status"] == "success":
                        self.ui.update_user_info(profile["data"])
                else:
                    self.ui.show_error("Login failed. Please check your credentials.")
            except Exception as e:
                self.logger.error(f"Login failed: {e}")
                self.ui.show_error(f"Login failed: {str(e)}")
        
        login_btn = ctk.CTkButton(
            self.login_window,
            text="Login",
            command=lambda: asyncio.run(login())
        )
        login_btn.pack(pady=20)
        
        signup_label = ctk.CTkLabel(
            self.login_window,
            text="Don't have an account? Sign up here",
            cursor="hand2"
        )
        signup_label.pack(pady=10)
        signup_label.bind("<Button-1>", lambda e: self.open_signup_page())
    
    def open_signup_page(self):
        """Open the signup page in default browser"""
        import webbrowser
        webbrowser.open("https://integrity-website.vercel.app/signup")
    
    def run(self):
        """Run the main application"""
        try:
            self.ui.mainloop()
        except Exception as e:
            self.logger.error("Application crashed", exc_info=True)
            raise

def main():
    logger = IntegrityLogger.get_logger()
    logger.info("Starting Integrity Assistant...")
    
    try:
        app = IntegrityAssistant()
        app.run()
    except Exception as e:
        logger.error("Failed to start application", exc_info=True)
        raise

if __name__ == "__main__":
    main() 