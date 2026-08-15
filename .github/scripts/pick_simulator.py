"""Pick an available iPhone simulator (iOS 17+) to run the app on in CI."""
import json
import re
import subprocess
import sys


def runtime_version(runtime_id):
    match = re.search(r"iOS-(\d+)-(\d+)", runtime_id)
    if not match:
        return None
    return (int(match.group(1)), int(match.group(2)))


def main():
    output = subprocess.check_output(["xcrun", "simctl", "list", "devices", "available", "-j"])
    data = json.loads(output)

    best = None
    for runtime_id, devices in data["devices"].items():
        version = runtime_version(runtime_id)
        if version is None or version < (17, 0):
            continue
        for device in devices:
            if device.get("isAvailable") and device.get("name", "").startswith("iPhone"):
                if best is None or version > best[0]:
                    best = (version, device["udid"])

    if best is None:
        sys.exit("No available iPhone simulator with iOS 17+ found")

    print(best[1])


if __name__ == "__main__":
    main()
