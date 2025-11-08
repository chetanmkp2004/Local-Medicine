@echo off
REM Local Medicine App Launcher (Batch version)
REM This script runs Django backend, AI FastAPI service, and Flutter frontend

echo.
echo ========================================
echo   Local Medicine App Launcher
echo ========================================
echo.

REM Get the script directory
cd /d "%~dp0"

REM Basic dependency checks
where python >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python not found in PATH. Install Python or open from a Python-enabled terminal.
    pause
    exit /b 1
)

where flutter >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Flutter not found in PATH. Install Flutter SDK and run 'flutter doctor'.
    pause
    exit /b 1
)

REM Check if backend exists
if not exist "Backend" (
    echo [ERROR] Backend directory not found!
    pause
    exit /b 1
)

echo [1/3] Starting Django Backend Server...
echo       URL: http://localhost:8000
echo.

REM Start Django backend in a new window
start "Django Backend" cmd /k "cd /d Backend && python manage.py runserver 0.0.0.0:8000"

REM Small wait to give the backend time to start
timeout /t 3 /nobreak >nul

REM Start AI service if folder exists
if exist "ai_model" (
    echo [2/3] Starting AI Service ^(FastAPI^)...
    echo       URL: http://localhost:8001
    if exist "ai_model\requirements.txt" (
        echo       [Hint] First time? Install deps: pip install -r ai_model\requirements.txt
    )
    start "AI Service" cmd /k "cd /d ai_model && python -m uvicorn app.api:app --host 0.0.0.0 --port 8001 --reload"
) else (
    echo [2/3] Skipping AI Service ^(ai_model folder not found^)
)

echo [3/3] Starting Flutter App...

REM Prefer Windows desktop if available, otherwise fall back to default device selection
set "FLUTTER_CMD=flutter run"
if exist "windows" (
    set "FLUTTER_CMD=flutter run"
)

echo       Command: %FLUTTER_CMD%
echo.
start "Flutter App" cmd /k "%FLUTTER_CMD%"

echo.
echo ========================================
echo   All processes launched in new terminals
echo ========================================
echo.
echo Backend API:    http://localhost:8000/api/v1/
echo AI Service:     http://localhost:8001/docs ^(FastAPI auto-docs after first run^)
echo API Docs:       http://localhost:8000/api/docs/
echo Admin Panel:    http://localhost:8000/admin/
echo.
echo Test Credentials:
echo   Customer:  customer@test.com / password123
echo   Shop:      shop@test.com / password123
echo   Admin:     admin@test.com / admin123
echo.
echo Close this window at any time. The other terminals will continue running.
echo.
pause
