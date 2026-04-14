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
for /f "delims=" %%i in ('python -c "import sys, json; print(json.load(open('settings.json')).get('server_dir', 'server'))"') do set SERVER_DIR=%%i
for /f "delims=" %%i in ('python -c "import sys, json; print(json.load(open('settings.json')).get('server_jar', 'server.jar'))"') do set SERVER_JAR=%%i
for /f "delims=" %%i in ('python -c "import sys, json; print(json.load(open('settings.json')).get('java_args', '-Xms2G -Xmx2G'))"') do set JAVA_ARGS=%%i
set BRANCH=main

echo --- Configuration Loaded ---
echo Server Dir: %SERVER_DIR%

echo --- Pulling latest world data from Git ---
git pull origin %BRANCH%

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
    call start.cmd || java %JAVA_ARGS% -jar "%SERVER_JAR%" nogui
) else if exist "run.cmd" (
    call run.cmd || java %JAVA_ARGS% -jar "%SERVER_JAR%" nogui
) else if exist "start.bat" (
    call start.bat || java %JAVA_ARGS% -jar "%SERVER_JAR%" nogui
) else if exist "run.bat" (
    call run.bat || java %JAVA_ARGS% -jar "%SERVER_JAR%" nogui
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
    git push origin %BRANCH%
    echo --- World data pushed successfully ---
) else (
    echo --- No changes to push ---
)
pause
