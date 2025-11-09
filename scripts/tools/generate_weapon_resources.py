#!/usr/bin/env python3
"""
Generate Godot .tres weapon resource files from weapons.json

This script reads resources/data/weapons.json and creates WeaponResource .tres files
in resources/weapons/ directory. The .tres format is Godot's text-based resource format.

Usage:
    python3 scripts/tools/generate_weapon_resources.py
"""

import json
import os
from pathlib import Path


# Paths
SCRIPT_DIR = Path(__file__).parent
PROJECT_ROOT = SCRIPT_DIR.parent.parent
JSON_PATH = PROJECT_ROOT / "resources/data/weapons.json"
OUTPUT_DIR = PROJECT_ROOT / "resources/weapons"


def create_tres_content(weapon: dict) -> str:
    """
    Create .tres file content for a weapon.

    Format follows Godot's text resource format:
    [gd_resource type="WeaponResource" ...]

    Args:
        weapon: Dictionary with weapon data from JSON

    Returns:
        String content for .tres file
    """
    return f"""[gd_resource type="WeaponResource" script_class="WeaponResource" load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/resources/weapon_resource.gd" id="1_weapon"]

[resource]
script = ExtResource("1_weapon")
weapon_id = "{weapon['id']}"
weapon_name = "{weapon['name']}"
damage = {weapon['damage']}
fire_rate = {weapon['fire_rate']}
projectile_speed = {weapon['projectile_speed']}
weapon_range = {weapon['range']}
is_premium = {str(weapon['is_premium']).lower()}
rarity = "{weapon['rarity']}"
sprite = "{weapon['sprite']}"
"""


def main():
    print("=== Weapon Resource Generator ===")
    print()

    # Ensure output directory exists
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    # Read weapons.json
    print(f"Reading: {JSON_PATH}")
    with open(JSON_PATH, 'r') as f:
        weapons = json.load(f)

    print(f"Found {len(weapons)} weapons")
    print()

    # Generate .tres files
    created_count = 0

    for weapon in weapons:
        weapon_id = weapon['id']
        output_path = OUTPUT_DIR / f"{weapon_id}.tres"

        # Create .tres content
        tres_content = create_tres_content(weapon)

        # Write file
        with open(output_path, 'w') as f:
            f.write(tres_content)

        print(f"✓ Created: {weapon_id}.tres ({weapon['name']}, damage={weapon['damage']})")
        created_count += 1

    print()
    print("=== Generation Complete ===")
    print(f"Created: {created_count} weapon resources")
    print(f"Output: {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
