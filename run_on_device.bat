@echo off
REM Run Flutter app on physical Android device with network IP configuration
REM This script is for testing on a physical device connected via USB

echo ====================================
echo Flutter App - Physical Device Mode
echo ====================================
echo.

REM Get your PC's local IP automatically
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4 Address" ^| findstr "192.168"') do (
    set IP_ADDRESS=%%a
)

REM Remove leading spaces
set IP_ADDRESS=%IP_ADDRESS: =%

echo Detected IP Address: %IP_ADDRESS%
echo.
echo Starting services...
echo.

REM Start Django Backend
start "Django Backend" cmd /k "cd /d Backend && python manage.py runserver 0.0.0.0:8000"
timeout /t 3 /nobreak >nul

REM Start AI Service
start "AI Service" cmd /k "cd /d ai_model && python main.py"
timeout /t 3 /nobreak >nul

echo.
echo Services started!
echo - Django Backend: http://%IP_ADDRESS%:8000
echo - AI Service: http://%IP_ADDRESS%:8001
echo.
echo Starting Flutter app...
echo.

REM Run Flutter on connected physical device
flutter run --dart-define=BACKEND_BASE_URL=http://%IP_ADDRESS%:8000 --dart-define=AI_BASE_URL=http://%IP_ADDRESS%:8001

pause
