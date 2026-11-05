@echo off
echo ========================================================
echo Running Oloz Verification Suite (Analyze + Tests)
echo ========================================================

echo.
echo [1/2] Running Flutter Analyze...
call flutter analyze
if %ERRORLEVEL% NEQ 0 (
    echo [FAIL] Flutter analyze failed with errors.
    exit /b %ERRORLEVEL%
)
echo [PASS] Flutter analyze clean!

echo.
echo [2/2] Running Flutter Tests...
call flutter test
if %ERRORLEVEL% NEQ 0 (
    echo [FAIL] Flutter tests failed.
    exit /b %ERRORLEVEL%
)
echo [PASS] All tests passed!

echo.
echo ========================================================
echo [SUCCESS] Oloz build and verification completed cleanly!
echo ========================================================
