import customtkinter as ctk
from typing import Callable

class LoginWindow:
    def __init__(self, on_login: Callable):
        self.window = ctk.CTkToplevel()
        self.window.title("Login")
        self.window.geometry("400x300")
        self.on_login = on_login
        
        # Email field
        self.email_label = ctk.CTkLabel(self.window, text="Email:")
        self.email_label.pack(pady=10)
        self.email_entry = ctk.CTkEntry(self.window, width=200)
        self.email_entry.pack()
        
        # Password field
        self.password_label = ctk.CTkLabel(self.window, text="Password:")
        self.password_label.pack(pady=10)
        self.password_entry = ctk.CTkEntry(self.window, show="*", width=200)
        self.password_entry.pack()
        
        # Login button
        self.login_btn = ctk.CTkButton(self.window, text="Login", command=self._handle_login)
        self.login_btn.pack(pady=20)
        
        # Error label
        self.error_label = ctk.CTkLabel(self.window, text="", text_color="red")
        self.error_label.pack(pady=10)
    
    def _handle_login(self):
        email = self.email_entry.get()
        password = self.password_entry.get()
        self.on_login(email, password)
    
    def show_error(self, message: str):
        self.error_label.configure(text=message)
    
    def close(self):
        self.window.destroy() 