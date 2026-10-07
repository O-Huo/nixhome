"""Merge Home Manager settings without discarding Codex's mutable state."""

import os
from collections.abc import MutableMapping
from pathlib import Path
import sys
import tempfile

import tomlkit


def merge(current, managed):
    for key, value in managed.items():
        if isinstance(value, MutableMapping) and isinstance(
            current.get(key), MutableMapping
        ):
            merge(current[key], value)
        else:
            current[key] = value


def main():
    source, target = map(Path, sys.argv[1:])
    managed = tomlkit.parse(source.read_text())
    current = tomlkit.parse(target.read_text()) if target.exists() else tomlkit.document()
    merge(current, managed)
    target.parent.mkdir(parents=True, exist_ok=True)
    # Replace the symlink itself, never its read-only Nix store destination.
    # A temporary file also leaves the original intact if parsing/writing fails.
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w", dir=target.parent, prefix=".config.toml-", delete=False
        ) as output:
            temporary = Path(output.name)
            output.write(tomlkit.dumps(current))
        os.replace(temporary, target)
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)


if __name__ == "__main__":
    main()
