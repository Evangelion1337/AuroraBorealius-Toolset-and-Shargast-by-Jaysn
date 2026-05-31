@echo off
REM Aurora Borealis Toolset — Windows Launcher (Batch)
REM Calls the PowerShell wrapper. Simpler for double-click use.

powershell.exe -ExecutionPolicy Bypass -File "%~dp0run_windows.ps1" %*
if %ERRORLEVEL% neq 0 (
    echo.
    echo If PowerShell fails, ensure execution policy allows scripts:
    echo   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
    pause
)
