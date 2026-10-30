@echo off
title FocusFlow
cd /d "%~dp0"
if not exist node_modules (
    echo Installing FocusFlow for the first time...
    echo This may take a minute.
    npm install
    if errorlevel 1 (
        echo Installation failed. Make sure Node.js is installed.
        pause
        exit /b
    )
    echo Installation complete.
)
start "" npx electron .
exit