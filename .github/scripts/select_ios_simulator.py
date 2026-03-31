#!/usr/bin/env python3

import argparse
import json
import re
import subprocess
from typing import TypedDict


class Simulator(TypedDict):
    major: int
    minor: int
    name: str
    udid: str


runtime_pattern = re.compile(r"iOS-(\d+)-(\d+)$")
preferred_names = [
    "iPhone 17 Pro",
    "iPhone 17",
    "iPhone 17 Pro Max",
    "iPhone 17e",
    "iPhone Air",
    "iPhone 16 Pro",
    "iPhone 16",
]


def choose_simulator() -> Simulator:
    raw = subprocess.check_output(
        ["xcrun", "simctl", "list", "devices", "available", "-j"],
        text=True,
    )
    devices_by_runtime = json.loads(raw)["devices"]

    candidates: list[Simulator] = []
    for runtime, devices in devices_by_runtime.items():
        match = runtime_pattern.search(runtime)
        if not match:
            continue

        major, minor = (int(part) for part in match.groups())
        for device in devices:
            name = device["name"]
            if not device.get("isAvailable") or not name.startswith("iPhone"):
                continue
            candidates.append(
                {
                    "major": major,
                    "minor": minor,
                    "name": name,
                    "udid": device["udid"],
                }
            )

    if not candidates:
        raise SystemExit("No available iPhone simulator destinations found.")

    latest_runtime = max((candidate["major"], candidate["minor"]) for candidate in candidates)
    latest_candidates = [
        candidate
        for candidate in candidates
        if (candidate["major"], candidate["minor"]) == latest_runtime
    ]

    for preferred_name in preferred_names:
        for candidate in latest_candidates:
            if candidate["name"] == preferred_name:
                return candidate

    return sorted(latest_candidates, key=lambda candidate: candidate["name"])[0]


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--field",
        choices=["destination", "udid"],
        default="destination",
        help="Which selected simulator field to print.",
    )
    args = parser.parse_args()

    chosen = choose_simulator()
    destination = (
        f"platform=iOS Simulator,OS={chosen['major']}.{chosen['minor']},name={chosen['name']}"
    )

    if args.field == "udid":
        print(chosen["udid"])
        return

    print(destination)


if __name__ == "__main__":
    main()
