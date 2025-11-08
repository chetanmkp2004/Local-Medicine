@echo off
echo Starting AI Service...
start "AI Service" cmd /k "cd /d %~dp0ai_model && python main.py"

echo Waiting for service to start...
timeout /t 10 /nobreak >nul

echo.
echo Testing AI Service...
cd /d "%~dp0ai_model"
python test_api.py

echo.
echo.
echo Press any key to close the AI service window...
pause >nul
taskkill /fi "WINDOWTITLE eq AI Service*" /f >nul 2>&1
