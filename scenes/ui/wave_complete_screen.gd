extends Panel

## Wave completion screen showing stats and next wave button

signal next_wave_pressed

@onready var victory_label: Label = $VictoryLabel
@onready var stats_display: VBoxContainer = $StatsDisplay
@onready var next_wave_button: Button = $NextWaveButton


func _ready() -> void:
	hide()  # Hidden by default
	next_wave_button.pressed.connect(_on_next_wave_pressed)


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


func _add_stat_label(text: String) -> void:
	var label = Label.new()
	label.text = text
	stats_display.add_child(label)


func _on_next_wave_pressed() -> void:
	hide()
	next_wave_pressed.emit()
