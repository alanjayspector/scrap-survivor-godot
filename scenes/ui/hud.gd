extends Control
## HUD - Heads-Up Display for combat scene
##
## Week 10 Phase 3: HUD Implementation with HP, XP, wave, and currency displays
## Week 12 Phase 2: Wave countdown timer
##
## Displays:
## - HP bar (current/max health)
## - XP bar (current/required XP, level)
## - Wave counter
## - Wave countdown timer
## - Currency display (scrap, components, nanites)
##
## Based on: docs/migration/week10-implementation-plan.md (lines 467-562)

## Node references (set when nodes are available)
@onready var hp_bar: ProgressBar = $HPBar if has_node("HPBar") else null
@onready var xp_bar: ProgressBar = $XPBar if has_node("XPBar") else null
@onready var xp_label: Label = $XPBar/XPLabel if has_node("XPBar/XPLabel") else null
@onready var wave_label: Label = $WaveLabel if has_node("WaveLabel") else null
@onready var wave_timer_label: Label = $WaveTimerLabel if has_node("WaveTimerLabel") else null
@onready
var currency_display: HBoxContainer = $CurrencyDisplay if has_node("CurrencyDisplay") else null
@onready var scrap_label: Label = (
	$CurrencyDisplay/ScrapLabel if has_node("CurrencyDisplay/ScrapLabel") else null
)
@onready var components_label: Label = (
	$CurrencyDisplay/ComponentsLabel if has_node("CurrencyDisplay/ComponentsLabel") else null
)
@onready var nanites_label: Label = (
	$CurrencyDisplay/NanitesLabel if has_node("CurrencyDisplay/NanitesLabel") else null
)

## Currency tracking (local state)
var scrap: int = 0
var components: int = 0
var nanites: int = 0

## XP tracking (for detecting actual level-ups)
var previous_xp: int = -1  # -1 = uninitialized

## Wave timer tracking
var wave_duration: float = 60.0  # Default 60 seconds per wave
var wave_time_remaining: float = 0.0
var wave_active: bool = false


func _ready() -> void:
	# Connect to HudService signals
	if HudService:
		HudService.hp_changed.connect(_on_hp_changed)
		HudService.xp_changed.connect(_on_xp_changed)
		HudService.wave_changed.connect(_on_wave_changed)
		HudService.currency_changed.connect(_on_currency_changed)

	# Connect to WaveManager signals for wave timer
	var wave_manager = get_tree().get_first_node_in_group("wave_manager")
	if wave_manager:
		wave_manager.wave_started.connect(_on_wave_started)
		wave_manager.wave_completed.connect(_on_wave_completed)

	# Initialize currency from BankingService
	if BankingService:
		scrap = BankingService.balances.get("scrap", 0)
		# TODO Week 11: Add components and nanites to BankingService
		components = 0
		nanites = 0

	# Update displays
	_update_currency_display()

	# Initialize HP and XP from HudService
	var hp_state = HudService.get_current_hp()
	_on_hp_changed(hp_state.current, hp_state.max)

	var xp_state = HudService.get_current_xp()
	_on_xp_changed(xp_state.current, xp_state.required, xp_state.level)

	# Initialize wave
	_on_wave_changed(HudService.get_current_wave())

	GameLogger.info("HUD initialized")


func _process(delta: float) -> void:
	"""Update wave timer every frame"""
	if wave_active and wave_time_remaining > 0:
		wave_time_remaining -= delta
		wave_time_remaining = max(0, wave_time_remaining)
		_update_wave_timer_display()


## Signal Handlers


func _on_hp_changed(current: float, max_value: float) -> void:
	if not hp_bar:
		return

	hp_bar.max_value = max_value
	hp_bar.value = current

	# Flash HP bar red when damaged (if decreasing)
	if current < hp_bar.value:
		_flash_bar(hp_bar, Color.RED)


func _on_xp_changed(current: int, required: int, level: int) -> void:
	if not xp_bar:
		return

	xp_bar.max_value = required
	xp_bar.value = current

	# Update XP label text
	if xp_label:
		xp_label.text = "XP: %d / %d (Level %d)" % [current, required, level]

	# Show level up effect when XP resets to 0 (leveled up)
	# Only show if previous XP was > 0 (actual level-up, not initial state)
	if current == 0 and previous_xp > 0:
		_show_level_up_popup(level)

	# Track previous XP for next update
	previous_xp = current


func _on_wave_changed(wave: int) -> void:
	if not wave_label:
		return

	wave_label.text = "Wave %d" % wave

	# Wave label animation
	var tween = create_tween()
	tween.tween_property(wave_label, "scale", Vector2(1.5, 1.5), 0.2)
	tween.tween_property(wave_label, "scale", Vector2(1.0, 1.0), 0.2)


func _on_wave_started(wave: int) -> void:
	"""Called when a wave starts - initialize wave timer"""
	wave_active = true
	wave_time_remaining = wave_duration
	_update_wave_timer_display()
	GameLogger.info("HUD: Wave timer started", {"wave": wave, "duration": wave_duration})


func _on_wave_completed(_wave: int, _stats: Dictionary) -> void:
	"""Called when a wave completes - stop wave timer"""
	wave_active = false
	wave_time_remaining = 0.0
	if wave_timer_label:
		wave_timer_label.text = "COMPLETE"
		wave_timer_label.modulate = Color.GREEN
	GameLogger.info("HUD: Wave timer stopped")


func _on_currency_changed(currency_type: String, _amount: int, new_total: int) -> void:
	# Update local currency tracking
	match currency_type:
		"scrap":
			scrap = new_total
		"components":
			components = new_total
		"nanites":
			nanites = new_total

	_update_currency_display()

	# Animate currency label that changed
	var label = _get_currency_label(currency_type)
	if label:
		_pulse_label(label)


## Display Update Functions


func _update_currency_display() -> void:
	"""Update all currency labels"""
	if scrap_label:
		scrap_label.text = "Scrap: %d" % scrap

	if components_label:
		components_label.text = "Components: %d" % components

	if nanites_label:
		nanites_label.text = "Nanites: %d" % nanites


func _update_wave_timer_display() -> void:
	"""Update wave timer label with remaining time and color coding"""
	if not wave_timer_label:
		return

	# Format time as MM:SS
	var minutes = int(wave_time_remaining) / 60
	var seconds = int(wave_time_remaining) % 60
	wave_timer_label.text = "%d:%02d" % [minutes, seconds]

	# Color code based on remaining time
	if wave_time_remaining <= 5.0:
		# Red when < 5 seconds
		wave_timer_label.modulate = Color.RED
	elif wave_time_remaining <= 10.0:
		# Yellow when < 10 seconds
		wave_timer_label.modulate = Color.YELLOW
	else:
		# White when > 10 seconds
		wave_timer_label.modulate = Color.WHITE


func _get_currency_label(currency_type: String) -> Label:
	"""Get the label node for a currency type"""
	match currency_type:
		"scrap":
			return scrap_label
		"components":
			return components_label
		"nanites":
			return nanites_label
		_:
			return null


## Animation Functions


func _flash_bar(bar: ProgressBar, flash_color: Color) -> void:
	"""Flash a progress bar with a color"""
	if not bar:
		return

	var original_color = bar.modulate
	var tween = create_tween()
	tween.tween_property(bar, "modulate", flash_color, 0.1)
	tween.tween_property(bar, "modulate", original_color, 0.2)


func _pulse_label(label: Label) -> void:
	"""Pulse a label to indicate change"""
	if not label:
		return

	var tween = create_tween()
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.1)


func _show_level_up_popup(level: int) -> void:
	"""Show a level up notification popup"""
	# Create a temporary label for the popup
	var popup = Label.new()
	popup.text = "LEVEL UP! %d" % level
	popup.modulate = Color.YELLOW
	popup.z_index = 100  # Ensure it's on top

	# Set position (center-top of screen)
	popup.position = Vector2(size.x / 2 - 100, 100)
	add_child(popup)

	# Animate popup (float up and fade out)
	var tween = create_tween()
	tween.tween_property(popup, "position:y", popup.position.y - 50, 1.0)
	tween.parallel().tween_property(popup, "modulate:a", 0.0, 0.5).set_delay(0.5)
	tween.tween_callback(popup.queue_free)

	GameLogger.info("HUD: Level up popup shown", {"level": level})
