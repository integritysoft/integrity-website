import sys
import traceback
from src.integrity_main import main

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print("\nError: The application encountered an error:")
        print(str(e))
        print("\nFull error details:")
        traceback.print_exc()
        print("\nPress Enter to exit...")
        input()  # Keep the terminal open 