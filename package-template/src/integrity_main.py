# This is a placeholder for your main Python script
# Replace this with your actual code

import os
import sys
import json
import requests
import customtkinter as ctk
import numpy as np
import cv2
from supabase import create_client, Client

class IntegrityAssistant:
    def __init__(self):
        self.load_config()
        self.setup_ui()
        
    def load_config(self):
        """Load Supabase configuration"""
        config_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "config")
        config_file = os.path.join(config_dir, "supabase_config.json")
        
        if not os.path.exists(config_file):
            self.show_login_dialog()
        else:
            try:
                with open(config_file, 'r') as f:
                    config = json.load(f)
                self.supabase = create_client(config['url'], config['key'])
                # Verify connection
                self.supabase.auth.get_user()
            except Exception as e:
                print(f"Error loading configuration: {e}")
                self.show_login_dialog()

    def show_login_dialog(self):
        """Show login dialog to get Supabase credentials"""
        self.login_window = ctk.CTk()
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
        
        def login():
            try:
                response = requests.post(
                    "https://integrity-website.vercel.app/api/login",
                    json={
                        "email": email_var.get(),
                        "password": password_var.get()
                    }
                )
                if response.status_code == 200:
                    data = response.json()
                    config_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "config")
                    os.makedirs(config_dir, exist_ok=True)
                    
                    with open(os.path.join(config_dir, "supabase_config.json"), 'w') as f:
                        json.dump({
                            'url': data['supabase_url'],
                            'key': data['supabase_key']
                        }, f)
                    
                    self.supabase = create_client(data['supabase_url'], data['supabase_key'])
                    self.login_window.destroy()
                else:
                    ctk.CTkLabel(self.login_window, text="Login failed. Please try again.", text_color="red").pack()
            except Exception as e:
                ctk.CTkLabel(self.login_window, text=f"Error: {str(e)}", text_color="red").pack()
        
        ctk.CTkButton(self.login_window, text="Login", command=login).pack(pady=20)
        
        signup_label = ctk.CTkLabel(
            self.login_window, 
            text="Don't have an account? Sign up here",
            cursor="hand2"
        )
        signup_label.pack(pady=10)
        signup_label.bind("<Button-1>", lambda e: self.open_signup_page())
        
        self.login_window.mainloop()

    def open_signup_page(self):
        """Open the signup page in the default browser"""
        import webbrowser
        webbrowser.open("https://integrity-website.vercel.app/signup")

    def setup_ui(self):
        """Set up the main application UI"""
        self.window = ctk.CTk()
        self.window.title("Integrity Assistant")
        self.window.geometry("800x600")
        
        # Add your UI components here
        self.label = ctk.CTkLabel(self.window, text="Integrity Assistant")
        self.label.pack(pady=20)
        
        self.start_button = ctk.CTkButton(self.window, text="Start Analysis", command=self.start_analysis)
        self.start_button.pack(pady=10)

    def start_analysis(self):
        """Start the analysis process"""
        try:
            # Verify user session is still valid
            user = self.supabase.auth.get_user()
            # Add your analysis code here
            pass
        except Exception as e:
            print(f"Error during analysis: {e}")
            self.show_login_dialog()

    def run(self):
        """Run the main application"""
        self.window.mainloop()

if __name__ == "__main__":
    app = IntegrityAssistant()
    app.run()
