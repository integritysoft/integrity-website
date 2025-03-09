import os
import sys
import json
import traceback
import customtkinter as ctk
from integrity_logger import IntegrityLogger
from integrity_config import ConfigManager

class IntegrityAssistant:
    def __init__(self):
        self.logger = IntegrityLogger.get_logger()
        self.config = ConfigManager.get_instance()
        
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
            import tkinter as tk
            from tkinter import messagebox
            root = tk.Tk()
            root.withdraw()
            messagebox.showerror("Error", error_msg)
            root.destroy()
        except:
            self.logger.error("Failed to show error dialog", exc_info=True)
            print(error_msg)
    
    def setup_ui(self):
        """Set up the application UI"""
        try:
            # Set appearance mode from config
            ctk.set_appearance_mode(self.config.get("theme", "dark"))
            ctk.set_default_color_theme("blue")
            
            # Create main window
            self.window = ctk.CTk()
            self.window.title("Integrity Assistant")
            self.window.geometry("1024x768")
            self.window.minsize(800, 600)
            
            # Configure grid
            self.window.grid_columnconfigure(0, weight=1)
            self.window.grid_rowconfigure(1, weight=1)
            
            # Create header
            header = ctk.CTkLabel(
                self.window,
                text="Integrity Assistant",
                font=("Helvetica", 24, "bold")
            )
            header.grid(row=0, column=0, pady=20)
            
            # Create main content area
            content = ctk.CTkFrame(self.window)
            content.grid(row=1, column=0, padx=20, pady=10, sticky="nsew")
            
            # Add buttons
            btn_frame = ctk.CTkFrame(content)
            btn_frame.pack(pady=20)
            
            analyze_btn = ctk.CTkButton(
                btn_frame,
                text="Start Analysis",
                command=self.start_analysis
            )
            analyze_btn.pack(side="left", padx=10)
            
            settings_btn = ctk.CTkButton(
                btn_frame,
                text="Settings",
                command=self.open_settings
            )
            settings_btn.pack(side="left", padx=10)
            
            # Status bar
            self.status = ctk.CTkLabel(
                self.window,
                text="Ready",
                anchor="w"
            )
            self.status.grid(row=2, column=0, padx=20, pady=10, sticky="ew")
            
            self.logger.info("UI initialized successfully")
            
        except Exception as e:
            self.logger.error("Failed to initialize UI", exc_info=True)
            raise
    
    def start_analysis(self):
        """Start the analysis process"""
        try:
            self.status.configure(text="Analysis in progress...")
            self.window.update()
            
            # TODO: Add your analysis code here
            # For now, just show a success message
            self.show_message("Analysis completed successfully!", "success")
            
        except Exception as e:
            self.logger.error("Analysis failed", exc_info=True)
            self.show_message(f"Analysis failed: {str(e)}", "error")
        finally:
            self.status.configure(text="Ready")
    
    def open_settings(self):
        """Open settings dialog"""
        try:
            dialog = ctk.CTkToplevel(self.window)
            dialog.title("Settings")
            dialog.geometry("400x300")
            dialog.transient(self.window)
            dialog.grab_set()
            
            # Add theme selection
            theme_label = ctk.CTkLabel(dialog, text="Theme:")
            theme_label.pack(pady=10)
            
            theme_var = ctk.StringVar(value=self.config.get("theme", "dark"))
            theme_menu = ctk.CTkOptionMenu(
                dialog,
                values=["dark", "light"],
                variable=theme_var,
                command=lambda t: self.change_theme(t)
            )
            theme_menu.pack(pady=5)
            
        except Exception as e:
            self.logger.error("Failed to open settings", exc_info=True)
            self.show_message(f"Failed to open settings: {str(e)}", "error")
    
    def change_theme(self, theme: str):
        """Change the application theme"""
        try:
            self.config.set("theme", theme)
            ctk.set_appearance_mode(theme)
        except Exception as e:
            self.logger.error(f"Failed to change theme: {e}")
            self.show_message(f"Failed to change theme: {str(e)}", "error")
    
    def show_message(self, message: str, type_: str = "info"):
        """Show a message dialog"""
        try:
            if type_ == "error":
                self.logger.error(message)
                icon = "cancel"
            elif type_ == "success":
                self.logger.info(message)
                icon = "check"
            else:
                self.logger.info(message)
                icon = "info"
            
            ctk.CTkMessagebox(
                title=type_.capitalize(),
                message=message,
                icon=icon
            )
        except Exception as e:
            self.logger.error(f"Failed to show message: {e}")
            print(f"{type_.upper()}: {message}")
    
    def run(self):
        """Run the main application"""
        try:
            self.window.mainloop()
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