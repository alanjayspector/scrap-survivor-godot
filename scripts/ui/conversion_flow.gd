extends Node
## Conversion Flow Manager
## Week 8 Phase 4: Try-before-buy monetization flow
##
## Flow:
## 1. Player requests free trial of locked character type
## 2. Create temporary trial character
## 3. Track run completion
## 4. Show post-run conversion screen with stats
## 5. Offer tier upgrade with "Unlock Forever" CTA
##
## Analytics Events:
## - tier_upgrade_viewed
## - free_trial_started
## - tier_upgrade_offered_post_trial
## - tier_upgrade_completed

signal tier_upgrade_viewed(character_type: String, required_tier: int)
signal free_trial_started(character_type: String)
signal tier_upgrade_offered_post_trial(character_type: String, run_stats: Dictionary)
signal tier_upgrade_completed(from_tier: int, to_tier: int)
signal trial_completed(character_id: String, run_stats: Dictionary)

## Trial state
var is_trial_active: bool = false
var trial_character_id: String = ""
var trial_character_type: String = ""
var trial_start_time: float = 0.0


func _ready() -> void:
	# Connect to relevant game events
	pass


## Start a free trial for a character type
## Creates a temporary character and tracks the trial state
func start_free_trial(character_type: String) -> String:
	if is_trial_active:
		GameLogger.warning("Trial already active", {"active_trial": trial_character_type})
		return ""

	# Week 18 Phase 2: Use CharacterTypeDatabase
	if not CharacterTypeDatabase.has_type(character_type):
		GameLogger.error("Invalid character type for trial", {"type": character_type})
		return ""

	var type_def = CharacterTypeDatabase.get_type(character_type)

	# Check if user tier is below required
	var user_tier = CharacterService.get_tier()
	var tier_required = type_def.get("tier_required", CharacterTypeDatabase.Tier.FREE)
	if user_tier >= tier_required:
		GameLogger.warning(
			"Trial not needed - user already has required tier",
			{"type": character_type, "user_tier": user_tier, "required_tier": tier_required}
		)
		return ""

	# Temporarily elevate user tier for character creation
	var original_tier = user_tier
	CharacterService.set_tier(tier_required)

	# Create trial character
	var trial_name = "TRIAL_%s" % type_def.display_name
	var character_id = CharacterService.create_character(trial_name, character_type)

	# Restore original tier
	CharacterService.set_tier(original_tier)

	if character_id == "":
		GameLogger.error("Failed to create trial character")
		return ""

	# Mark character as trial (add metadata)
	var character = CharacterService.get_character(character_id)
	if character:
		# Store trial flag (would normally be in character data)
		trial_character_id = character_id
		trial_character_type = character_type
		is_trial_active = true
		trial_start_time = Time.get_unix_time_from_system()

		GameLogger.info(
			"Free trial started", {"character_id": character_id, "type": character_type}
		)

		# Emit analytics event
		free_trial_started.emit(character_type)
		_track_analytics_event(
			"free_trial_started",
			{"character_type": character_type, "required_tier": type_def.tier_required}
		)

	return character_id


## End the trial run and show conversion screen
func end_trial_run(run_stats: Dictionary) -> void:
	if not is_trial_active:
		GameLogger.warning("No active trial to end")
		return

	var trial_duration = Time.get_unix_time_from_system() - trial_start_time

	GameLogger.info(
		"Trial run completed",
		{
			"character_id": trial_character_id,
			"type": trial_character_type,
			"duration": trial_duration,
			"stats": run_stats
		}
	)

	# Emit trial completed event
	trial_completed.emit(trial_character_id, run_stats)

	# Show conversion screen
	_show_post_trial_conversion_screen(run_stats)

	# Emit analytics event
	tier_upgrade_offered_post_trial.emit(trial_character_type, run_stats)
	_track_analytics_event(
		"tier_upgrade_offered_post_trial",
		{
			"character_type": trial_character_type,
			"run_stats": run_stats,
			"trial_duration": trial_duration
		}
	)


## Delete trial character (called after conversion screen)
func cleanup_trial_character() -> void:
	if trial_character_id != "":
		CharacterService.delete_character(trial_character_id)
		GameLogger.info("Trial character deleted", {"id": trial_character_id})

	trial_character_id = ""
	trial_character_type = ""
	is_trial_active = false


## User clicked "Unlock Forever" button
func request_tier_upgrade(target_tier: int) -> void:
	var current_tier = CharacterService.get_tier()

	if target_tier <= current_tier:
		GameLogger.warning(
			"Target tier not higher than current tier",
			{"current": current_tier, "target": target_tier}
		)
		return

	GameLogger.info("Tier upgrade requested", {"from": current_tier, "to": target_tier})

	# Emit analytics event
	tier_upgrade_viewed.emit(trial_character_type, target_tier)
	_track_analytics_event(
		"tier_upgrade_viewed",
		{
			"character_type": trial_character_type,
			"from_tier": current_tier,
			"to_tier": target_tier,
			"context": "post_trial" if is_trial_active else "character_selection"
		}
	)

	# Open tier upgrade purchase flow (would integrate with payment system)
	_open_tier_upgrade_purchase(target_tier)


## Simulate tier upgrade completion (would be called by payment system)
func complete_tier_upgrade(new_tier: int) -> void:
	var old_tier = CharacterService.get_tier()
	CharacterService.set_tier(new_tier)

	GameLogger.info("Tier upgrade completed", {"from": old_tier, "to": new_tier})

	# Emit analytics event
	tier_upgrade_completed.emit(old_tier, new_tier)
	_track_analytics_event(
		"tier_upgrade_completed",
		{"from_tier": old_tier, "to_tier": new_tier, "upgrade_type": _get_tier_name(new_tier)}
	)

	# Convert trial character to permanent if applicable
	if is_trial_active:
		_convert_trial_to_permanent()


func _show_post_trial_conversion_screen(run_stats: Dictionary) -> void:
	# Create conversion modal
	var modal = _create_conversion_modal(run_stats)

	# Add to scene tree (would normally add to UI layer)
	if get_tree().root:
		get_tree().root.add_child(modal)


func _create_conversion_modal(run_stats: Dictionary) -> Control:
	"""Create conversion modal following Parent-First protocol for iOS safety"""
	# Week 18 Phase 2: Use CharacterTypeDatabase
	var type_def = CharacterTypeDatabase.get_type(trial_character_type)

	# Create modal container (will be parented by caller)
	var modal = PanelContainer.new()

	# Layout
	var vbox = VBoxContainer.new()
	modal.add_child(vbox)  # Parent FIRST
	vbox.layout_mode = 2  # Explicit Mode 2 (Container) for iOS

	# Title
	var title = Label.new()
	vbox.add_child(title)  # Parent FIRST
	title.layout_mode = 2  # Explicit Mode 2 (Container) for iOS
	title.text = "Trial Complete!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)

	# Stats summary
	var stats_label = Label.new()
	vbox.add_child(stats_label)  # Parent FIRST
	stats_label.layout_mode = 2  # Explicit Mode 2 (Container) for iOS
	stats_label.text = _format_run_stats(run_stats)
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Character type highlight
	var char_type_label = Label.new()
	vbox.add_child(char_type_label)  # Parent FIRST
	char_type_label.layout_mode = 2  # Explicit Mode 2 (Container) for iOS
	char_type_label.text = "You played as: %s" % type_def.display_name
	char_type_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	char_type_label.add_theme_font_size_override("font_size", 24)

	# Benefits text
	var benefits_label = Label.new()
	vbox.add_child(benefits_label)  # Parent FIRST
	benefits_label.layout_mode = 2  # Explicit Mode 2 (Container) for iOS
	benefits_label.text = (
		"Unlock %s forever to:\n" % type_def.display_name
		+ "• Keep all progress\n"
		+ "• Play unlimited runs\n"
		+ "• Access exclusive perks"
	)
	benefits_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Buttons
	var buttons_hbox = HBoxContainer.new()
	vbox.add_child(buttons_hbox)  # Parent FIRST
	buttons_hbox.layout_mode = 2  # Explicit Mode 2 (Container) for iOS
	buttons_hbox.alignment = BoxContainer.ALIGNMENT_CENTER

	var unlock_btn = Button.new()
	buttons_hbox.add_child(unlock_btn)  # Parent FIRST
	unlock_btn.layout_mode = 2  # Explicit Mode 2 (Container) for iOS
	unlock_btn.text = "Unlock %s Forever" % _get_tier_name(type_def.tier_required)
	unlock_btn.custom_minimum_size = Vector2(250, 60)
	unlock_btn.pressed.connect(_on_unlock_forever_pressed.bind(type_def.tier_required))

	var maybe_later_btn = Button.new()
	buttons_hbox.add_child(maybe_later_btn)  # Parent FIRST
	maybe_later_btn.layout_mode = 2  # Explicit Mode 2 (Container) for iOS
	maybe_later_btn.text = "Maybe Later"
	maybe_later_btn.custom_minimum_size = Vector2(150, 60)
	maybe_later_btn.pressed.connect(_on_maybe_later_pressed.bind(modal))

	# Configure modal AFTER all children are parented
	modal.name = "ConversionModal"
	modal.custom_minimum_size = Vector2(600, 400)
	modal.position = Vector2((get_viewport().size.x - 600) / 2, (get_viewport().size.y - 400) / 2)

	return modal


func _format_run_stats(stats: Dictionary) -> String:
	var lines: Array[String] = []
	lines.append("Run Statistics:")

	if stats.has("wave_reached"):
		lines.append("Wave Reached: %d" % stats.wave_reached)
	if stats.has("enemies_killed"):
		lines.append("Enemies Killed: %d" % stats.enemies_killed)
	if stats.has("scrap_collected"):
		lines.append("Scrap Collected: %d" % stats.scrap_collected)
	if stats.has("survival_time"):
		lines.append("Survival Time: %.1fs" % stats.survival_time)

	return "\n".join(lines)


func _convert_trial_to_permanent() -> void:
	if trial_character_id == "":
		return

	# Remove "TRIAL_" prefix from name
	var character = CharacterService.get_character(trial_character_id)
	if character:
		var new_name = character.name.replace("TRIAL_", "")
		CharacterService.update_character(trial_character_id, {"name": new_name})

		GameLogger.info(
			"Trial character converted to permanent",
			{"id": trial_character_id, "new_name": new_name}
		)

	# Clear trial state
	is_trial_active = false
	trial_character_id = ""
	trial_character_type = ""


func _open_tier_upgrade_purchase(target_tier: int) -> void:
	# TODO: Integrate with payment system (Supabase, Stripe, etc.)
	GameLogger.info("Opening tier upgrade purchase flow", {"target_tier": target_tier})

	# For now, show a placeholder message
	GameLogger.info("Tier upgrade purchase UI", {"message": "Payment flow would open here"})


func _on_unlock_forever_pressed(required_tier: int) -> void:
	request_tier_upgrade(required_tier)


func _on_maybe_later_pressed(modal: Control) -> void:
	GameLogger.info("User declined tier upgrade", {"character_type": trial_character_type})

	# Track analytics
	_track_analytics_event(
		"tier_upgrade_declined", {"character_type": trial_character_type, "context": "post_trial"}
	)

	# Cleanup trial character
	cleanup_trial_character()

	# Close modal
	modal.queue_free()


func _track_analytics_event(event_name: String, properties: Dictionary) -> void:
	# TODO: Integrate with analytics service (e.g., AnalyticsService)
	GameLogger.info("Analytics Event", {"event": event_name, "properties": properties})


func _get_tier_name(tier: int) -> String:
	match tier:
		CharacterService.UserTier.FREE:
			return "FREE"
		CharacterService.UserTier.PREMIUM:
			return "PREMIUM"
		CharacterService.UserTier.SUBSCRIPTION:
			return "SUBSCRIPTION"
	return "UNKNOWN"


## Public API
func is_character_on_trial(character_id: String) -> bool:
	return is_trial_active and trial_character_id == character_id


func get_trial_character_type() -> String:
	return trial_character_type if is_trial_active else ""
