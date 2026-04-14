# Minecraft Git Sync Wrapper

A Minecraft server wrapper for pulling and pushing a world automatically at the start and stop of the server, making self-hosting with friends not gatekept behind a unique host.

## Prerequisites
* Git installed and configured.
* Java installed (matching your Minecraft server version).
* A Minecraft server `.jar` file (e.g., `server.jar`).

## Initial Setup (First Host)
1. Initialize the repository in your server folder: `git clone git@github.com:jojo2504/git-mc.git`
2. Add your remote repository: `git remote set-url origin <your-repo-url>`
3. Put your server files in `git-mc/server/`, (i.e. `git-mc/server/myserver`)
4. Run the server once manually to generate the EULA and world files, and accept the EULA (`eula=true` in `eula.txt`).
6. Commit: `git commit -m "Initial commit"`
7. Push: `git push -u origin main`

## For future friends who wants to host after you
1. Clone your private shared repository: `git clone <your-repo-url>`
2. Run the server

## Run the server:
* **Windows:** Double-click `start.cmd`
* **Linux/macOS:** Run `./start.sh`

The scripts will automatically pull the latest world data, start the server, and push the updated world data when the server is stopped.
