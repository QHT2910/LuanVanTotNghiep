#!/usr/bin/env python3
import argparse
import hashlib
import json
from pathlib import Path
import sys
import zipfile

SOURCES = [
    "lib/main.dart",
    "lib/src/simulation/config.dart",
    "lib/src/simulation/practice.dart",
    "lib/src/input/joystick.dart",
    "lib/src/input/jump_button.dart",
    "lib/src/input/dash_button.dart",
    "lib/src/presentation/practice_page.dart",
]
OLD = [
    "lib/config.dart", "lib/practice.dart",
    "lib/joystick.dart", "lib/jump_button.dart",
]
KERNEL = "assets/flutter_assets/kernel_blob.bin"


def digest_file(path):
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--apk",
                        default="build/app/outputs/flutter-apk/app-debug.apk")
    parser.add_argument("--local-kernel", default=None)
    args = parser.parse_args()
    app = Path(__file__).resolve().parents[1]
    apk = Path(args.apk)
    if not apk.is_absolute():
        apk = app / apk
    if not apk.is_file():
        raise RuntimeError("APK missing")
    with zipfile.ZipFile(apk) as archive:
        names = archive.namelist()
        if names.count(KERNEL) != 1:
            raise RuntimeError("Expected one debug kernel")
        kernel = archive.read(KERNEL)
        architectures = sorted({
            n for n in names
            if n.startswith("lib/") and n.endswith("/libflutter.so")
        })
    sources = {}
    for relative in SOURCES:
        file = app / relative
        if not file.is_file():
            raise RuntimeError("Required source missing")
        content = file.read_bytes()
        if not content:
            raise RuntimeError("Empty source")
        sources[relative] = {
            "sha256": hashlib.sha256(content).hexdigest(),
            "bytes": len(content),
            "embeddedInAPKKernel": content in kernel,
        }
    local_matches = None
    if args.local_kernel:
        local = Path(args.local_kernel)
        if not local.is_absolute():
            local = app / local
        if not local.is_file():
            raise RuntimeError("Requested local kernel missing")
        local_matches = digest_file(local) == hashlib.sha256(kernel).hexdigest()
    stale = [p for p in OLD if (app / p).exists()]
    passed = (all(v["embeddedInAPKKernel"] for v in sources.values())
              and not stale
              and local_matches is not False
              and "lib/x86_64/libflutter.so" in architectures)
    print(json.dumps({
        "schema": 1,
        "scope": "current refactored source vs supplied debug APK only",
        "pass": passed,
        "apkSHA256": digest_file(apk),
        "apkBytes": apk.stat().st_size,
        "kernelSHA256": hashlib.sha256(kernel).hexdigest(),
        "kernelBytes": len(kernel),
        "localKernelMatchesAPK": local_matches,
        "sources": sources,
        "staleFlatSources": stale,
        "apkArchitectures": architectures,
        "notProven": [
            "Installed device APK identity",
            "Runtime after refactor",
            "Performance",
        ],
    }, ensure_ascii=False, indent=2))
    return 0 if passed else 1


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as error:
        # Avoid absolute machine/profile paths in public error output.
        print("FAIL: audit could not complete: " + type(error).__name__,
              file=sys.stderr)
        sys.exit(2)
