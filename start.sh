#!/bin/bash

# --- Parse Configuration ---
# Check if Python is available to parse the JSON
if ! command -v python3 &> /dev/null; then
    echo "Error: Python3 is required to parse settings.json"
    exit 1
fi

# Extract settings from settings.json
REMOTE=$(python3 -c "import sys, json; print(json.load(open('settings.json')).get('remote', ''))")
SERVER_DIR=$(python3 -c "import sys, json; print(json.load(open('settings.json')).get('server_dir', 'server'))")

# Optional fallbacks in case the server pack lacks a start script
SERVER_JAR=$(python3 -c "import sys, json; print(json.load(open('settings.json')).get('server_jar', 'server.jar'))")
JAVA_ARGS=$(python3 -c "import sys, json; print(json.load(open('settings.json')).get('java_args', '-Xms2G -Xmx2G'))")
BRANCH="main"

echo "--- Configuration Loaded ---"
echo "Remote: $REMOTE"
echo "Server Dir: $SERVER_DIR"

# Ensure Git remote is configured correctly
if ! git remote | grep -q "^origin$"; then
    if [ "$REMOTE" != "PUT SHARED REPO LINK WITH FRIENDS HERE" ] && [ -n "$REMOTE" ]; then
        git remote add origin "$REMOTE"
        git branch -M $BRANCH
    else
        echo "Warning: Please set your Git 'remote' URL in settings.json!"
    fi
fi

echo "--- Pulling latest world data from Git ---"
# Only pull if a remote is properly set up
if git remote | grep -q "^origin$"; then
    git pull origin $BRANCH
fi

echo "--- Starting Minecraft Server ---"
# Navigate into the server directory
if [ -d "$SERVER_DIR" ]; then
    cd "$SERVER_DIR" || exit 1
else
    echo "Error: Directory '$SERVER_DIR' does not exist! Check your settings.json."
    exit 1
fi

# Run the server pack's native start script
if [ -f "start.sh" ]; then
    chmod +x start.sh
    ./start.sh
elif [ -f "run.sh" ]; then
    chmod +x run.sh
    ./run.sh
elif [ -f "start.cmd" ]; then
    # Fallback for WSL or mixed environments
    cmd.exe /c start.cmd
else
    echo "No start.sh or start.cmd found in $SERVER_DIR. Using raw Java arguments from settings..."
    java $JAVA_ARGS -jar $SERVER_JAR nogui
fi

# Return to the root of the repository
cd "$(git rev-parse --show-toplevel)"

echo "--- Server stopped. Pushing world data to Git ---"
# Stage everything. Our strict .gitignore will protect binaries, logs, and mods from being tracked
git add .

# Check if there are actually changes to commit
if ! git diff --cached --quiet; then
    git commit -m "Auto-save world: $(date +'%Y-%m-%d %H:%M:%S')"
    if git remote | grep -q "^origin$"; then
        git push -u origin $BRANCH
        echo "--- World data pushed successfully ---"
    else
        echo "--- Changes committed locally, but no remote configured to push to! ---"
    fi
else
    echo "--- No changes to push ---"
fi
