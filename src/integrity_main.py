import sys
import os
import tkinter as tk
from customtkinter import CTk, CTkLabel, CTkButton, CTkEntry
import requests

class IntegrityAssistant:
    def __init__(self):
        self.window = None
        self.setup_ui()
        
    def setup_ui(self):
        self.window = CTk()
        self.window.title("Integrity Assistant")
        self.window.geometry("800x600")
        
        # Welcome label
        welcome = CTkLabel(self.window, text="Welcome to Integrity Assistant")
        welcome.pack(pady=20)
        
        # Version info
        version = CTkLabel(self.window, text=f"Running on Python {sys.version.split()[0]}")
        version.pack(pady=10)
        
        # Start button
        start_btn = CTkButton(self.window, text="Start Analysis", command=self.start_analysis)
        start_btn.pack(pady=20)
    
    def start_analysis(self):
        print("Starting analysis...")
        # Add your analysis code here
    
    def run(self):
        self.window.mainloop()

if __name__ == "__main__":
    app = IntegrityAssistant()
    app.run() 