@echo off
REM Run Flutter app pointing to hosted backend on Hugging Face

set BACKEND=https://chetan2710-local-medicine.hf.space
REM If you also have the AI service hosted, set AI here; otherwise omit this define
set AI=

echo Using BACKEND_BASE_URL=%BACKEND%
if not "%AI%"=="" echo Using AI_BASE_URL=%AI%

echo Starting Flutter...
if "%AI%"=="" (
  flutter run --dart-define=BACKEND_BASE_URL=%BACKEND%
) else (
  flutter run --dart-define=BACKEND_BASE_URL=%BACKEND% --dart-define=AI_BASE_URL=%AI%
)

pause
