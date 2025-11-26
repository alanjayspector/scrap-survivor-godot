extends Node
## UI Audit Tool - Measure all UI components
## Week 16 Phase 1: Automated measurement of font sizes, button sizes, spacing


func audit_scene(scene_path: String) -> Dictionary:
	"""Audit all UI components in a scene"""
	var scene_resource = load(scene_path)
	if not scene_resource:
		GameLogger.error("[UIAudit] Failed to load scene", {"path": scene_path})
		return {}

	var scene = scene_resource.instantiate()
	get_tree().root.add_child(scene)

	# Wait for scene to fully initialize
	await get_tree().process_frame
	await get_tree().process_frame

	var results = {
		"scene": scene_path,
		"scene_name": scene_path.get_file().get_basename(),
		"labels": [],
		"buttons": [],
		"containers": [],
		"issues": [],
		"summary": {}
	}

	_audit_node_recursive(scene, results)
	_generate_summary(results)

	scene.queue_free()
	return results


func audit_all_scenes() -> Array[Dictionary]:
	"""Audit all UI scenes in the game"""
	var scenes = [
		"res://scenes/hub/scrapyard.tscn",
		"res://scenes/ui/barracks.tscn",
		"res://scenes/ui/character_creation.tscn",
		"res://scenes/ui/character_selection.tscn",
		"res://scenes/ui/character_card.tscn",
		"res://scenes/ui/character_details_panel.tscn",
		"res://scenes/ui/wave_complete_screen.tscn",
		"res://scenes/game/wasteland.tscn",  # For HUD audit
		"res://scenes/debug/debug_menu.tscn",
	]

	var all_results: Array[Dictionary] = []

	for scene_path in scenes:
		GameLogger.info("[UIAudit] Auditing scene", {"path": scene_path})
		var results = await audit_scene(scene_path)
		if not results.is_empty():
			all_results.append(results)

	return all_results


func _audit_node_recursive(node: Node, results: Dictionary) -> void:
	"""Recursively audit all nodes"""

	# Audit Labels
	if node is Label:
		var font_size = _get_font_size(node)
		var label_info = {
			"path": str(node.get_path()),
			"name": node.name,
			"text": node.text.substr(0, 50),  # Truncate long text
			"font_size": font_size,
		}

		# Check for issues
		if font_size < 13:
			label_info["issue"] = "TOO SMALL (< 13pt)"
			results.issues.append("Label '%s' is %dpt (< 13pt minimum)" % [node.name, font_size])
		elif font_size < 17:
			label_info["issue"] = "SMALL (< 17pt recommended for body text)"

		results.labels.append(label_info)

	# Audit Buttons
	if node is Button:
		var min_size = node.custom_minimum_size
		var font_size = _get_font_size(node)
		var actual_size = node.size if node.size.x > 0 else min_size
		var height = actual_size.y if actual_size.y > 0 else 30  # Fallback estimate

		var button_info = {
			"path": str(node.get_path()),
			"name": node.name,
			"text": node.text,
			"custom_minimum_size": min_size,
			"actual_size": actual_size,
			"height": height,
			"font_size": font_size,
		}

		# Check for issues
		if height < 44:
			button_info["issue"] = "HEIGHT < 44pt (iOS HIG minimum)"
			results.issues.append(
				"Button '%s' is %.1fpt high (< 44pt minimum)" % [node.name, height]
			)
		elif height < 60:
			button_info["issue"] = "HEIGHT < 60pt (recommended for primary buttons)"

		if font_size < 16:
			button_info["font_issue"] = "Font < 16pt"
			results.issues.append(
				"Button '%s' font is %dpt (< 16pt recommended)" % [node.name, font_size]
			)

		results.buttons.append(button_info)

	# Audit Container Spacing
	if node is BoxContainer:
		var separation = node.get_theme_constant("separation")
		if separation == 0:
			separation = 4  # Default Godot spacing

		var container_info = {
			"path": str(node.get_path()),
			"name": node.name,
			"type": node.get_class(),
			"separation": separation,
		}

		# Check for issues
		if separation < 8:
			container_info["issue"] = "TIGHT (< 8pt)"
		elif separation < 12:
			container_info["issue"] = "SMALL (< 12pt recommended)"

		results.containers.append(container_info)

	# Recurse to children
	for child in node.get_children():
		_audit_node_recursive(child, results)


func _get_font_size(node: Control) -> int:
	"""Get the effective font size for a Control node"""
	# Try theme override first
	var font_size = node.get_theme_font_size("font_size")
	if font_size > 0:
		return font_size

	# Try theme
	if node.has_theme_font_size_override("font_size"):
		font_size = node.get_theme_font_size("font_size")
		if font_size > 0:
			return font_size

	# Default Godot size
	return 16  # Godot 4.x default


func _generate_summary(results: Dictionary) -> void:
	"""Generate summary statistics"""
	var summary = {
		"total_labels": results.labels.size(),
		"total_buttons": results.buttons.size(),
		"total_containers": results.containers.size(),
		"total_issues": results.issues.size(),
		"buttons_under_44pt": 0,
		"buttons_under_60pt": 0,
		"labels_under_13pt": 0,
		"labels_under_17pt": 0,
		"containers_tight": 0,
	}

	# Count button size issues
	for button in results.buttons:
		if button.height < 44:
			summary.buttons_under_44pt += 1
		elif button.height < 60:
			summary.buttons_under_60pt += 1

	# Count label size issues
	for label in results.labels:
		if label.font_size < 13:
			summary.labels_under_13pt += 1
		elif label.font_size < 17:
			summary.labels_under_17pt += 1

	# Count spacing issues
	for container in results.containers:
		if container.separation < 12:
			summary.containers_tight += 1

	results.summary = summary


func print_audit_report(results: Dictionary) -> void:
	"""Print audit report to console"""
	print("\n" + "=".repeat(80))
	print("UI AUDIT REPORT: %s" % results.scene_name)
	print("=".repeat(80))

	var summary = results.summary
	print("\n📊 SUMMARY:")
	print("  Total Issues: %d" % summary.total_issues)
	print(
		(
			"  Labels: %d (%d under 13pt, %d under 17pt)"
			% [summary.total_labels, summary.labels_under_13pt, summary.labels_under_17pt]
		)
	)
	print(
		(
			"  Buttons: %d (%d under 44pt, %d under 60pt)"
			% [summary.total_buttons, summary.buttons_under_44pt, summary.buttons_under_60pt]
		)
	)
	print(
		"  Containers: %d (%d tight spacing)" % [summary.total_containers, summary.containers_tight]
	)

	if results.issues.size() > 0:
		print("\n⚠️  ISSUES FOUND:")
		for issue in results.issues:
			print("  - %s" % issue)

	print("\n" + "=".repeat(80))


func export_to_markdown(all_results: Array[Dictionary], output_path: String) -> void:
	"""Export all audit results to a markdown file"""
	var md = "# UI Audit Report - Week 16 Phase 1\n\n"
	md += "Generated: %s\n\n" % Time.get_datetime_string_from_system()
	md += "---\n\n"

	# Overall summary
	md += "## Summary Across All Scenes\n\n"
	var total_issues = 0
	var total_buttons_under_44 = 0
	var total_buttons_under_60 = 0
	var total_labels_under_13 = 0
	var total_labels_under_17 = 0

	for results in all_results:
		total_issues += results.summary.total_issues
		total_buttons_under_44 += results.summary.buttons_under_44pt
		total_buttons_under_60 += results.summary.buttons_under_60pt
		total_labels_under_13 += results.summary.labels_under_13pt
		total_labels_under_17 += results.summary.labels_under_17pt

	md += "- **Total Issues**: %d\n" % total_issues
	md += "- **Buttons < 44pt**: %d 🚨\n" % total_buttons_under_44
	md += "- **Buttons < 60pt**: %d ⚠️\n" % total_buttons_under_60
	md += "- **Labels < 13pt**: %d 🚨\n" % total_labels_under_13
	md += "- **Labels < 17pt**: %d ⚠️\n" % total_labels_under_17
	md += "\n---\n\n"

	# Per-scene details
	for results in all_results:
		md += "## %s\n\n" % results.scene_name
		md += "**Scene**: `%s`\n\n" % results.scene

		var summary = results.summary
		md += "### Summary\n\n"
		md += (
			"- Labels: %d (%d under 13pt, %d under 17pt)\n"
			% [summary.total_labels, summary.labels_under_13pt, summary.labels_under_17pt]
		)
		md += (
			"- Buttons: %d (%d under 44pt, %d under 60pt)\n"
			% [summary.total_buttons, summary.buttons_under_44pt, summary.buttons_under_60pt]
		)
		md += "- Issues: %d\n\n" % summary.total_issues

		# Issues
		if results.issues.size() > 0:
			md += "### Issues\n\n"
			for issue in results.issues:
				md += "- %s\n" % issue
			md += "\n"

		# Button details
		if results.buttons.size() > 0:
			md += "### Buttons\n\n"
			md += "| Name | Height | Font Size | Issues |\n"
			md += "|------|--------|-----------|--------|\n"
			for button in results.buttons:
				var issues_str = ""
				if button.has("issue"):
					issues_str += button.issue
				if button.has("font_issue"):
					if issues_str != "":
						issues_str += ", "
					issues_str += button.font_issue

				md += (
					"| %s | %.1fpt | %dpt | %s |\n"
					% [button.name, button.height, button.font_size, issues_str]
				)
			md += "\n"

		# Label details (only show problematic ones)
		var problem_labels = results.labels.filter(func(l): return l.has("issue"))
		if problem_labels.size() > 0:
			md += "### Problematic Labels\n\n"
			md += "| Name | Font Size | Text | Issue |\n"
			md += "|------|-----------|------|-------|\n"
			for label in problem_labels:
				md += (
					"| %s | %dpt | %s | %s |\n"
					% [label.name, label.font_size, label.text, label.get("issue", "")]
				)
			md += "\n"

		md += "---\n\n"

	# Save to file
	var file = FileAccess.open(output_path, FileAccess.WRITE)
	if file:
		file.store_string(md)
		file.close()
		GameLogger.info("[UIAudit] Report exported", {"path": output_path})
	else:
		GameLogger.error("[UIAudit] Failed to export report", {"path": output_path})
