extends Panel

## Wave completion screen showing stats and next wave button

signal next_wave_pressed
signal return_to_hub_pressed

@onready var victory_label: Label = $PaddingContainer/Content/VictoryLabel
@onready var stats_display: VBoxContainer = $PaddingContainer/Content/StatsDisplay
@onready var next_wave_button: Button = $PaddingContainer/Content/ButtonsContainer/NextWaveButton
@onready var hub_button: Button = $PaddingContainer/Content/ButtonsContainer/HubButton


func _ready() -> void:
	hide()  # Hidden by default

	# Verify nodes exist (defensive programming)
	if not is_instance_valid(next_wave_button):
		push_error("[WaveComplete] NextWaveButton not found!")
		return
	if not is_instance_valid(hub_button):
		push_error("[WaveComplete] HubButton not found!")
		return

	# Ensure hub button is visible and properly sized
	hub_button.visible = true
	hub_button.custom_minimum_size = Vector2(180, 70)  # Match NextWaveButton size (mobile-friendly)

	print("[WaveComplete] Buttons initialized - Hub: ", hub_button, " Next: ", next_wave_button)

	next_wave_button.pressed.connect(_on_next_wave_pressed)
	hub_button.pressed.connect(_on_hub_button_pressed)


func show_stats(wave: int, stats: Dictionary) -> void:
	victory_label.text = "Wave %d Complete!" % wave

	# Clear previous stats
	for child in stats_display.get_children():
		child.queue_free()

	# Add stat labels
	_add_stat_label("Enemies Killed: %d" % stats.enemies_killed)

	# Currency drops
	for currency in stats.drops_collected.keys():
		var amount = stats.drops_collected[currency]
		_add_stat_label("%s Collected: %d" % [currency.capitalize(), amount])

	# XP earned (if available)
	if stats.has("xp_earned"):
		_add_stat_label("XP Earned: %d" % stats.xp_earned)

	# Wave time (if available)
	if stats.has("wave_time"):
		var time_str = "%.1f" % stats.wave_time
		_add_stat_label("Time: %s seconds" % time_str)


func _add_stat_label(text: String) -> void:
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 24)  # Mobile-friendly font size
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 3)
	label.add_theme_constant_override("line_spacing", 4)  # Better line height
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_display.add_child(label)


func _on_next_wave_pressed() -> void:
	hide()
	next_wave_pressed.emit()


func _on_hub_button_pressed() -> void:
	hide()
	return_to_hub_pressed.emit()
