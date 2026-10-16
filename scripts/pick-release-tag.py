#!/usr/bin/env python3
"""Pick the highest stable SemVer release tag from a GitHub releases JSON array on stdin."""
import json
import re
import sys

SEMVER = re.compile(r"^v?(?P<major>[0-9]+)\.(?P<minor>[0-9]+)\.(?P<patch>[0-9]+)$")


def main() -> int:
    releases = json.load(sys.stdin)
    best = None
    for release in releases:
        if release.get("draft") or release.get("prerelease"):
            continue
        tag = str(release.get("tag_name", "")).strip()
        match = SEMVER.match(tag)
        if not match:
            continue
        key = (int(match.group("major")), int(match.group("minor")), int(match.group("patch")))
        if best is None or key > best[0]:
            best = (key, tag)
    if best is None:
        print("no valid release tag found", file=sys.stderr)
        return 1
    print(best[1])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
