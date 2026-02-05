@echo off
echo ===================================================
echo   Common Grounds - One-Click Launcher
echo ===================================================
echo.

echo [1/3] Checking for active emulator...
flutter devices | findstr "emulator-5554" > nul
if %errorlevel% neq 0 (
    echo Emulator-5554 not found. Checking for any emulator...
    flutter devices | findstr "emulator" > nul
    if %errorlevel% neq 0 (
        echo No emulator found. Launching Trae_Phone_Stable...
        call flutter emulators --launch Trae_Phone_Stable
        echo Waiting for emulator to boot...
        timeout /t 15
    ) else (
        echo Found another emulator.
    )
) else (
    echo Emulator-5554 is ready!
)

echo.
echo [2/3] Cleaning up...
call flutter clean > nul
call flutter pub get > nul

echo.
echo [3/3] Running App...
echo Note: Using --no-enable-impeller to fix graphics glitches.
echo.

:: Try running on emulator-5554 specifically to avoid "multiple devices" prompt
call flutter run -d emulator-5554 --no-enable-impeller

if %errorlevel% neq 0 (
    echo.
    echo Failed to run on emulator-5554. Trying generic run...
    call flutter run --no-enable-impeller
)

pause
