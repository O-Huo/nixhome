"""Use the package's writable plugin copier for the Local Work executor too.

The upstream llm-agents patch fixes marketplace plugin copies, but the executor
uses a separate fs.cp call that preserves read-only Nix store modes. Reuse the
patched helper in the same bundle. Keep byte lengths unchanged for ASAR offsets
and fail the build if an app update changes either relevant code path.
"""

import json
from pathlib import Path
import re
import struct
import sys


def patch(archive: Path) -> None:
    data = archive.read_bytes()
    header_size = struct.unpack_from("<I", data, 4)[0]
    json_size = struct.unpack_from("<I", data, 12)[0]
    header = json.loads(data[16 : 16 + json_size])
    files = header["files"][".vite"]["files"]["build"]["files"]
    candidates = [entry for name, entry in files.items() if name.startswith("main-") and name.endswith(".js")]
    if len(candidates) != 1:
        raise ValueError("Expected exactly one main JavaScript bundle")
    entry = candidates[0]
    start = 8 + header_size + int(entry["offset"])
    end = start + entry["size"]
    source = data[start:end]
    helpers = list(re.finditer(
        rb"async function (?P<name>[\w$]+)\(e,t\)\{let r=[\w$]+\.default\.platform;"
        rb"if\(r===`darwin`\)\{await [\w$]+\(`/usr/bin/ditto`,\[`--noqtn`,e,t\]\);return\}"
        rb"if\(r!==`win32`\)\{await [\w$]+\(`cp`,\[`-r`,e\+`/\.`,t\]\);"
        rb"await [\w$]+\(`chmod`,\[`-R`,`u\+w`,t\]\);return\}", source
    ))
    copies = list(re.finditer(
        rb"await (?P<copy>[\w$]+\.default\.cp\(n\.cwd,e,\{recursive:!0\}\))"
        rb",process\.platform!==`win32`", source
    ))
    if len(helpers) != 1 or len(copies) != 1:
        raise ValueError("Executor copy or writable helper changed; review the patch")
    copy = copies[0]
    replacement = helpers[0]["name"] + b"(n.cwd,e)"
    original = copy["copy"]
    if len(replacement) > len(original):
        raise ValueError("Replacement exceeds ASAR byte budget")
    patched = source[:copy.start("copy")] + replacement.ljust(len(original)) + source[copy.end("copy"):]
    archive.write_bytes(data[:start] + patched + data[end:])


if __name__ == "__main__":
    patch(Path(sys.argv[1]))
