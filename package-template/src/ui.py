"""
User interface implementation for the Integrity Assistant application.
"""

import os
import sys
import threading
from typing import Optional, Callable, Any
import customtkinter as ctk
from tkinter import messagebox

from .config import ConfigManager
from .logger import IntegrityLogger

class LoadingOverlay:
    """Overlay widget to show loading state with message."""
    
    def __init__(self, parent: ctk.CTk):
        self.parent = parent
        self.overlay = ctk.CTkFrame(parent, fg_color="gray20")
        self.message = ctk.CTkLabel(
            self.overlay,
            text="Loading...",
            font=("Helvetica", 14),
            text_color="white"
        )
        self.message.pack(pady=20)
        self._active_thread = None
        
    def show(self, message: str = "Loading..."):
        """Show the loading overlay with a message."""
        self.message.configure(text=message)
        self.overlay.place(relx=0, rely=0, relwidth=1, relheight=1)
        self.parent.update()
        
    def hide(self):
        """Hide the loading overlay."""
        self.overlay.place_forget()
        self.parent.update()
        
    def set_active_thread(self, thread: threading.Thread):
        """Set the currently active thread."""
        self._active_thread = thread
        
    def cleanup(self):
        """Clean up resources and wait for thread completion."""
        if self._active_thread and self._active_thread.is_alive():
            self._active_thread.join(timeout=0.5)
        self.hide()

class IntegrityUI(ctk.CTk):
    """Main application window for Integrity Assistant."""
    
    def __init__(self):
        super().__init__()
        
        self.logger = IntegrityLogger.get_instance()
        self.config = ConfigManager.get_instance()
        
        self.title("Integrity Assistant")
        self.geometry("800x600")
        
        # Set appearance mode and color theme
        ctk.set_appearance_mode(self.config.get("appearance.theme", "system"))
        ctk.set_default_color_theme(self.config.get("appearance.color_theme", "blue"))
        
        self._setup_ui()
        self.loading = LoadingOverlay(self)
        
        # Handle window close
        self.protocol("WM_DELETE_WINDOW", self._on_close)
        
    def _on_close(self):
        """Handle window close."""
        self.loading.cleanup()
        self.quit()
        
    def _setup_ui(self):
        """Set up the main UI components."""
        # Header
        header = ctk.CTkFrame(self)
        header.pack(fill="x", padx=10, pady=5)
        
        title = ctk.CTkLabel(
            header,
            text="Integrity Assistant",
            font=("Helvetica", 24, "bold")
        )
        title.pack(side="left", padx=10)
        
        settings_btn = ctk.CTkButton(
            header,
            text="Settings",
            command=self._show_settings
        )
        settings_btn.pack(side="right", padx=10)
        
        # Content area
        content = ctk.CTkFrame(self)
        content.pack(fill="both", expand=True, padx=10, pady=5)
        
        # Status label
        self.status_label = ctk.CTkLabel(
            content,
            text="Ready",
            font=("Helvetica", 12)
        )
        self.status_label.pack(pady=10)
        
        # Buttons
        btn_frame = ctk.CTkFrame(content)
        btn_frame.pack(pady=20)
        
        start_btn = ctk.CTkButton(
            btn_frame,
            text="Start Analysis",
            command=self.start_analysis
        )
        start_btn.pack(side="left", padx=5)
        
    def _show_settings(self):
        """Show the settings dialog."""
        dialog = SettingsDialog(self)
        dialog.grab_set()
        
    def update_status(self, message: str):
        """Update the status message."""
        self.status_label.configure(text=message)
        self.update()
        
    def show_error(self, title: str, message: str):
        """Show an error message dialog."""
        self.logger.error(f"{title}: {message}")
        messagebox.showerror(title, message)
        
    def show_success(self, title: str, message: str):
        """Show a success message dialog."""
        self.logger.info(f"{title}: {message}")
        messagebox.showinfo(title, message)
        
    def run_with_loading(self, func: Callable, loading_message: str = "Loading..."):
        """Run a function while showing a loading overlay."""
        def wrapper():
            try:
                result = func()
                self.loading.hide()
                return result
            except Exception as e:
                self.loading.hide()
                self.logger.error(f"Error during operation: {str(e)}", exc_info=True)
                self.show_error("Error", str(e))
                
        self.loading.show(loading_message)
        thread = threading.Thread(target=wrapper)
        self.loading.set_active_thread(thread)
        thread.start()
        
    def start_analysis(self):
        """Start the analysis process."""
        self.logger.info("Starting analysis...")
        self.update_status("Analysis in progress...")
        
        def analyze():
            # TODO: Implement actual analysis
            import time
            time.sleep(2)  # Simulate work
            return "Analysis completed successfully!"
            
        def on_complete(result):
            self.update_status("Ready")
            self.show_success("Success", result)
            
        self.run_with_loading(
            analyze,
            "Analyzing files..."
        )

class SettingsDialog(ctk.CTkToplevel):
    """Settings dialog window."""
    
    def __init__(self, parent):
        super().__init__(parent)
        
        self.title("Settings")
        self.geometry("400x500")
        
        self.config = ConfigManager.get_instance()
        self.logger = IntegrityLogger.get_instance()
        
        # Store original values for validation
        self._original_values = {
            "thread_count": self.config.get("analysis.thread_count"),
            "timeout": self.config.get("analysis.timeout")
        }
        
        self._setup_ui()
        
        # Handle window close
        self.protocol("WM_DELETE_WINDOW", self._on_close)
        
    def _validate_numeric(self, value: str, min_val: int, max_val: int) -> bool:
        """Validate numeric input within range."""
        try:
            num = int(value)
            return min_val <= num <= max_val
        except ValueError:
            return False
            
    def _validate_and_save(self) -> bool:
        """Validate all inputs before saving."""
        thread_count = self.thread_var.get()
        timeout = self.timeout_var.get()
        
        if not self._validate_numeric(thread_count, 1, 16):
            self.show_error("Invalid Input", "Thread count must be between 1 and 16")
            return False
            
        if not self._validate_numeric(timeout, 5, 300):
            self.show_error("Invalid Input", "Timeout must be between 5 and 300 seconds")
            return False
            
        # Save validated values
        self.config.set("analysis.thread_count", int(thread_count))
        self.config.set("analysis.timeout", int(timeout))
        return True
        
    def _on_close(self):
        """Handle window close."""
        if self._has_unsaved_changes():
            if messagebox.askyesno(
                "Unsaved Changes",
                "You have unsaved changes. Do you want to save them?"
            ):
                if self._validate_and_save():
                    self.destroy()
            else:
                self.destroy()
        else:
            self.destroy()
            
    def _has_unsaved_changes(self) -> bool:
        """Check if there are unsaved changes."""
        return (
            str(self._original_values["thread_count"]) != self.thread_var.get() or
            str(self._original_values["timeout"]) != self.timeout_var.get()
        )
        
    def show_error(self, title: str, message: str):
        """Show an error message dialog."""
        self.logger.error(f"{title}: {message}")
        messagebox.showerror(title, message)
        
    def _setup_ui(self):
        """Set up the settings dialog UI."""
        # Tabs
        tabview = ctk.CTkTabview(self)
        tabview.pack(fill="both", expand=True, padx=10, pady=10)
        
        # General tab
        general_tab = tabview.add("General")
        
        # Theme selection
        theme_label = ctk.CTkLabel(general_tab, text="Theme:")
        theme_label.pack(pady=5)
        
        theme_var = ctk.StringVar(value=self.config.get("appearance.theme"))
        theme_menu = ctk.CTkOptionMenu(
            general_tab,
            values=["system", "light", "dark"],
            variable=theme_var,
            command=lambda v: self.config.set("appearance.theme", v)
        )
        theme_menu.pack(pady=5)
        
        # Auto-update toggle
        auto_update_var = ctk.BooleanVar(value=self.config.get("general.auto_update"))
        auto_update_cb = ctk.CTkCheckBox(
            general_tab,
            text="Check for updates automatically",
            variable=auto_update_var,
            command=lambda: self.config.set("general.auto_update", auto_update_var.get())
        )
        auto_update_cb.pack(pady=10)
        
        # Save logs toggle
        save_logs_var = ctk.BooleanVar(value=self.config.get("general.save_logs"))
        save_logs_cb = ctk.CTkCheckBox(
            general_tab,
            text="Save logs to file",
            variable=save_logs_var,
            command=lambda: self.config.set("general.save_logs", save_logs_var.get())
        )
        save_logs_cb.pack(pady=10)
        
        # Analysis tab
        analysis_tab = tabview.add("Analysis")
        
        # Thread count
        thread_label = ctk.CTkLabel(analysis_tab, text="Thread count (1-16):")
        thread_label.pack(pady=5)
        
        self.thread_var = ctk.StringVar(value=str(self.config.get("analysis.thread_count")))
        thread_entry = ctk.CTkEntry(
            analysis_tab,
            textvariable=self.thread_var
        )
        thread_entry.pack(pady=5)
        
        # Timeout
        timeout_label = ctk.CTkLabel(analysis_tab, text="Timeout (5-300 seconds):")
        timeout_label.pack(pady=5)
        
        self.timeout_var = ctk.StringVar(value=str(self.config.get("analysis.timeout")))
        timeout_entry = ctk.CTkEntry(
            analysis_tab,
            textvariable=self.timeout_var
        )
        timeout_entry.pack(pady=5)
        
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
        
    def _save_settings(self):
        """Save settings and close dialog."""
        if self._validate_and_save():
            self.destroy()
            messagebox.showinfo(
                "Settings Saved",
                "Settings have been saved successfully.\n"
                "Some changes may require restarting the application."
            )
        
    def _reset_settings(self):
        """Reset all settings to default values."""
        if messagebox.askyesno(
            "Reset Settings",
            "Are you sure you want to reset all settings to default values?"
        ):
            self.config.reset()
            self.destroy()
            messagebox.showinfo(
                "Settings Reset",
                "All settings have been reset to default values.\n"
                "Please restart the application for changes to take effect."
            ) 