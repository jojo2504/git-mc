@echo off
setlocal enabledelayedexpansion

:: Store the root directory
set "ROOT_DIR=%~dp0"

:: --- Parse Configuration ---
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Python is required to parse settings.json
    pause
    exit /b 1
)

:: Extract settings from settings.json
for /f "delims=" %%i in ('python -c "import sys, json; print(json.load(open('settings.json')).get('remote', ''))"') do set REMOTE=%%i
for /f "delims=" %%i in ('python -c "import sys, json; print(json.load(open('settings.json')).get('server_dir', 'server'))"') do set SERVER_DIR=%%i
for /f "delims=" %%i in ('python -c "import sys, json; print(json.load(open('settings.json')).get('server_jar', 'server.jar'))"') do set SERVER_JAR=%%i
for /f "delims=" %%i in ('python -c "import sys, json; print(json.load(open('settings.json')).get('java_args', '-Xms2G -Xmx2G'))"') do set JAVA_ARGS=%%i
set BRANCH=main

echo --- Configuration Loaded ---
echo Remote: %REMOTE%
echo Server Dir: %SERVER_DIR%

:: Ensure Git remote is configured correctly
git remote | findstr /x "origin" >nul
if %errorlevel% neq 0 (
    if "%REMOTE%" neq "PUT SHARED REPO LINK WITH FRIENDS HERE" (
        if "%REMOTE%" neq "" (
            git remote add origin "%REMOTE%"
            git branch -M %BRANCH%
        )
    ) else (
        echo Warning: Please set your Git 'remote' URL in settings.json!
    )
)

echo --- Pulling latest world data from Git ---
git remote | findstr /x "origin" >nul
if %errorlevel% equ 0 (
    git pull origin %BRANCH%
)

echo --- Starting Minecraft Server ---
if exist "%ROOT_DIR%%SERVER_DIR%\" (
    cd /d "%ROOT_DIR%%SERVER_DIR%"
) else if exist "%SERVER_DIR%\" (
    cd "%SERVER_DIR%"
) else (
    echo Error: Directory '%SERVER_DIR%' does not exist! Check your settings.json.
    pause
    exit /b 1
)

:: Run the server pack's native start script
if exist "start.cmd" (
    call start.cmd
) else if exist "run.cmd" (
    call run.cmd
) else if exist "start.bat" (
    call start.bat
) else if exist "run.bat" (
    call run.bat
) else (
    echo No launcher script found in %SERVER_DIR%. Using raw Java arguments from settings...
    java %JAVA_ARGS% -jar "%SERVER_JAR%" nogui
)

:: Return to the root of the repository
cd /d "%ROOT_DIR%"

echo --- Server stopped. Pushing world data to Git ---
:: Stage everything. Our strict .gitignore will protect binaries, logs, and mods from being tracked
git add .

:: Check if there are actually changes to commit
git diff --cached --quiet
if %errorlevel% neq 0 (
    git commit -m "Auto-save world: %date% %time%"
    git remote | findstr /x "origin" >nul
    if !errorlevel! equ 0 (
        git push -u origin %BRANCH%
        echo --- World data pushed successfully ---
    ) else (
        echo --- Changes committed locally, but no remote configured to push to! ---
    )
) else (
    echo --- No changes to push ---
)
pause
