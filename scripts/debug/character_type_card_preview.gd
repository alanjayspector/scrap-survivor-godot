extends Control
## CharacterTypeCard Preview - Visual test scene for card component
##
## Week 17 Phase 1: Test all card states and animations
##
## Features tested:
## - All 4 character types (Scavenger, Tank, Commando, Mutant)
## - Player mode display
## - Selection glow animation
## - Tap animation
## - Lock overlay
## - Long press detection

const CharacterTypeCardScene = preload("res://scenes/ui/components/character_type_card.tscn")

@onready
var type_cards_container: GridContainer = $MarginContainer/VBoxContainer/TypeCardsSection/TypeCardsGrid
@onready
var player_cards_container: HBoxContainer = $MarginContainer/VBoxContainer/PlayerCardsSection/PlayerCardsHBox
@onready var status_label: Label = $MarginContainer/VBoxContainer/StatusSection/StatusLabel
@onready var tier_button: Button = $MarginContainer/VBoxContainer/ControlsSection/TierButton

var _type_cards: Array = []
var _player_cards: Array = []
var _selected_type_card: Node = null
var _current_tier: int = CharacterService.UserTier.FREE


func _ready() -> void:
	GameLogger.info("[CardPreview] Starting CharacterTypeCard preview")

	# Setup tier button
	if tier_button:
		tier_button.pressed.connect(_on_tier_button_pressed)
		_update_tier_button_text()

	# Create type cards
	_create_type_cards()

	# Create player cards
	_create_player_cards()

	_update_status("Ready - Tap cards to test")


func _create_type_cards() -> void:
	"""Create cards for all 4 character types"""
	var types = ["scavenger", "tank", "commando", "mutant"]

	for type_id in types:
		var card = CharacterTypeCardScene.instantiate()
		type_cards_container.add_child(card)
		card.setup_type(type_id)

		# Connect signals
		card.card_pressed.connect(_on_type_card_pressed.bind(card))
		card.card_long_pressed.connect(_on_type_card_long_pressed.bind(card))

		_type_cards.append(card)

	GameLogger.info("[CardPreview] Created %d type cards" % _type_cards.size())


func _create_player_cards() -> void:
	"""Create sample player character cards"""
	var sample_characters = [
		{
			"id": "player_1",
			"name": "Rusty",
			"character_type": "scavenger",
			"level": 5,
			"highest_wave": 12,
			"max_hp": 120
		},
		{
			"id": "player_2",
			"name": "Tank McTankface",
			"character_type": "tank",
			"level": 3,
			"highest_wave": 8,
			"max_hp": 150
		}
	]

	for char_data in sample_characters:
		var card = CharacterTypeCardScene.instantiate()
		player_cards_container.add_child(card)
		card.setup_player(char_data)

		# Connect signals
		card.card_pressed.connect(_on_player_card_pressed.bind(card))
		card.card_long_pressed.connect(_on_player_card_long_pressed.bind(card))

		_player_cards.append(card)

	# Select first player card to show selection state
	if _player_cards.size() > 0:
		_player_cards[0].set_selected(true)

	GameLogger.info("[CardPreview] Created %d player cards" % _player_cards.size())


func _on_type_card_pressed(identifier: String, card: Node) -> void:
	"""Handle type card tap - toggle selection"""
	GameLogger.info("[CardPreview] Type card pressed: %s" % identifier)

	# Deselect previous
	if _selected_type_card and _selected_type_card != card:
		_selected_type_card.set_selected(false)

	# Toggle this card
	var new_selected = not card.is_selected()
	card.set_selected(new_selected)
	_selected_type_card = card if new_selected else null

	_update_status("Selected type: %s" % identifier if new_selected else "Deselected")


func _on_type_card_long_pressed(identifier: String, _card: Node) -> void:
	"""Handle type card long press - show info"""
	GameLogger.info("[CardPreview] Type card LONG pressed: %s" % identifier)
	_update_status("Long press on: %s (would show detail modal)" % identifier)


func _on_player_card_pressed(identifier: String, card: Node) -> void:
	"""Handle player card tap"""
	GameLogger.info("[CardPreview] Player card pressed: %s" % identifier)

	# Deselect all player cards
	for pc in _player_cards:
		pc.set_selected(false)

	# Select this one
	card.set_selected(true)
	_update_status("Selected player: %s" % identifier)


func _on_player_card_long_pressed(identifier: String, _card: Node) -> void:
	"""Handle player card long press"""
	GameLogger.info("[CardPreview] Player card LONG pressed: %s" % identifier)
	_update_status("Long press on player: %s" % identifier)


func _on_tier_button_pressed() -> void:
	"""Cycle through tiers to test lock states"""
	_current_tier = (_current_tier + 1) % 3
	CharacterService.set_tier(_current_tier)

	_update_tier_button_text()

	# Refresh type cards to update lock states
	for card in _type_cards:
		var type_id = card.get_identifier()
		card.setup_type(type_id)

	var tier_name = ["FREE", "PREMIUM", "SUBSCRIPTION"][_current_tier]
	_update_status("Tier changed to: %s" % tier_name)


func _update_tier_button_text() -> void:
	"""Update tier button label"""
	if tier_button:
		var tier_names = ["FREE", "PREMIUM", "SUBSCRIPTION"]
		tier_button.text = "Tier: %s (tap to cycle)" % tier_names[_current_tier]


func _update_status(message: String) -> void:
	"""Update status label"""
	if status_label:
		status_label.text = message
	GameLogger.debug("[CardPreview] Status: %s" % message)
