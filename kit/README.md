# Deployment kit

The files every new project starts with. This folder is the master copy;
AgentSmokeTest was only where it was tested.

| File | What it is |
| :-- | :-- |
| `CLAUDE.md` | The team rules. Goes at the root of every project. |
| `setup.bat` | Windows setup: creates the folders, `.gitignore`, `.claude\settings.json`, and installs embedded Python 3.11.9 into `python\`. |
| `Launch.bat` | Runs the project's `src\main.py` with that Python. |
| `setup.sh` | The Linux/macOS setup, for cloud sessions (no embedded Python). |
| `USING-THE-TEAM.md` | How to set up and talk to the team. |

## New project

1. `git pull` in your local Coconut-Team folder, to get the latest kit.
2. Copy **all the files in this folder** into the new project's folder
   (`setup.bat` takes `CLAUDE.md` and `Launch.bat` from the folder it sits in).
3. Double-click `setup.bat` in the new project and press **Enter** (Enter = this folder).
4. `git add -A`, `git commit -m "Project setup"`, `git push`.

Changing a rule or a script: edit it here, push, and new projects get it.
Existing projects keep their own copy until you copy the new one over.
