import os
import sys
import threading
import asyncio
from typing import Optional, Callable, Dict, Any
import customtkinter as ctk
from integrity_logger import IntegrityLogger
from integrity_config import ConfigManager

class SettingsDialog(ctk.CTkToplevel):
    def __init__(self, parent):
        super().__init__(parent)
        
        self.title("Settings")
        self.geometry("600x400")
        self.resizable(False, False)
        
        self.config = ConfigManager.get_instance()
        self.logger = IntegrityLogger.get_logger()
        
        self.create_widgets()
        
        # Make dialog modal
        self.transient(parent)
        self.grab_set()
    
    def create_widgets(self):
        # Create tabs
        self.tabview = ctk.CTkTabview(self)
        self.tabview.pack(fill="both", expand=True, padx=10, pady=10)
        
        # General tab
        general_tab = self.tabview.add("General")
        self._create_general_tab(general_tab)
        
        # Analysis tab
        analysis_tab = self.tabview.add("Analysis")
        self._create_analysis_tab(analysis_tab)
        
        # Buttons
        button_frame = ctk.CTkFrame(self)
        button_frame.pack(fill="x", padx=10, pady=10)
        
        reset_btn = ctk.CTkButton(
            button_frame,
            text="Reset to Defaults",
            command=self._reset_settings
        )
        reset_btn.pack(side="left", padx=5)
        
        save_btn = ctk.CTkButton(
            button_frame,
            text="Save",
            command=self._save_settings
        )
        save_btn.pack(side="right", padx=5)
    
    def _create_general_tab(self, tab):
        # Theme selection
        theme_label = ctk.CTkLabel(tab, text="Theme:")
        theme_label.pack(anchor="w", padx=10, pady=(10,5))
        
        self.theme_var = ctk.StringVar(value=self.config.get("theme"))
        theme_menu = ctk.CTkOptionMenu(
            tab,
            values=["dark", "light"],
            variable=self.theme_var
        )
        theme_menu.pack(anchor="w", padx=10)
        
        # Auto update toggle
        self.auto_update_var = ctk.BooleanVar(value=self.config.get("auto_update"))
        auto_update_cb = ctk.CTkCheckBox(
            tab,
            text="Check for updates automatically",
            variable=self.auto_update_var
        )
        auto_update_cb.pack(anchor="w", padx=10, pady=10)
        
        # Save logs toggle
        self.save_logs_var = ctk.BooleanVar(value=self.config.get("save_logs"))
        save_logs_cb = ctk.CTkCheckBox(
            tab,
            text="Save logs to file",
            variable=self.save_logs_var
        )
        save_logs_cb.pack(anchor="w", padx=10, pady=5)
        
        # Max log files
        max_logs_frame = ctk.CTkFrame(tab)
        max_logs_frame.pack(anchor="w", fill="x", padx=10, pady=10)
        
        max_logs_label = ctk.CTkLabel(max_logs_frame, text="Maximum log files:")
        max_logs_label.pack(side="left", padx=5)
        
        self.max_logs_var = ctk.StringVar(value=str(self.config.get("max_log_files")))
        max_logs_entry = ctk.CTkEntry(
            max_logs_frame,
            width=80,
            textvariable=self.max_logs_var
        )
        max_logs_entry.pack(side="left", padx=5)
    
    def _create_analysis_tab(self, tab):
        # Thread count
        threads_frame = ctk.CTkFrame(tab)
        threads_frame.pack(anchor="w", fill="x", padx=10, pady=10)
        
        threads_label = ctk.CTkLabel(threads_frame, text="Analysis threads:")
        threads_label.pack(side="left", padx=5)
        
        self.threads_var = ctk.StringVar(value=str(self.config.get("analysis.threads")))
        threads_entry = ctk.CTkEntry(
            threads_frame,
            width=80,
            textvariable=self.threads_var
        )
        threads_entry.pack(side="left", padx=5)
        
        # Timeout
        timeout_frame = ctk.CTkFrame(tab)
        timeout_frame.pack(anchor="w", fill="x", padx=10, pady=10)
        
        timeout_label = ctk.CTkLabel(timeout_frame, text="Analysis timeout (seconds):")
        timeout_label.pack(side="left", padx=5)
        
        self.timeout_var = ctk.StringVar(value=str(self.config.get("analysis.timeout")))
        timeout_entry = ctk.CTkEntry(
            timeout_frame,
            width=80,
            textvariable=self.timeout_var
        )
        timeout_entry.pack(side="left", padx=5)
        
        # Max file size
        max_size_frame = ctk.CTkFrame(tab)
        max_size_frame.pack(anchor="w", fill="x", padx=10, pady=10)
        
        max_size_label = ctk.CTkLabel(max_size_frame, text="Maximum file size (MB):")
        max_size_label.pack(side="left", padx=5)
        
        current_max_size = self.config.get("analysis.max_file_size") // (1024 * 1024)
        self.max_size_var = ctk.StringVar(value=str(current_max_size))
        max_size_entry = ctk.CTkEntry(
            max_size_frame,
            width=80,
            textvariable=self.max_size_var
        )
        max_size_entry.pack(side="left", padx=5)
    
    def _reset_settings(self):
        self.config.reset()
        self.destroy()
        self.master.show_success("Settings reset to defaults")
    
    def _save_settings(self):
        try:
            # Update general settings
            self.config.set("theme", self.theme_var.get())
            self.config.set("auto_update", self.auto_update_var.get())
            self.config.set("save_logs", self.save_logs_var.get())
            self.config.set("max_log_files", int(self.max_logs_var.get()))
            
            # Update analysis settings
            self.config.set("analysis.threads", int(self.threads_var.get()))
            self.config.set("analysis.timeout", int(self.timeout_var.get()))
            max_size_mb = int(self.max_size_var.get())
            self.config.set("analysis.max_file_size", max_size_mb * 1024 * 1024)
            
            self.destroy()
            self.master.show_success("Settings saved successfully")
            self.master.apply_settings()
            
        except ValueError as e:
            self.master.show_error("Invalid value entered. Please check your inputs.")
        except Exception as e:
            self.master.show_error(f"Failed to save settings: {str(e)}")

class LoadingOverlay(ctk.CTkFrame):
    def __init__(self, master, message: str = "Processing..."):
        super().__init__(master)
        self.configure(fg_color=("gray85", "gray25"))
        
        self.loading_label = ctk.CTkLabel(
            self, 
            text=message,
            font=("Helvetica", 16)
        )
        self.loading_label.place(relx=0.5, rely=0.5, anchor="center")
    
    def update_message(self, message: str):
        self.loading_label.configure(text=message)

class IntegrityUI(ctk.CTk):
    def __init__(self, app):
        super().__init__()
        
        self.app = app
        self.logger = IntegrityLogger.get_logger()
        self.config = ConfigManager.get_instance()
        self.loading_overlay: Optional[LoadingOverlay] = None
        self.user_info: Optional[Dict[str, Any]] = None
        
        self.setup_window()
        self.create_widgets()
        self.apply_settings()
        
        self.logger.info("UI initialized successfully")
    
    def setup_window(self):
        self.title("Integrity Assistant")
        self.geometry("1024x768")
        
        # Configure grid
        self.grid_columnconfigure(0, weight=1)
        self.grid_rowconfigure(1, weight=1)
        
        # Set minimum window size
        self.minsize(800, 600)
    
    def create_widgets(self):
        # Header frame
        header_frame = ctk.CTkFrame(self)
        header_frame.grid(row=0, column=0, padx=10, pady=(10,5), sticky="ew")
        
        title = ctk.CTkLabel(
            header_frame, 
            text="Integrity Assistant",
            font=("Helvetica", 24, "bold")
        )
        title.pack(side="left", pady=10, padx=10)
        
        # User info frame (right side of header)
        self.user_frame = ctk.CTkFrame(header_frame)
        self.user_frame.pack(side="right", pady=10, padx=10)
        
        self.user_label = ctk.CTkLabel(
            self.user_frame,
            text="Not logged in",
            font=("Helvetica", 12)
        )
        self.user_label.pack(side="left", padx=5)
        
        self.questions_label = ctk.CTkLabel(
            self.user_frame,
            text="",
            font=("Helvetica", 12)
        )
        self.questions_label.pack(side="left", padx=5)
        
        # Main content frame
        self.content_frame = ctk.CTkFrame(self)
        self.content_frame.grid(row=1, column=0, padx=10, pady=5, sticky="nsew")
        
        # Configure content grid
        self.content_frame.grid_columnconfigure(0, weight=1)
        self.content_frame.grid_rowconfigure(1, weight=1)
        
        # Add main buttons
        self.create_main_buttons()
        
        # Status bar
        self.status_label = ctk.CTkLabel(
            self,
            text="Ready",
            anchor="w"
        )
        self.status_label.grid(row=2, column=0, padx=10, pady=5, sticky="ew")
    
    def create_main_buttons(self):
        button_frame = ctk.CTkFrame(self.content_frame)
        button_frame.grid(row=0, column=0, padx=10, pady=10, sticky="ew")
        
        analyze_btn = ctk.CTkButton(
            button_frame,
            text="Start Analysis",
            command=lambda: self.run_with_loading(
                self.start_analysis,
                "Analyzing..."
            )
        )
        analyze_btn.pack(side="left", padx=5)
        
        settings_btn = ctk.CTkButton(
            button_frame,
            text="Settings",
            command=self.open_settings
        )
        settings_btn.pack(side="left", padx=5)
        
        logout_btn = ctk.CTkButton(
            button_frame,
            text="Logout",
            command=self.logout
        )
        logout_btn.pack(side="right", padx=5)
    
    def show_loading(self, message: str = "Processing..."):
        if self.loading_overlay is None:
            self.loading_overlay = LoadingOverlay(self, message)
            self.loading_overlay.place(relx=0, rely=0, relwidth=1, relheight=1)
            self.update()
    
    def hide_loading(self):
        if self.loading_overlay is not None:
            self.loading_overlay.destroy()
            self.loading_overlay = None
            self.update()
    
    def update_status(self, message: str):
        self.status_label.configure(text=message)
        self.update()
    
    def show_error(self, message: str):
        self.logger.error(message)
        ctk.CTkMessagebox(
            title="Error",
            message=message,
            icon="cancel"
        )
    
    def show_success(self, message: str):
        self.logger.info(message)
        ctk.CTkMessagebox(
            title="Success",
            message=message,
            icon="check"
        )
    
    def run_with_loading(self, func: Callable, loading_message: str = "Processing..."):
        def wrapper():
            try:
                self.show_loading(loading_message)
                result = func()
                self.hide_loading()
                return result
            except Exception as e:
                self.logger.error("Operation failed", exc_info=True)
                self.hide_loading()
                self.show_error(f"Operation failed: {str(e)}")
                return None
        
        thread = threading.Thread(target=wrapper)
        thread.daemon = True
        thread.start()
    
    async def start_analysis(self):
        self.logger.info("Starting analysis...")
        self.update_status("Analysis in progress...")
        
        try:
            # Get screenshot or other analysis data
            analysis_data = {"type": "test"}  # Replace with actual data
            
            # Send to server
            result = await self.app.api.send_analysis(analysis_data)
            
            if result["status"] == "success":
                self.show_success("Analysis completed successfully!")
                # Update remaining questions count
                await self.update_user_info()
            else:
                self.show_error(f"Analysis failed: {result.get('message', 'Unknown error')}")
        except Exception as e:
            self.logger.error("Analysis failed", exc_info=True)
            self.show_error(f"Analysis failed: {str(e)}")
        finally:
            self.update_status("Ready")
    
    def open_settings(self):
        self.logger.info("Opening settings...")
        SettingsDialog(self)
    
    async def logout(self):
        try:
            await self.app.api.logout()
            self.user_info = None
            self.update_user_label()
            self.app.show_login_dialog()
        except Exception as e:
            self.logger.error(f"Logout failed: {e}")
            self.show_error(f"Logout failed: {str(e)}")
    
    def update_user_info(self, profile_data: Dict[str, Any] = None):
        """Update user information display"""
        self.user_info = profile_data
        self.update_user_label()
    
    def update_user_label(self):
        """Update the user information labels"""
        if self.user_info:
            self.user_label.configure(
                text=f"User: {self.user_info.get('username', 'Unknown')}"
            )
            questions_used = self.user_info.get('questions_used', 0)
            questions_limit = self.user_info.get('questions_limit', 10)
            self.questions_label.configure(
                text=f"Questions: {questions_used}/{questions_limit}"
            )
        else:
            self.user_label.configure(text="Not logged in")
            self.questions_label.configure(text="")
    
    async def update_user_info_from_server(self):
        """Update user information from server"""
        try:
            profile = await self.app.api.get_user_profile()
            if profile["status"] == "success":
                self.update_user_info(profile["data"])
        except Exception as e:
            self.logger.error(f"Failed to update user info: {e}")
    
    def apply_settings(self):
        """Apply current settings to the UI"""
        theme = self.config.get("theme", "dark")
        ctk.set_appearance_mode(theme)
        self.logger.info(f"Applied theme: {theme}") 