import sys
import customtkinter as ctk

def main():
    # Create the main window
    app = ctk.CTk()
    app.title("Test Window")
    app.geometry("300x200")
    
    # Add a label
    label = ctk.CTkLabel(app, text="Test Window")
    label.pack(pady=20)
    
    # Add a button
    button = ctk.CTkButton(app, text="Click Me", command=lambda: print("Button clicked!"))
    button.pack(pady=20)
    
    # Start the application
    app.mainloop()

if __name__ == "__main__":
    print("Python version:", sys.version)
    print("Starting test application...")
    main() 