import sys
import traceback

def main():
    print("Python version:", sys.version)
    print("Python path:", sys.executable)
    print()
    
    try:
        print("Importing required modules...")
        import customtkinter
        print("CustomTkinter version:", customtkinter.__version__)
        
        from src.integrity_main import main as app_main
        print("Modules imported successfully")
        print()
        
        print("Starting application...")
        app_main()
        
    except ImportError as e:
        print("\nError: Failed to import required modules")
        print("Error details:", str(e))
        print("\nTrying to install missing dependencies...")
        
        try:
            import subprocess
            subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"])
            print("\nDependencies installed. Please restart the application.")
        except Exception as install_error:
            print("\nFailed to install dependencies:", str(install_error))
        
    except Exception as e:
        print("\nError: The application encountered an error:")
        print(str(e))
        print("\nFull error details:")
        traceback.print_exc()
    
    print("\nPress Enter to exit...")
    input()

if __name__ == "__main__":
    main() 