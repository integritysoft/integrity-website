#!/bin/bash

echo "========== INTEGRITY ASSISTANT INSTALLER =========="
echo

# Change to script directory
cd "$(dirname "$0")"

# Check for Python installation
echo "Checking Python installation..."
if ! command -v python3 &> /dev/null; then
    echo "Python 3 not found. Please install Python 3.8 or newer."
    echo "For Ubuntu/Debian: sudo apt-get install python3 python3-venv python3-pip"
    echo "For Fedora: sudo dnf install python3 python3-pip"
    echo "For macOS: brew install python3"
    read -p "Press Enter to continue..."
    exit 1
fi

# Get Python version
PY_VERSION=$(python3 -c "import sys; print('.'.join(map(str, sys.version_info[:3])))")
echo "Detected Python version: $PY_VERSION"

# Check Python version meets minimum requirements
PY_MAJOR=$(echo $PY_VERSION | cut -d. -f1)
PY_MINOR=$(echo $PY_VERSION | cut -d. -f2)

if [ "$PY_MAJOR" -lt 3 ] || ([ "$PY_MAJOR" -eq 3 ] && [ "$PY_MINOR" -lt 8 ]); then
    echo "Python 3.8 or newer is required, but Python $PY_VERSION was found."
    echo "Please install a newer version of Python."
    read -p "Press Enter to continue..."
    exit 1
fi

# Remove existing virtual environment if it's corrupt
if [ -d "venv" ]; then
    echo "Checking if existing virtual environment is valid..."
    if [ ! -f "venv/bin/activate" ]; then
        echo "Existing virtual environment appears corrupt. Removing..."
        rm -rf venv
        echo "Removed corrupted environment."
    else
        echo "Existing virtual environment looks valid."
    fi
fi

# Create virtual environment
echo "Setting up Python virtual environment..."
if [ ! -d "venv" ]; then
    echo "Creating new virtual environment..."
    python3 -m venv venv
    if [ $? -ne 0 ]; then
        echo "Failed to create virtual environment."
        echo "Please check your Python installation."
        read -p "Press Enter to continue..."
        exit 1
    fi
fi

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate
if [ $? -ne 0 ]; then
    echo "Failed to activate virtual environment."
    read -p "Press Enter to continue..."
    exit 1
fi

# Upgrade pip and install build dependencies
echo "Installing build dependencies..."
python -m pip install --upgrade pip setuptools wheel

# Install dependencies from requirements.txt
echo "Installing application dependencies..."
python -m pip install -r requirements.txt

if [ $? -ne 0 ]; then
    echo "Failed to install dependencies."
    echo "Please check your internet connection and try again."
    deactivate
    read -p "Press Enter to continue..."
    exit 1
fi

# Create desktop shortcut (if on Linux)
if [ "$(uname)" = "Linux" ]; then
    echo "Creating desktop shortcut..."
    DESKTOP_FILE="$HOME/Desktop/IntegrityAssistant.desktop"
    cat > "$DESKTOP_FILE" << EOL
[Desktop Entry]
Version=1.0
Name=Integrity Assistant
Comment=Launch Integrity Assistant
Exec=bash -c "cd $(pwd) && ./run_integrity.sh"
Terminal=false
Type=Application
Categories=Utility;
EOL
    chmod +x "$DESKTOP_FILE"
fi

# Make run script executable
chmod +x run_integrity.sh

echo
echo "Installation completed successfully!"
echo "You can now run the application using:"
echo "  ./run_integrity.sh"
if [ "$(uname)" = "Linux" ]; then
    echo "Or use the desktop shortcut."
fi
echo

# Deactivate virtual environment
deactivate

read -p "Press Enter to continue..." 