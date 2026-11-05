@echo off
echo ========================================================
echo Running Oloz Verification Suite (Analyze + Tests)
echo ========================================================

set FLUTTER_BIN=flutter
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    if exist "D:\flutter\bin\flutter.bat" (
        set FLUTTER_BIN=D:\flutter\bin\flutter.bat
    )
)

echo.
echo [1/2] Running Flutter Analyze...
call %FLUTTER_BIN% analyze
if %ERRORLEVEL% NEQ 0 (
    echo [FAIL] Flutter analyze failed with errors.
    exit /b %ERRORLEVEL%
)
echo [PASS] Flutter analyze clean!

echo.
echo [2/2] Running Flutter Tests...
call %FLUTTER_BIN% test
if %ERRORLEVEL% NEQ 0 (
    echo [FAIL] Flutter tests failed.
    exit /b %ERRORLEVEL%
)
echo [PASS] All tests passed!

echo.
echo ========================================================
echo [SUCCESS] Oloz build and verification completed cleanly!
echo ========================================================
