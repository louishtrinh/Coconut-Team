# Deployment Package

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

1. `git pull` in your local Coconut-Team folder, to get the latest package.
2. Copy this whole **`Deployment Package`** folder into the new project's folder.
3. Double-click `Deployment Package\setup.bat` and press **Enter**
   (Enter = the project folder the package sits in). It copies `CLAUDE.md` and
   `Launch.bat` up to the project, creates the folders, and installs Python.
4. `git add -A`, `git commit -m "Project setup"`, `git push`.

The package stays in the project, so `setup.bat` can be re-run on another PC.

Changing a rule or a script: edit it here, push, and new projects get it.
Existing projects keep their own copy until you copy the new one over.
