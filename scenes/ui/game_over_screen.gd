extends Panel
## Game Over screen shown when player dies

signal retry_pressed
signal main_menu_pressed

@onready var game_over_label: Label = $Content/GameOverLabel
@onready var stats_display: VBoxContainer = $Content/StatsDisplay
@onready var retry_button: Button = $Content/RetryButton
@onready var main_menu_button: Button = $Content/MainMenuButton


func _ready() -> void:
	# Allow UI to work when game is paused (PROCESS_MODE_ALWAYS)
	process_mode = Node.PROCESS_MODE_ALWAYS

	hide()  # Hidden by default
	retry_button.pressed.connect(_on_retry_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)


func show_game_over(stats: Dictionary) -> void:
	"""Display game over screen with stats"""
	# Clear previous stats
	for child in stats_display.get_children():
		child.queue_free()

	# Add stats
	_add_stat_label("Wave Reached: %d" % stats.get("wave", 0))
	_add_stat_label("Enemies Killed: %d" % stats.get("kills", 0))
	_add_stat_label("Survival Time: %s" % _format_time(stats.get("time", 0)))

	show()


func _add_stat_label(text: String) -> void:
	var label = Label.new()
	label.text = text
	stats_display.add_child(label)


func _format_time(seconds: float) -> String:
	"""Format seconds as MM:SS"""
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%02d:%02d" % [minutes, secs]


func _on_retry_pressed() -> void:
	hide()
	retry_pressed.emit()


func _on_main_menu_pressed() -> void:
	hide()
	main_menu_pressed.emit()
