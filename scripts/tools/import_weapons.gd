@tool
extends EditorScript
## Batch import weapons from weapons.json to .tres files
##
## This tool reads resources/data/weapons.json and creates WeaponResource .tres files
## in resources/weapons/ directory.
##
## Usage:
## 1. Open this script in Godot editor
## 2. Click File > Run (or press Ctrl+Shift+X / Cmd+Shift+X)
## 3. Check console output for results
## 4. Verify .tres files in resources/weapons/

const JSON_PATH = "res://resources/data/weapons.json"
const OUTPUT_DIR = "res://resources/weapons/"


func _run() -> void:
	print("=== Weapon Import Tool ===")
	print("")

	# Read JSON file
	var json_file = FileAccess.open(JSON_PATH, FileAccess.READ)
	if json_file == null:
		push_error("Failed to open %s" % JSON_PATH)
		return

	var json_content = json_file.get_as_text()
	json_file.close()

	# Parse JSON
	var json = JSON.new()
	var parse_result = json.parse(json_content)
	if parse_result != OK:
		push_error("Failed to parse JSON: %s" % json.get_error_message())
		return

	var weapons_data = json.get_data()
	if not weapons_data is Array:
		push_error("JSON root is not an array")
		return

	print("Found %d weapons in JSON" % weapons_data.size())
	print("")

	# Create resources
	var created_count = 0
	var skipped_count = 0

	for weapon_data in weapons_data:
		var result = _create_weapon_resource(weapon_data)
		if result:
			created_count += 1
		else:
			skipped_count += 1

	print("")
	print("=== Import Complete ===")
	print("Created: %d weapons" % created_count)
	print("Skipped: %d weapons" % skipped_count)
	print("Output: %s" % OUTPUT_DIR)


func _create_weapon_resource(data: Dictionary) -> bool:
	var weapon_id = data.get("id", "")
	if weapon_id.is_empty():
		push_warning("Skipping weapon with no ID")
		return false

	# Create resource
	var weapon = WeaponResource.new()

	# Set properties from JSON
	weapon.weapon_id = data.get("id", "")
	weapon.weapon_name = data.get("name", "")
	weapon.damage = data.get("damage", 10)
	weapon.fire_rate = data.get("fire_rate", 1.0)
	weapon.projectile_speed = data.get("projectile_speed", 400)
	weapon.weapon_range = data.get("range", 300)
	weapon.is_premium = data.get("is_premium", false)
	weapon.rarity = data.get("rarity", "common")
	weapon.sprite = data.get("sprite", weapon_id)

	# Save as .tres file
	var output_path = OUTPUT_DIR + weapon_id + ".tres"
	var save_error = ResourceSaver.save(weapon, output_path)

	if save_error != OK:
		push_error("Failed to save %s: error %d" % [output_path, save_error])
		return false

	print("✓ Created: %s (%s, damage=%d)" % [weapon_id, weapon.weapon_name, weapon.damage])
	return true
