extends Panel
## Debug Weapon Switcher - iOS testing tool for Week 14 Phase 1.0
##
## Enables weapon switching on iOS devices via touch buttons.
## TEMPORARY: Remove before production release.
##
## Created: 2025-11-15 (Week 14 Phase 1.0)
## Purpose: Test all 10 weapon sounds on iOS device

var player: Player = null
var panel_visible: bool = false

# Weapon list (matches WeaponService.WEAPON_DEFINITIONS keys)
const WEAPONS = [
	{"id": "plasma_pistol", "name": "Plasma Pistol"},
	{"id": "rusty_blade", "name": "Rusty Blade"},
	{"id": "steel_sword", "name": "Scrap Cleaver"},
	{"id": "shock_rifle", "name": "Arc Blaster"},
	{"id": "shotgun", "name": "Scattergun"},
	{"id": "sniper_rifle", "name": "Dead Eye"},
	{"id": "flamethrower", "name": "Scorcher"},
	{"id": "laser_rifle", "name": "Beam Gun"},
	{"id": "minigun", "name": "Shredder"},
	{"id": "rocket_launcher", "name": "Boom Tube"}
]


func _ready() -> void:
	# Find player (wait for scene tree to be ready)
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player") as Player

	if not player:
		print("[DebugWeaponSwitcher] WARNING: Player not found!")

	# Build UI programmatically (no .tscn required)
	_build_ui()

	print("[DebugWeaponSwitcher] Initialized with ", WEAPONS.size(), " weapons")


func _build_ui() -> void:
	"""Build weapon switcher UI programmatically"""
	# Panel configuration
	custom_minimum_size = Vector2(340, 600)
	position = Vector2(10, 10)  # Top-left corner (safe area)

	# Semi-transparent dark background
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.85)  # Dark, 85% opaque
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	add_theme_stylebox_override("panel", style)

	# Toggle button (always visible, top of panel)
	var toggle_btn = Button.new()
	toggle_btn.name = "ToggleButton"
	toggle_btn.text = "WEAPONS ▼"
	toggle_btn.custom_minimum_size = Vector2(320, 60)
	toggle_btn.position = Vector2(10, 10)
	toggle_btn.pressed.connect(_on_toggle_pressed)
	add_child(toggle_btn)

	# Content container (can be hidden)
	var content = VBoxContainer.new()
	content.name = "Content"
	content.position = Vector2(10, 80)
	content.custom_minimum_size = Vector2(320, 500)
	content.visible = panel_visible
	add_child(content)

	# Title label
	var title = Label.new()
	title.text = "DEBUG: Weapon Switcher"
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(1, 0.8, 0, 1))  # Yellow
	content.add_child(title)

	# Weapon grid (2 columns)
	var grid = GridContainer.new()
	grid.name = "WeaponGrid"
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	content.add_child(grid)

	# Create weapon buttons
	for weapon in WEAPONS:
		var btn = Button.new()
		btn.text = weapon.name
		btn.custom_minimum_size = Vector2(145, 60)  # Touch-friendly
		btn.pressed.connect(_on_weapon_button_pressed.bind(weapon.id))

		# Style button
		btn.add_theme_font_size_override("font_size", 14)

		grid.add_child(btn)

	print("[DebugWeaponSwitcher] UI built with ", WEAPONS.size(), " weapon buttons")


func _on_weapon_button_pressed(weapon_id: String) -> void:
	"""Switch to selected weapon"""
	if not player:
		print("[DebugWeaponSwitcher] ERROR: No player reference!")
		return

	if not player.is_alive():
		print("[DebugWeaponSwitcher] Cannot switch weapon - player is dead")
		return

	# Equip weapon
	var success = player.equip_weapon(weapon_id)
	if success:
		print("[DebugWeaponSwitcher] ✓ Switched to: ", weapon_id)

		# Update UI feedback (highlight active weapon)
		_update_active_weapon_highlight(weapon_id)
	else:
		print("[DebugWeaponSwitcher] ✗ Failed to equip: ", weapon_id)


func _update_active_weapon_highlight(active_weapon_id: String) -> void:
	"""Visual feedback: highlight the active weapon button"""
	var grid = get_node_or_null("Content/WeaponGrid")
	if not grid:
		return

	for button in grid.get_children():
		if button is Button:
			# Find which weapon this button represents
			var button_weapon_id = ""
			for weapon in WEAPONS:
				if button.text == weapon.name:
					button_weapon_id = weapon.id
					break

			# Highlight if active
			if button_weapon_id == active_weapon_id:
				button.modulate = Color(0.5, 1.0, 0.5)  # Green tint
			else:
				button.modulate = Color(1, 1, 1)  # White (normal)


func _on_toggle_pressed() -> void:
	"""Toggle panel content visibility"""
	panel_visible = !panel_visible

	var content = get_node_or_null("Content")
	var toggle_btn = get_node_or_null("ToggleButton")

	if content:
		content.visible = panel_visible

	if toggle_btn:
		toggle_btn.text = "WEAPONS ▲" if panel_visible else "WEAPONS ▼"

	print("[DebugWeaponSwitcher] Panel ", "shown" if panel_visible else "hidden")
