@echo off
REM Password Manager Backend - Quick Start Script for Windows

echo 🔐 Password Manager Backend Setup
echo =================================
echo.

REM Check Python version
echo Checking Python version...
python --version

REM Create virtual environment
echo.
echo Creating virtual environment...
python -m venv venv

REM Activate virtual environment
echo.
echo Activating virtual environment...
call venv\Scripts\activate

REM Install dependencies
echo.
echo Installing dependencies...
pip install -r requirements.txt

REM Create .env file if it doesn't exist
if not exist .env (
    echo.
    echo Creating .env file from template...
    copy .env.example .env
    echo ⚠️  Please update .env with your configuration!
)

echo.
echo ✅ Setup complete!
echo.
echo Next steps:
echo 1. Make sure MongoDB is running
echo 2. Update .env with your configuration
echo 3. Run: uvicorn app.main:app --reload
echo.
echo API will be available at: http://localhost:8000
echo Documentation at: http://localhost:8000/docs

pause
