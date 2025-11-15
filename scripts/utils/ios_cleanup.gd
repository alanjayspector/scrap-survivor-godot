class_name IOSCleanup
## iOS-specific node cleanup utility
##
## Solves iOS Metal renderer bug where nodes remain in GPU draw list even after
## hide() + remove_child() + queue_free(). Uses multi-layered approach to force
## visual invisibility before scene tree cleanup.
##
## Root Cause: iOS Metal renderer caches CanvasItem draw calls and doesn't
## immediately update when nodes are hidden or removed from scene tree.
##
## Solution: Force invisibility through redundant methods:
##   1. Clear visual properties (text, color, etc.)
##   2. Set modulate alpha to 0 (transparent)
##   3. Move completely off-screen
##   4. Set z-index to minimum (render behind everything)
##   5. Disable processing
##   6. Standard cleanup (hide, remove_child, queue_free)
##
## Date: 2025-01-14
## Bug Reference: docs/experiments/ios-rendering-pipeline-bug-analysis.md


static func force_invisible_and_destroy(node: Node) -> void:
	"""iOS-safe node cleanup with forced visual invalidation

	This method uses multiple redundant techniques to ensure a node becomes
	invisible on iOS before being removed from the scene tree.

	Args:
		node: The node to clean up and destroy

	Implementation Notes:
		- Pre-cleanup: Clears type-specific visual properties (text, color)
		- Modulate: Sets alpha to 0 for transparency
		- Position: Moves node completely off-screen
		- Z-Index: Renders behind everything as fallback
		- Processing: Disables all update loops
		- Standard: hide() + remove_child() + queue_free()
	"""

	# Validate node
	if not is_instance_valid(node):
		print("[IOSCleanup] WARNING: Invalid node passed to force_invisible_and_destroy")
		return

	var node_id = node.get_instance_id()
	var node_type = node.get_class()
	print("[IOSCleanup] Destroying node: ", node_type, " (ID: ", node_id, ")")

	# === PHASE 1: Pre-cleanup - Clear visual properties ===

	# Labels: Clear text to remove rendered glyphs
	if node is Label:
		node.text = ""
		print("[IOSCleanup]   Cleared Label text")

	# ColorRect: Set to fully transparent
	elif node is ColorRect:
		node.color = Color(0, 0, 0, 0)
		print("[IOSCleanup]   Set ColorRect to transparent")

	# Sprite2D: Hide sprite texture
	elif node is Sprite2D:
		node.texture = null
		print("[IOSCleanup]   Cleared Sprite2D texture")

	# AnimatedSprite2D: Stop animation and clear
	elif node is AnimatedSprite2D:
		node.stop()
		node.animation = ""
		print("[IOSCleanup]   Stopped AnimatedSprite2D")

	# === PHASE 2: Force transparency via modulate ===

	# Set modulate alpha to 0 (fully transparent)
	if node.has_method("set"):
		node.set("modulate", Color(1, 1, 1, 0))
		print("[IOSCleanup]   Set modulate alpha to 0")

		# Also set self_modulate if available (affects node only, not children)
		if "self_modulate" in node:
			node.set("self_modulate", Color(1, 1, 1, 0))
			print("[IOSCleanup]   Set self_modulate alpha to 0")

	# === PHASE 3: Move completely off-screen ===

	# Node2D: Use global_position for world-space nodes
	if node is Node2D:
		node.global_position = Vector2(999999, 999999)
		print("[IOSCleanup]   Moved Node2D off-screen to (999999, 999999)")

	# Control: Use global_position for UI nodes
	elif node is Control:
		node.global_position = Vector2(999999, 999999)
		print("[IOSCleanup]   Moved Control off-screen to (999999, 999999)")

	# === PHASE 4: Set minimum z-index (render behind everything) ===

	if node.has_method("set") and "z_index" in node:
		node.set("z_index", -4096)
		print("[IOSCleanup]   Set z_index to -4096")

	# === PHASE 5: Disable all processing ===

	# Disable _process() callback
	if node.has_method("set_process"):
		node.set_process(false)
		print("[IOSCleanup]   Disabled _process()")

	# Disable _physics_process() callback
	if node.has_method("set_physics_process"):
		node.set_physics_process(false)
		print("[IOSCleanup]   Disabled _physics_process()")

	# Disable input processing
	if node.has_method("set_process_input"):
		node.set_process_input(false)
		print("[IOSCleanup]   Disabled input processing")

	# === PHASE 6: RenderingServer forced invisibility (iOS Metal renderer fix) ===

	# Try to force Metal renderer to update by directly manipulating canvas item
	if node is CanvasItem:
		var canvas_item_rid = node.get_canvas_item()
		if canvas_item_rid.is_valid():
			# Force render server to mark this canvas item as invisible
			RenderingServer.canvas_item_set_visible(canvas_item_rid, false)
			print("[IOSCleanup]   RenderingServer: Forced canvas_item invisible")

			# Try to force canvas item to be removed from draw list
			RenderingServer.canvas_item_set_draw_index(canvas_item_rid, -999999)
			print("[IOSCleanup]   RenderingServer: Set draw_index to -999999")

	# === PHASE 7: Standard scene tree cleanup ===

	# Hide node (sets visible = false)
	node.hide()
	print("[IOSCleanup]   Called hide()")

	# Remove from parent (removes from scene tree)
	if node.get_parent():
		var parent = node.get_parent()
		parent.remove_child(node)
		print("[IOSCleanup]   Removed from parent: ", parent.get_class())
	else:
		print("[IOSCleanup]   Node has no parent (already orphaned)")

	# Queue for deferred deletion (frees memory at end of frame)
	node.queue_free()
	print("[IOSCleanup]   Queued for deletion via queue_free()")

	print(
		"[IOSCleanup] ✓ Node destroyed with forced invisibility: ",
		node_type,
		" (ID: ",
		node_id,
		")"
	)


static func force_invisible_and_destroy_batch(nodes: Array) -> void:
	"""Clean up multiple nodes in batch

	Convenience method for cleaning up arrays of nodes.

	Args:
		nodes: Array of nodes to clean up
	"""

	if nodes.is_empty():
		print("[IOSCleanup] force_invisible_and_destroy_batch: No nodes to clean")
		return

	print("[IOSCleanup] Batch cleanup: ", nodes.size(), " nodes")

	for node in nodes:
		if is_instance_valid(node):
			force_invisible_and_destroy(node)

	print("[IOSCleanup] ✓ Batch cleanup complete: ", nodes.size(), " nodes destroyed")
