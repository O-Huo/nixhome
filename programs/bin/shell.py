import argparse
import subprocess
import sys
import os
from pathlib import Path
from git import Repo, InvalidGitRepositoryError

PATH = os.environ.get("NIXHOME_PATH", "")


def run(cmd: list[str]) -> None:
    returncode = subprocess.run(cmd).returncode
    if returncode != 0:
        sys.exit(returncode)


def main() -> None:
    description = "create gitignored direnv config"
    parser = argparse.ArgumentParser(description=description)
    parser.add_argument("name")
    args = parser.parse_args()

    Path(".envrc").write_text(f"use flake {PATH}#{args.name}\n")
    run(["direnv", "allow"])

    try:
        repo = Repo(Path.cwd(), search_parent_directories=True)
    except InvalidGitRepositoryError:
        git_info_exclude = []
        return
    git_info_exclude_path = Path(repo.git_dir + "/info/exclude")
    git_info_exclude_path.parent.mkdir(parents=True, exist_ok=True)
    try:
        git_info_exclude = git_info_exclude_path.read_text().splitlines()
    except FileNotFoundError:
        git_info_exclude = []
    for line in ["/.direnv/", "/.envrc"]:
        if line not in git_info_exclude:
            git_info_exclude.append(line)
    git_info_exclude_path.write_text("\n".join(git_info_exclude + [""]))


if __name__ == "__main__":
    main()
