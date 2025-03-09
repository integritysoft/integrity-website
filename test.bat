@echo on
echo Testing CustomTkinter installation...

:: Activate virtual environment
call venv\Scripts\activate

:: Run test script
python test.py

pause 