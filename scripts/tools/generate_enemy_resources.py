#!/usr/bin/env python3
"""
Generate Godot .tres enemy resource files from enemies.json

This script reads resources/data/enemies.json and creates EnemyResource .tres files
in resources/enemies/ directory.

Usage:
    python3 scripts/tools/generate_enemy_resources.py
"""

import json
from pathlib import Path


# Paths
SCRIPT_DIR = Path(__file__).parent
PROJECT_ROOT = SCRIPT_DIR.parent.parent
JSON_PATH = PROJECT_ROOT / "resources/data/enemies.json"
OUTPUT_DIR = PROJECT_ROOT / "resources/enemies"


def hex_to_godot_color(hex_color: str) -> str:
    """
    Convert hex color string to Godot Color format.

    Args:
        hex_color: Hex color like "#ff0000"

    Returns:
        Godot Color string like "Color(1, 0, 0, 1)"
    """
    # Remove # prefix
    hex_color = hex_color.lstrip('#')

    # Convert to RGB values (0-1 range)
    r = int(hex_color[0:2], 16) / 255.0
    g = int(hex_color[2:4], 16) / 255.0
    b = int(hex_color[4:6], 16) / 255.0

    return f"Color({r:.4f}, {g:.4f}, {b:.4f}, 1)"


def create_tres_content(enemy: dict) -> str:
    """
    Create .tres file content for an enemy.

    Args:
        enemy: Dictionary with enemy data from JSON

    Returns:
        String content for .tres file
    """
    color = hex_to_godot_color(enemy['color'])

    return f"""[gd_resource type="EnemyResource" script_class="EnemyResource" load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/resources/enemy_resource.gd" id="1_enemy"]

[resource]
script = ExtResource("1_enemy")
enemy_id = "{enemy['id']}"
enemy_name = "{enemy['name']}"
color = {color}
size = {enemy['size']}
base_hp = {enemy['base_hp']}
base_speed = {enemy['base_speed']}
base_damage = {enemy['base_damage']}
base_value = {enemy['base_value']}
spawn_weight = {enemy['spawn_weight']}
drop_chance = {enemy['drop_chance']}
"""


def main():
    print("=== Enemy Resource Generator ===")
    print()

    # Ensure output directory exists
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    # Read enemies.json
    print(f"Reading: {JSON_PATH}")
    with open(JSON_PATH, 'r') as f:
        enemies = json.load(f)

    print(f"Found {len(enemies)} enemy types")
    print()

    # Generate .tres files
    created_count = 0

    for enemy in enemies:
        enemy_id = enemy['id']
        output_path = OUTPUT_DIR / f"{enemy_id}.tres"

        # Create .tres content
        tres_content = create_tres_content(enemy)

        # Write file
        with open(output_path, 'w') as f:
            f.write(tres_content)

        print(f"✓ Created: {enemy_id}.tres ({enemy['name']}, spawn_weight={enemy['spawn_weight']}%)")
        created_count += 1

    print()
    print("=== Generation Complete ===")
    print(f"Created: {created_count} enemy resources")
    print(f"Output: {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
