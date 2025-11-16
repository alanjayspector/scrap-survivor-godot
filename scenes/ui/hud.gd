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
@onready var hp_label: Label = $HPBar/HPLabel if has_node("HPBar/HPLabel") else null
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

## Animation tracking
var hp_warning_tween: Tween = null
var timer_warning_tween: Tween = null


func _ready() -> void:
	# Connect to HudService signals
	if HudService:
		HudService.hp_changed.connect(_on_hp_changed)
		HudService.xp_changed.connect(_on_xp_changed)
		HudService.wave_changed.connect(_on_wave_changed)
		HudService.currency_changed.connect(_on_currency_changed)
	else:
		GameLogger.error("HUD: HudService not found")

	# Connect to WaveManager signals for wave timer (deferred to ensure WaveManager is ready)
	call_deferred("_connect_to_wave_manager")

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


func _connect_to_wave_manager() -> void:
	"""Connect to WaveManager signals (called deferred to ensure it's ready)"""
	var wave_manager = get_tree().get_first_node_in_group("wave_manager")
	if wave_manager:
		wave_manager.wave_started.connect(_on_wave_started)
		wave_manager.wave_completed.connect(_on_wave_completed)
		GameLogger.info("HUD: Connected to WaveManager signals")
	else:
		GameLogger.error("HUD: WaveManager not found in group")


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

	# Update HP label text with percentage for easier mental math
	if hp_label:
		var hp_percent = int((current / max_value) * 100.0)
		hp_label.text = "HP: %d%%" % hp_percent

	# Flash HP bar red when damaged (if decreasing)
	if current < hp_bar.value:
		_flash_bar(hp_bar, Color.RED)

	# Low HP warning (< 30% HP)
	var hp_percent = (current / max_value) * 100.0
	if hp_percent < 30.0:
		_show_low_hp_warning()
	else:
		_hide_low_hp_warning()


func _on_xp_changed(current: int, required: int, level: int) -> void:
	if not xp_bar:
		return

	xp_bar.max_value = required
	xp_bar.value = current

	# Update XP label text
	if xp_label:
		xp_label.text = "XP: %d / %d (Level %d)" % [current, required, level]

	# Track previous XP for next update
	previous_xp = current


func _on_wave_changed(wave: int) -> void:
	if not wave_label:
		return

	wave_label.text = "Wave %d" % wave

	# Wave label animation disabled - Tweens don't work on iOS Metal renderer


func _on_wave_started(wave: int) -> void:
	"""Called when a wave starts - initialize wave timer"""
	wave_active = true
	wave_time_remaining = wave_duration
	_update_wave_timer_display()

	# Hide currency display during combat (mobile UX optimization)
	if currency_display:
		currency_display.hide()

	GameLogger.info("HUD: Wave timer started", {"wave": wave, "duration": wave_duration})


func _on_wave_completed(_wave: int, _stats: Dictionary) -> void:
	"""Called when a wave completes - stop wave timer"""
	wave_active = false
	wave_time_remaining = 0.0

	# Stop timer pulsing animation
	if timer_warning_tween:
		timer_warning_tween.kill()
		timer_warning_tween = null

	if wave_timer_label:
		wave_timer_label.text = "COMPLETE"
		wave_timer_label.modulate = Color.GREEN
		wave_timer_label.scale = Vector2(1.0, 1.0)

	# Show currency display during wave complete (mobile UX optimization)
	if currency_display:
		currency_display.show()

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
	"""Update all currency labels (compact mobile-friendly format)"""
	if scrap_label:
		scrap_label.text = "S: %d" % scrap

	if components_label:
		components_label.text = "C: %d" % components

	if nanites_label:
		nanites_label.text = "N: %d" % nanites


func _update_wave_timer_display() -> void:
	"""Update wave timer label with remaining time and color coding"""
	if not wave_timer_label:
		return

	# Format time as MM:SS
	var minutes = int(wave_time_remaining) / 60
	var seconds = int(wave_time_remaining) % 60
	wave_timer_label.text = "%d:%02d" % [minutes, seconds]

	# Color code and animate based on remaining time
	if wave_time_remaining <= 5.0:
		# Red when < 5 seconds
		wave_timer_label.modulate = Color.RED
	elif wave_time_remaining <= 10.0:
		# Yellow when < 10 seconds
		wave_timer_label.modulate = Color.YELLOW

		# Start pulsing animation if not already active
		if not timer_warning_tween or not timer_warning_tween.is_running():
			timer_warning_tween = create_tween().set_loops()
			timer_warning_tween.tween_property(wave_timer_label, "scale", Vector2(1.1, 1.1), 0.5)
			timer_warning_tween.tween_property(wave_timer_label, "scale", Vector2(1.0, 1.0), 0.5)
	else:
		# White when > 10 seconds
		wave_timer_label.modulate = Color.WHITE

		# Stop pulsing animation if active
		if timer_warning_tween:
			timer_warning_tween.kill()
			timer_warning_tween = null
			wave_timer_label.scale = Vector2(1.0, 1.0)


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


func _flash_bar(_bar: ProgressBar, _flash_color: Color) -> void:
	"""Flash a progress bar with a color (disabled for iOS compatibility)"""
	# NOTE: Bar flash disabled - Tweens don't work on iOS Metal renderer
	return


func _pulse_label(_label: Label) -> void:
	"""Pulse a label to indicate change (disabled for iOS compatibility)"""
	# NOTE: Label pulse disabled - Tweens don't work on iOS Metal renderer
	return


func _show_low_hp_warning() -> void:
	"""Show visual warning when HP is low (pulsing HP bar)"""
	if not hp_bar:
		return

	# Stop any existing tween
	if hp_warning_tween:
		hp_warning_tween.kill()

	# Create pulsing animation between red and lighter red
	hp_warning_tween = create_tween().set_loops()
	hp_warning_tween.tween_property(hp_bar, "modulate", Color.RED, 0.5)
	hp_warning_tween.tween_property(hp_bar, "modulate", Color(1.0, 0.5, 0.5), 0.5)


func _hide_low_hp_warning() -> void:
	"""Hide low HP warning (restore normal HP bar color)"""
	if not hp_bar:
		return

	# Stop pulsing animation
	if hp_warning_tween:
		hp_warning_tween.kill()
		hp_warning_tween = null

	# Restore normal color
	hp_bar.modulate = Color.WHITE
