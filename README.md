# Minecraft Git Sync Wrapper

A Minecraft server wrapper for pulling and pushing a world automatically at the start and stop of the server, making self-hosting with friends not gatekept behind a unique host.

## Prerequisites
* Git installed and configured.
* Java installed (matching your Minecraft server version).
* A Minecraft server `.jar` file (e.g., `server.jar`).

## Initial Setup (First Host)
1. Initialize the repository in your server folder: `git init`
2. Add your remote repository: `git remote add origin <your-repo-url>`
3. Ensure your branch is named `main`: `git branch -M main`
4. Run the server once manually to generate the EULA and world files, and accept the EULA (`eula=true` in `eula.txt`).
5. Add the necessary files: `git add world world_nether world_the_end start.cmd start.sh .gitignore README.md`
6. Commit: `git commit -m "Initial commit"`
7. Push: `git push -u origin main`

## Hosting for Friends
1. Clone the repository: `git clone <your-repo-url> my-mc-server`
2. Navigate to the folder: `cd my-mc-server`
3. Drop your `server.jar` (and `eula.txt`, `server.properties`, mods, etc.) into the folder. (These are ignored by `.gitignore` so they won't be uploaded).
4. Run the server:
   * **Windows:** Double-click `start.cmd`
   * **Linux/macOS:** Run `./start.sh`

The scripts will automatically pull the latest world data, start the server, and push the updated world data when the server is stopped.