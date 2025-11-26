extends Node
## Visual Regression Testing - Screenshot capture for before/after comparison
## Week 16 Phase 0: Baseline capture infrastructure

const BASELINE_PATH = "tests/visual_regression/baseline/"
const CURRENT_PATH = "tests/visual_regression/current/"

var scenes_to_capture = [
	"res://scenes/hub/scrapyard.tscn",
	"res://scenes/ui/barracks.tscn",
	"res://scenes/ui/character_creation.tscn",
	"res://scenes/ui/character_selection.tscn",
	"res://scenes/game/wasteland.tscn",  # For HUD capture
	"res://scenes/debug/debug_menu.tscn",
]


func capture_all_baselines() -> void:
	"""Capture baseline screenshots of all scenes"""
	_ensure_directory_exists(BASELINE_PATH)

	for scene_path in scenes_to_capture:
		var scene_name = scene_path.get_file().get_basename()
		var output_path = "%s%s.png" % [BASELINE_PATH, scene_name]

		await _capture_scene_screenshot(scene_path, output_path)
		GameLogger.info("[VisualRegression] Baseline captured: %s" % scene_name)

	GameLogger.info(
		"[VisualRegression] All baselines captured", {"count": scenes_to_capture.size()}
	)


func capture_all_current() -> void:
	"""Capture current screenshots for comparison"""
	_ensure_directory_exists(CURRENT_PATH)

	for scene_path in scenes_to_capture:
		var scene_name = scene_path.get_file().get_basename()
		var output_path = "%s%s.png" % [CURRENT_PATH, scene_name]

		await _capture_scene_screenshot(scene_path, output_path)
		GameLogger.info("[VisualRegression] Current captured: %s" % scene_name)

	GameLogger.info(
		"[VisualRegression] All current screenshots captured", {"count": scenes_to_capture.size()}
	)


func _capture_scene_screenshot(scene_path: String, output_path: String) -> void:
	"""Capture screenshot of a scene"""
	# Load and instantiate scene
	var scene_resource = load(scene_path)
	if not scene_resource:
		GameLogger.error("[VisualRegression] Failed to load scene", {"path": scene_path})
		return

	var scene = scene_resource.instantiate()
	get_tree().root.add_child(scene)

	# Wait for scene to render
	await get_tree().process_frame
	await get_tree().process_frame

	# Capture screenshot from root viewport (where scene was added)
	var img = get_tree().root.get_viewport().get_texture().get_image()
	var error = img.save_png(output_path)

	if error != OK:
		GameLogger.error(
			"[VisualRegression] Failed to save screenshot", {"path": output_path, "error": error}
		)
	else:
		GameLogger.debug("[VisualRegression] Screenshot saved", {"path": output_path})

	# Cleanup
	scene.queue_free()


func _ensure_directory_exists(path: String) -> void:
	"""Create directory if it doesn't exist"""
	if not DirAccess.dir_exists_absolute(path):
		var error = DirAccess.make_dir_recursive_absolute(path)
		if error != OK:
			GameLogger.error(
				"[VisualRegression] Failed to create directory", {"path": path, "error": error}
			)
		else:
			GameLogger.info("[VisualRegression] Directory created", {"path": path})
