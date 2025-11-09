#!/usr/bin/env python3
"""
Generate Godot .tres item resource files from items.json

This script reads resources/data/items.json and creates ItemResource .tres files
in resources/items/ directory. Handles both upgrades/consumables (with stat_modifiers)
and craftable weapons (with weapon-specific properties).

Usage:
    python3 scripts/tools/generate_item_resources.py
"""

import json
from pathlib import Path


# Paths
SCRIPT_DIR = Path(__file__).parent
PROJECT_ROOT = SCRIPT_DIR.parent.parent
JSON_PATH = PROJECT_ROOT / "resources/data/items.json"
OUTPUT_DIR = PROJECT_ROOT / "resources/items"


def format_dictionary(stats: dict) -> str:
    """
    Format a Python dictionary as a Godot Dictionary string.
    
    Args:
        stats: Dictionary with stat modifiers
    
    Returns:
        Godot Dictionary format string like {"maxHp": 20, "damage": 5}
    """
    if not stats:
        return "{}"
    
    # Format each key-value pair
    pairs = []
    for key, value in stats.items():
        # Use quotes for string keys, preserve numeric values
        pairs.append(f'"{key}": {value}')
    
    return "{" + ", ".join(pairs) + "}"


def create_tres_content(item: dict) -> str:
    """
    Create .tres file content for an item.
    
    Handles both upgrade/consumable items and craftable weapons.
    
    Args:
        item: Dictionary with item data from JSON
    
    Returns:
        String content for .tres file
    """
    # Format stat_modifiers as Godot Dictionary
    stat_modifiers = format_dictionary(item.get('stats', {}))
    
    # Base resource content
    content = f"""[gd_resource type="ItemResource" script_class="ItemResource" load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/resources/item_resource.gd" id="1_item"]

[resource]
script = ExtResource("1_item")
item_id = "{item['id']}"
item_name = "{item['name']}"
description = "{item['description']}"
item_type = "{item['type']}"
rarity = "{item['rarity']}"
stat_modifiers = {stat_modifiers}
"""
    
    # Add weapon-specific properties if this is a weapon
    if item['type'] == 'weapon':
        content += f"""base_damage = {item['base_damage']}
damage_type = "{item['damage_type']}"
fire_rate = {item['fire_rate']}
projectile_speed = {item['projectile_speed']}
base_range = {item['base_range']}
max_durability = {item['max_durability']}
max_fuse_tier = {item['max_fuse_tier']}
base_value = {item['base_value']}
"""
    
    return content


def main():
    print("=== Item Resource Generator ===")
    print()
    
    # Ensure output directory exists
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    # Read items.json
    print(f"Reading: {JSON_PATH}")
    with open(JSON_PATH, 'r') as f:
        items = json.load(f)
    
    print(f"Found {len(items)} items")
    print()
    
    # Count by type
    upgrades = [i for i in items if i['type'] == 'upgrade']
    consumables = [i for i in items if i['type'] == 'item']
    weapons = [i for i in items if i['type'] == 'weapon']
    
    print(f"  Upgrades: {len(upgrades)}")
    print(f"  Consumables: {len(consumables)}")
    print(f"  Weapons: {len(weapons)}")
    print()
    
    # Generate .tres files
    created_count = 0
    
    for item in items:
        item_id = item['id']
        output_path = OUTPUT_DIR / f"{item_id}.tres"
        
        # Create .tres content
        tres_content = create_tres_content(item)
        
        # Write file
        with open(output_path, 'w') as f:
            f.write(tres_content)
        
        # Display progress with relevant info
        item_type = item['type']
        rarity = item['rarity']
        
        if item_type == 'weapon':
            print(f"✓ Created: {item_id}.tres ({item['name']}, {rarity} weapon, dmg={item['base_damage']})")
        else:
            stats = item.get('stats', {})
            stat_summary = ", ".join([f"{k}={v}" for k, v in list(stats.items())[:2]])
            if len(stats) > 2:
                stat_summary += "..."
            print(f"✓ Created: {item_id}.tres ({item['name']}, {rarity} {item_type}, {stat_summary})")
        
        created_count += 1
    
    print()
    print("=== Generation Complete ===")
    print(f"Created: {created_count} item resources")
    print(f"  Upgrades: {len(upgrades)}")
    print(f"  Consumables: {len(consumables)}")
    print(f"  Weapons: {len(weapons)}")
    print(f"Output: {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
