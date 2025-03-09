#!/bin/bash

# Change to script directory
cd "$(dirname "$0")"

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "Virtual environment not found"
    echo "Please run install.sh first"
    read -p "Press Enter to continue..."
    exit 1
fi

# Activate virtual environment
source venv/bin/activate
if [ $? -ne 0 ]; then
    echo "Failed to activate virtual environment"
    echo "Please run install.sh to repair the installation"
    read -p "Press Enter to continue..."
    exit 1
fi

# Run the application
python src/integrity_main.py

# Deactivate virtual environment
deactivate

# If we get here with an error, show it
if [ $? -ne 0 ]; then
    echo
    echo "Application exited with an error"
    echo "Please check the logs in: $HOME/IntegrityAssistant/logs"
    read -p "Press Enter to continue..."
fi 