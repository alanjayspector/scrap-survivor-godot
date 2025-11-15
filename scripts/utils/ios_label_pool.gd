class_name IOSLabelPool
## iOS-safe label management using Tween-based modulate.a pattern
##
## Root Cause: iOS Metal renderer has ghost rendering bug with hide()/show() calls.
## Solution: Use modulate.a with Tween animations (industry standard mobile pattern).
##
## Pattern (Standard Mobile Game Approach):
##   1. Create label pool at startup
##   2. Labels stay visible=true ALWAYS
##   3. "Show" label = set text, position, animate modulate.a from 0.0 → 1.0
##   4. "Hide" label = animate modulate.a from 1.0 → 0.0, clear text
##   5. Never call hide()/show() or set visible property
##
## Date: 2025-01-15
## Reference: docs/godot-ios-temp-ui.md (Pattern 1: Reusable Label with Tween)

## Maximum labels in pool (prevent unbounded growth)
const MAX_POOL_SIZE := 20

## Pool of available (hidden) labels
var available_labels: Array[Label] = []

## Pool of active (visible) labels
var active_labels: Array[Label] = []

## Parent node to attach labels to
var parent_node: Node = null


func _init(parent: Node) -> void:
	"""Initialize pool with parent node for label attachment

	Args:
		parent: Node to attach labels to (typically a CanvasLayer)
	"""
	parent_node = parent
	print("[IOSLabelPool] Initialized with parent: ", parent.get_class())


func get_label() -> Label:
	"""Get a label from pool (reuse if available, create if needed)

	Returns:
		Label: A label ready to be configured (starts invisible with modulate.a = 0.0)
	"""
	var label: Label = null

	if not available_labels.is_empty():
		# Reuse existing label from pool
		label = available_labels.pop_back()
		print("[IOSLabelPool] Reusing label from pool (ID: ", label.get_instance_id(), ")")
	else:
		# Create new label (visible=true ALWAYS, use modulate.a for showing/hiding)
		label = Label.new()
		label.add_theme_font_size_override("font_size", 48)
		label.add_theme_color_override("font_color", Color.YELLOW)
		label.add_theme_color_override("font_outline_color", Color.BLACK)
		label.add_theme_constant_override("outline_size", 3)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

		# CRITICAL: Keep visible=true always, use modulate.a for transparency
		label.visible = true
		label.modulate.a = 0.0  # Start invisible

		# Add to parent
		parent_node.add_child(label)
		print("[IOSLabelPool] Created new label (ID: ", label.get_instance_id(), ")")

	# Ensure label starts invisible (modulate.a = 0.0)
	# Caller will use Tween to fade in
	label.modulate.a = 0.0

	# Add to active tracking
	active_labels.append(label)

	return label


func return_label(label: Label) -> void:
	"""Return label to pool using iOS-safe modulate.a pattern

	iOS-safe pattern (standard mobile game approach):
	1. Clear text (remove rendered glyphs)
	2. Set modulate.a = 0.0 (fully transparent)
	3. Move off-screen (safety)
	4. Keep visible=true (NEVER call hide())
	5. NO queue_free() - label stays in scene tree for reuse

	CRITICAL: Never call hide() - triggers iOS Metal renderer ghost bug.
	Use modulate.a = 0.0 instead (GPU-accelerated alpha blending).

	Args:
		label: Label to return to pool
	"""
	if not is_instance_valid(label):
		print("[IOSLabelPool] WARNING: Invalid label passed to return_label")
		return

	print("[IOSLabelPool] Returning label to pool (ID: ", label.get_instance_id(), ")")

	# Remove from active tracking
	if label in active_labels:
		active_labels.erase(label)

	# iOS-safe hiding using modulate.a (standard mobile pattern)

	# Phase 1: Clear visual content
	label.text = ""

	# Phase 2: Set fully transparent (GPU-accelerated alpha, no Metal cache bug)
	label.modulate.a = 0.0

	# Phase 3: Move off-screen (safety, though modulate.a = 0.0 is sufficient)
	label.global_position = Vector2(999999, 999999)

	# Phase 4: Keep visible=true (NEVER call hide() - triggers Metal bug)
	# Label is invisible via modulate.a = 0.0, not hide()

	print("[IOSLabelPool]   Cleared text, set modulate.a=0.0, moved off-screen, kept visible=true")

	# Add to available pool if under max size
	if available_labels.size() < MAX_POOL_SIZE:
		available_labels.append(label)
		print("[IOSLabelPool]   Added to pool (pool size: ", available_labels.size(), ")")
	else:
		# Pool is full - actually free this one (rare case)
		print("[IOSLabelPool]   Pool full, calling queue_free() on excess label")
		label.queue_free()


func clear_all_active_labels() -> void:
	"""Return all active labels to pool using modulate.a pattern

	Used during wave transitions to hide all level-up feedback.
	Uses iOS-safe modulate.a = 0.0, never calls hide().
	"""
	print("[IOSLabelPool] Clearing all active labels (", active_labels.size(), " active)")

	# Copy array since return_label modifies active_labels
	var labels_to_clear = active_labels.duplicate()

	for label in labels_to_clear:
		return_label(label)

	print("[IOSLabelPool] All labels cleared (pool size: ", available_labels.size(), ")")


func get_stats() -> Dictionary:
	"""Get pool statistics for debugging

	Returns:
		Dictionary with pool metrics
	"""
	return {
		"available": available_labels.size(),
		"active": active_labels.size(),
		"total": available_labels.size() + active_labels.size(),
		"max_pool_size": MAX_POOL_SIZE
	}
