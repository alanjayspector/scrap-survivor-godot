extends GutTest
## Unit tests for CharacterTypeCard component
##
## Week 17 Phase 1: Tests for unified card component
##
## Test Coverage:
## - setup_type() mode (Character Creation)
## - setup_player() mode (Barracks)
## - Selection state and glow animation
## - Lock state for tier-restricted types
## - Signal emissions (card_pressed, card_long_pressed)
## - Cleanup on exit

const CharacterTypeCardScene = preload("res://scenes/ui/components/character_type_card.tscn")

var _card: Node = null
var _original_tier: int = 0


func before_each() -> void:
	# Store original tier to restore after tests
	_original_tier = CharacterService.get_tier()
	# Reset to FREE tier for consistent tests
	CharacterService.set_tier(CharacterService.UserTier.FREE)

	# Create fresh card instance
	_card = CharacterTypeCardScene.instantiate()
	add_child_autofree(_card)
	# Wait for _ready to complete
	await get_tree().process_frame


func after_each() -> void:
	# Restore original tier
	CharacterService.set_tier(_original_tier)
	_card = null


## ============================================================================
## SETUP_TYPE TESTS (Character Creation Mode)
## ============================================================================


func test_setup_type_scavenger_sets_correct_identifier() -> void:
	_card.setup_type("scavenger")

	assert_eq(_card.get_identifier(), "scavenger", "Identifier should be 'scavenger'")
	assert_eq(_card.get_mode(), _card.CardMode.TYPE, "Mode should be TYPE")


func test_setup_type_scavenger_displays_correct_name() -> void:
	_card.setup_type("scavenger")

	var name_label = _card.get_node("ContentContainer/VBoxContainer/NameLabel")
	assert_eq(name_label.text, "Scavenger", "Name label should show 'Scavenger'")


func test_setup_type_scavenger_displays_stat_preview() -> void:
	_card.setup_type("scavenger")

	var sub_label = _card.get_node("ContentContainer/VBoxContainer/SubLabel")
	# Scavenger has scavenging: 5, pickup_range: 20
	assert_true(sub_label.text.contains("+5"), "Stat preview should contain '+5'")


func test_setup_type_scavenger_shows_silhouette() -> void:
	_card.setup_type("scavenger")

	var portrait_rect = _card.get_node("ContentContainer/VBoxContainer/PortraitRect")
	var portrait_color = _card.get_node("ContentContainer/VBoxContainer/PortraitColorRect")

	assert_true(portrait_rect.visible, "PortraitRect should be visible for type mode")
	assert_false(portrait_color.visible, "PortraitColorRect should be hidden for type mode")
	assert_not_null(portrait_rect.texture, "Silhouette texture should be loaded")


func test_setup_type_scavenger_unlocked_at_free_tier() -> void:
	CharacterService.set_tier(CharacterService.UserTier.FREE)
	_card.setup_type("scavenger")

	assert_false(_card.is_locked(), "Scavenger should be unlocked at FREE tier")


func test_setup_type_tank_locked_at_free_tier() -> void:
	CharacterService.set_tier(CharacterService.UserTier.FREE)
	_card.setup_type("tank")

	assert_true(_card.is_locked(), "Tank should be locked at FREE tier")

	var lock_overlay = _card.get_node("LockOverlay")
	assert_true(lock_overlay.visible, "Lock overlay should be visible")


func test_setup_type_tank_unlocked_at_premium_tier() -> void:
	CharacterService.set_tier(CharacterService.UserTier.PREMIUM)
	_card.setup_type("tank")

	assert_false(_card.is_locked(), "Tank should be unlocked at PREMIUM tier")


func test_setup_type_commando_locked_at_premium_tier() -> void:
	CharacterService.set_tier(CharacterService.UserTier.PREMIUM)
	_card.setup_type("commando")

	assert_true(_card.is_locked(), "Commando should be locked at PREMIUM tier")


func test_setup_type_commando_unlocked_at_subscription_tier() -> void:
	CharacterService.set_tier(CharacterService.UserTier.SUBSCRIPTION)
	_card.setup_type("commando")

	assert_false(_card.is_locked(), "Commando should be unlocked at SUBSCRIPTION tier")


func test_setup_type_all_types_load_silhouettes() -> void:
	var types = ["scavenger", "tank", "commando", "mutant"]

	for type_id in types:
		# Create fresh card for each type
		var card = CharacterTypeCardScene.instantiate()
		add_child_autofree(card)
		await get_tree().process_frame

		CharacterService.set_tier(CharacterService.UserTier.SUBSCRIPTION)
		card.setup_type(type_id)

		var portrait_rect = card.get_node("ContentContainer/VBoxContainer/PortraitRect")
		assert_not_null(portrait_rect.texture, "Silhouette for '%s' should load" % type_id)


## ============================================================================
## SETUP_PLAYER TESTS (Barracks Mode)
## ============================================================================


func test_setup_player_sets_correct_identifier() -> void:
	var char_data = {
		"id": "test_char_123", "name": "TestHero", "character_type": "scavenger", "level": 5
	}
	_card.setup_player(char_data)

	assert_eq(_card.get_identifier(), "test_char_123", "Identifier should match character ID")
	assert_eq(_card.get_mode(), _card.CardMode.PLAYER, "Mode should be PLAYER")


func test_setup_player_displays_character_name() -> void:
	var char_data = {"id": "test_1", "name": "Rusty", "character_type": "scavenger", "level": 3}
	_card.setup_player(char_data)

	var name_label = _card.get_node("ContentContainer/VBoxContainer/NameLabel")
	assert_eq(name_label.text, "Rusty", "Name label should show character name")


func test_setup_player_displays_type_and_level() -> void:
	var char_data = {"id": "test_1", "name": "Rusty", "character_type": "tank", "level": 7}
	_card.setup_player(char_data)

	var sub_label = _card.get_node("ContentContainer/VBoxContainer/SubLabel")
	assert_true(sub_label.text.contains("Tank"), "Sub label should contain type name")
	assert_true(sub_label.text.contains("7"), "Sub label should contain level")


func test_setup_player_shows_color_rect_not_texture() -> void:
	var char_data = {"id": "test_1", "name": "Hero", "character_type": "scavenger", "level": 1}
	_card.setup_player(char_data)

	var portrait_rect = _card.get_node("ContentContainer/VBoxContainer/PortraitRect")
	var portrait_color = _card.get_node("ContentContainer/VBoxContainer/PortraitColorRect")

	assert_false(portrait_rect.visible, "PortraitRect should be hidden for player mode")
	assert_true(portrait_color.visible, "PortraitColorRect should be visible for player mode")


func test_setup_player_uses_type_color_for_portrait() -> void:
	var char_data = {"id": "test_1", "name": "Hero", "character_type": "tank", "level": 1}
	_card.setup_player(char_data)

	var portrait_color = _card.get_node("ContentContainer/VBoxContainer/PortraitColorRect")
	# Tank color from CharacterService is Color(0.3, 0.5, 0.3) - olive green
	assert_almost_eq(portrait_color.color.r, 0.3, 0.1, "Portrait should use tank red channel")
	assert_almost_eq(portrait_color.color.g, 0.5, 0.1, "Portrait should use tank green channel")


func test_setup_player_never_locked() -> void:
	CharacterService.set_tier(CharacterService.UserTier.FREE)
	# Even a "commando" type player character should never be locked
	var char_data = {"id": "test_1", "name": "Hero", "character_type": "commando", "level": 1}
	_card.setup_player(char_data)

	assert_false(_card.is_locked(), "Player cards should never be locked")


## ============================================================================
## SELECTION STATE TESTS
## ============================================================================


func test_set_selected_true_shows_glow() -> void:
	_card.setup_type("scavenger")
	_card.set_selected(true)

	assert_true(_card.is_selected(), "Card should report as selected")

	var glow_panel = _card.get_node("GlowPanel")
	assert_true(glow_panel.visible, "Glow panel should be visible when selected")


func test_set_selected_false_hides_glow() -> void:
	_card.setup_type("scavenger")
	_card.set_selected(true)
	_card.set_selected(false)

	assert_false(_card.is_selected(), "Card should report as not selected")

	var glow_panel = _card.get_node("GlowPanel")
	assert_false(glow_panel.visible, "Glow panel should be hidden when not selected")


func test_set_selected_shows_badge() -> void:
	_card.setup_type("scavenger")
	_card.set_selected(true)

	var badge = _card.get_node("ContentContainer/VBoxContainer/BadgeContainer/SelectionBadge")
	assert_true(badge.visible, "Selection badge should be visible when selected")


func test_set_selected_false_hides_badge() -> void:
	_card.setup_type("scavenger")
	_card.set_selected(true)
	_card.set_selected(false)

	var badge = _card.get_node("ContentContainer/VBoxContainer/BadgeContainer/SelectionBadge")
	assert_false(badge.visible, "Selection badge should be hidden when not selected")


## ============================================================================
## LOCK STATE TESTS
## ============================================================================


func test_set_locked_shows_overlay() -> void:
	_card.setup_type("scavenger")
	_card.set_locked(true, CharacterService.UserTier.PREMIUM)

	assert_true(_card.is_locked(), "Card should report as locked")

	var lock_overlay = _card.get_node("LockOverlay")
	assert_true(lock_overlay.visible, "Lock overlay should be visible")


func test_set_locked_disables_button() -> void:
	_card.setup_type("scavenger")
	_card.set_locked(true, CharacterService.UserTier.PREMIUM)

	assert_true(_card.disabled, "Button should be disabled when locked")


func test_set_locked_false_enables_button() -> void:
	_card.setup_type("scavenger")
	_card.set_locked(true, CharacterService.UserTier.PREMIUM)
	_card.set_locked(false, 0)

	assert_false(_card.disabled, "Button should be enabled when unlocked")


func test_lock_overlay_shows_premium_text() -> void:
	_card.setup_type("tank")
	_card.set_locked(true, CharacterService.UserTier.PREMIUM)

	var lock_label = _card.get_node("LockOverlay/LockIconLabel")
	assert_true(lock_label.text.contains("Premium"), "Lock label should mention Premium")


func test_lock_overlay_shows_subscriber_text() -> void:
	_card.setup_type("commando")
	_card.set_locked(true, CharacterService.UserTier.SUBSCRIPTION)

	var lock_label = _card.get_node("LockOverlay/LockIconLabel")
	assert_true(lock_label.text.contains("Subscriber"), "Lock label should mention Subscriber")


## ============================================================================
## SIGNAL TESTS
## ============================================================================


func test_card_pressed_signal_emitted_on_press() -> void:
	_card.setup_type("scavenger")

	# Use GUT's built-in signal watching for reliable signal detection
	watch_signals(_card)

	# Simulate button press by calling the handler directly
	_card._on_pressed()
	await get_tree().process_frame

	assert_signal_emitted(_card, "card_pressed", "card_pressed signal should be emitted")
	var signal_params = get_signal_parameters(_card, "card_pressed", 0)
	assert_eq(signal_params[0], "scavenger", "Signal should include correct identifier")


func test_card_pressed_not_emitted_when_locked() -> void:
	_card.setup_type("tank")
	# Tank is locked at FREE tier

	var signal_received = false
	_card.card_pressed.connect(func(_id): signal_received = true)

	# Try to press - but card is locked
	_card._on_pressed()
	await get_tree().process_frame

	assert_false(signal_received, "card_pressed should NOT emit when locked")


## ============================================================================
## EDGE CASE TESTS
## ============================================================================


func test_setup_type_unknown_type_handles_gracefully() -> void:
	# Should not crash, just log warning
	_card.setup_type("unknown_type")

	# Card should still be in a valid state
	assert_eq(_card.get_identifier(), "", "Unknown type should result in empty identifier")


func test_setup_player_with_missing_fields_uses_defaults() -> void:
	var minimal_data = {"id": "min_1"}
	_card.setup_player(minimal_data)

	var name_label = _card.get_node("ContentContainer/VBoxContainer/NameLabel")
	assert_eq(name_label.text, "Unknown", "Missing name should default to 'Unknown'")


func test_multiple_setup_calls_update_correctly() -> void:
	_card.setup_type("scavenger")
	assert_eq(_card.get_identifier(), "scavenger")

	_card.setup_type("tank")
	assert_eq(_card.get_identifier(), "tank", "Second setup should update identifier")
	assert_eq(_card.get_mode(), _card.CardMode.TYPE, "Mode should still be TYPE")


func test_mode_switch_type_to_player() -> void:
	_card.setup_type("scavenger")
	assert_eq(_card.get_mode(), _card.CardMode.TYPE)

	var char_data = {"id": "switch_test", "name": "Switcher", "character_type": "tank", "level": 1}
	_card.setup_player(char_data)

	assert_eq(_card.get_mode(), _card.CardMode.PLAYER, "Mode should switch to PLAYER")
	assert_eq(_card.get_identifier(), "switch_test", "Identifier should update")


## ============================================================================
## ANIMATION STATE TESTS (Verify state, not visual)
## ============================================================================


func test_glow_timer_created_on_selection() -> void:
	_card.setup_type("scavenger")
	_card.set_selected(true)

	# Check that glow timer exists and is running
	var glow_timer = _card._glow_timer
	assert_not_null(glow_timer, "Glow timer should be created")
	assert_false(glow_timer.is_stopped(), "Glow timer should be running")


func test_glow_timer_stopped_on_deselection() -> void:
	_card.setup_type("scavenger")
	_card.set_selected(true)
	_card.set_selected(false)

	var glow_timer = _card._glow_timer
	assert_true(glow_timer.is_stopped(), "Glow timer should be stopped")


func test_tap_animation_state_resets() -> void:
	_card.setup_type("scavenger")

	# Trigger tap animation
	_card._animate_tap()
	assert_true(_card._is_animating_tap, "Should be animating after tap")

	# Wait for animation to complete (80ms + 120ms = 200ms, add buffer)
	await get_tree().create_timer(0.3).timeout

	assert_false(_card._is_animating_tap, "Animation should complete")
	assert_eq(_card._tap_phase, 0, "Tap phase should reset to 0")
