extends CharacterBody2D
## Demo Player - Integrates with CharacterService
##
## Loads character data from CharacterService and displays it visually
## This proves the character system works end-to-end

@onready var visual: ColorRect = $Visual
@onready var aura_visual: Node2D = $AuraVisual
@onready var label: Label = $Label

var character_data: Dictionary = {}
var character_id: String = ""
var speed: float = 200.0


func _ready() -> void:
	# Get active character from CharacterService
	character_id = CharacterService.get_active_character_id()

	if character_id.is_empty():
		push_error("No active character found!")
		return

	character_data = CharacterService.get_character(character_id)

	if character_data.is_empty():
		push_error("Failed to load character data!")
		return

	# Apply character visuals
	_apply_character_appearance()

	# Setup aura if character has one
	_setup_aura()

	# Update label
	_update_label()

	GameLogger.info(
		"Demo player loaded",
		{
			"character_id": character_id,
			"name": character_data.name,
			"type": character_data.character_type,
			"level": character_data.level
		}
	)


func _physics_process(_delta: float) -> void:
	# Get input
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# Apply character speed stat
	speed = character_data.stats.speed

	# Move
	velocity = input_dir * speed
	move_and_slide()

	# Rotate to face movement
	if input_dir.length() > 0.1:
		rotation = input_dir.angle()


func _apply_character_appearance() -> void:
	"""Apply character type color to visual"""
	var character_type = character_data.character_type
	var type_def = CharacterService.CHARACTER_TYPES[character_type]

	# Set visual color based on character type
	visual.color = type_def.color


func _setup_aura() -> void:
	"""Setup aura visual based on character type"""
	if not character_data.has("aura"):
		return

	var aura_type = character_data.aura.type
	if aura_type == null:
		# Commando has no aura
		aura_visual.visible = false
		return

	# Calculate aura radius from pickup_range stat
	var radius = AuraTypes.calculate_aura_radius(character_data.stats.pickup_range)

	# Update aura visual
	if aura_visual.has_method("update_aura"):
		aura_visual.update_aura(aura_type, radius)


func _update_label() -> void:
	"""Update label with character info"""
	var text = (
		"%s (Lv %d)\n%s\n\nStats:\nHP: %d\nDamage: %d\nSpeed: %d\nArmor: %d"
		% [
			character_data.name,
			character_data.level,
			character_data.character_type.capitalize(),
			character_data.stats.max_hp,
			character_data.stats.damage,
			character_data.stats.speed,
			character_data.stats.armor
		]
	)

	# Add type-specific stats
	if character_data.character_type == "scavenger":
		text += "\nScavenging: %d" % character_data.stats.scavenging
	elif character_data.character_type == "commando":
		text += (
			"\nRanged DMG: %d\nAtk Speed: %d%%"
			% [character_data.stats.ranged_damage, character_data.stats.attack_speed]
		)
	elif character_data.character_type == "mutant":
		text += (
			"\nResonance: %d\nLuck: %d"
			% [character_data.stats.resonance, character_data.stats.luck]
		)

	# Add aura info
	if character_data.aura.type:
		var aura_power = AuraTypes.calculate_aura_power(
			character_data.aura.type, character_data.stats.resonance
		)
		text += "\n\nAura: %s\nPower: %.1f" % [character_data.aura.type.capitalize(), aura_power]
	else:
		text += "\n\nAura: None (Commando)"

	label.text = text
