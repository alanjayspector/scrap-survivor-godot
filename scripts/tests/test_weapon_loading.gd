extends Node
## Test script to verify weapon resources load correctly
##
## Usage:
## 1. Create a new scene with a Node
## 2. Attach this script
## 3. Run the scene (F6)
## 4. Check console output


func _ready() -> void:
	print("=== Weapon Resource Loading Test ===")
	print("")

	_test_load_weapon("rusty_pistol")
	_test_load_weapon("void_cannon")
	_test_load_weapon("plasma_cutter")

	print("")
	_test_load_all_weapons()

	print("")
	print("=== Test Complete ===")


func _test_load_weapon(weapon_id: String) -> void:
	var path = "res://resources/weapons/%s.tres" % weapon_id
	var weapon: WeaponResource = load(path)

	if weapon == null:
		push_error("Failed to load: %s" % path)
		return

	print("✓ Loaded: %s" % weapon)
	print("  DPS: %.1f" % weapon.get_dps())
	print("  Premium: %s" % weapon.is_premium_weapon())
	print("  Rarity Tier: %d (%s)" % [weapon.get_rarity_tier(), weapon.rarity])


func _test_load_all_weapons() -> void:
	print("Loading all 23 weapons...")

	var weapons_dir = DirAccess.open("res://resources/weapons/")
	if weapons_dir == null:
		push_error("Failed to open weapons directory")
		return

	var loaded_count = 0
	var failed_count = 0

	weapons_dir.list_dir_begin()
	var file_name = weapons_dir.get_next()

	while file_name != "":
		if file_name.ends_with(".tres"):
			var path = "res://resources/weapons/" + file_name
			var weapon: WeaponResource = load(path)

			if weapon != null:
				loaded_count += 1
			else:
				push_error("Failed to load: %s" % path)
				failed_count += 1

		file_name = weapons_dir.get_next()

	weapons_dir.list_dir_end()

	print("Loaded: %d weapons" % loaded_count)
	print("Failed: %d weapons" % failed_count)

	if loaded_count == 23 and failed_count == 0:
		print("✅ All weapons loaded successfully!")
	else:
		push_warning("Expected 23 weapons, got %d" % loaded_count)
