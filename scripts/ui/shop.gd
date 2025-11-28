extends Control
## Shop - Hub shop scene for purchasing items
##
## Week 18 Phase 6: Hub Shop UI
## Location: Hub -> Shop (per SHOPS-SYSTEM.md)
##
## Features:
## - Display 6 shop items with rarity colors
## - Refresh countdown timer (4-hour cycle)
## - Purchase items with scrap
## - Reroll shop with escalating costs
## - Empty stock auto-refresh with notification
## - Back navigation to scrapyard hub

const SHOP_ITEM_CARD_SCENE = preload("res://scenes/ui/components/shop_item_card.tscn")
const BUTTON_CLICK_SOUND: AudioStream = preload("res://assets/audio/ui/button_click.ogg")
const THEME_HELPER = preload("res://scripts/ui/theme/theme_helper.gd")
const UI_ICONS = preload("res://scripts/ui/theme/ui_icons.gd")

## Node references
@onready var _title_label: Label = $ScreenContainer/VBoxContainer/HeaderContainer/TitleLabel
@onready
var _scrap_label: Label = $ScreenContainer/VBoxContainer/HeaderContainer/ScrapContainer/ScrapLabel
@onready
var _refresh_label: Label = $ScreenContainer/VBoxContainer/HeaderContainer/InfoRow/RefreshLabel
@onready
var _reroll_info_label: Label = $ScreenContainer/VBoxContainer/HeaderContainer/InfoRow/RerollInfoLabel
# gdlint: disable=max-line-length
@onready
var _item_grid: GridContainer = $ScreenContainer/VBoxContainer/ItemGridContainer/ScrollContainer/CenterContainer/ItemGrid
# gdlint: enable=max-line-length
@onready var _reroll_button: Button = $ScreenContainer/VBoxContainer/ButtonsContainer/RerollButton
@onready var _back_button: Button = $ScreenContainer/VBoxContainer/ButtonsContainer/BackButton
@onready var _audio_player: AudioStreamPlayer = $AudioStreamPlayer

## Refresh timer
var _refresh_timer: Timer

## Track item cards for updates
var _item_cards: Array[ShopItemCard] = []


func _ready() -> void:
	GameLogger.info("[Shop] Initializing shop scene")

	# Connect signals
	_connect_signals()

	# Setup refresh timer (update countdown every second)
	_setup_refresh_timer()

	# Load shop items
	_load_shop_items()

	# Update UI
	_update_scrap_display()
	_update_refresh_display()
	_update_reroll_display()

	# Apply button styling
	THEME_HELPER.apply_button_style(_reroll_button, THEME_HELPER.ButtonStyle.PRIMARY)
	THEME_HELPER.apply_button_style(_back_button, THEME_HELPER.ButtonStyle.SECONDARY)
	UI_ICONS.apply_button_icon(_back_button, UI_ICONS.Icon.BACK)

	# Add button animations
	THEME_HELPER.add_button_animation(_reroll_button)
	THEME_HELPER.add_button_animation(_back_button)

	# Check for empty stock refresh on entry
	_check_empty_stock_refresh()

	GameLogger.info("[Shop] Shop scene ready")


func _exit_tree() -> void:
	if _refresh_timer:
		_refresh_timer.queue_free()


func _connect_signals() -> void:
	"""Connect button signals"""
	_reroll_button.pressed.connect(_on_reroll_pressed)
	_back_button.pressed.connect(_on_back_pressed)

	# Connect to ShopService signals
	if ShopService:
		ShopService.shop_refreshed.connect(_on_shop_refreshed)
		ShopService.purchase_failed.connect(_on_purchase_failed)

	# Connect to BankingService for balance updates
	if BankingService:
		BankingService.currency_changed.connect(_on_currency_changed)


func _setup_refresh_timer() -> void:
	"""Setup timer to update refresh countdown"""
	_refresh_timer = Timer.new()
	_refresh_timer.wait_time = 1.0
	_refresh_timer.autostart = true
	_refresh_timer.timeout.connect(_on_refresh_timer_tick)
	add_child(_refresh_timer)


func _load_shop_items() -> void:
	"""Load and display current shop items"""
	# Clear existing cards
	for card in _item_cards:
		card.queue_free()
	_item_cards.clear()

	# Get items from ShopService
	var items = ShopService.get_shop_items()

	GameLogger.info("[Shop] Loading shop items", {"count": items.size()})

	# Create cards for each item
	for item in items:
		var card = SHOP_ITEM_CARD_SCENE.instantiate() as ShopItemCard
		_item_grid.add_child(card)
		card.setup(item)
		card.purchase_requested.connect(_on_purchase_requested)
		_item_cards.append(card)


func _update_scrap_display() -> void:
	"""Update the scrap balance display"""
	var scrap = BankingService.get_balance(BankingService.CurrencyType.SCRAP)
	_scrap_label.text = "%d" % scrap


func _update_refresh_display() -> void:
	"""Update the refresh countdown display"""
	var seconds = ShopService.get_time_until_refresh()

	if seconds <= 0:
		_refresh_label.text = "Refreshing..."
		# Trigger refresh
		ShopService.generate_shop()
	else:
		var hours = seconds / 3600
		var minutes = (seconds % 3600) / 60
		var secs = seconds % 60

		if hours > 0:
			_refresh_label.text = "Refresh: %dh %dm" % [hours, minutes]
		elif minutes > 0:
			_refresh_label.text = "Refresh: %dm %ds" % [minutes, secs]
		else:
			_refresh_label.text = "Refresh: %ds" % secs


func _update_reroll_display() -> void:
	"""Update reroll button and info label"""
	var character_id = CharacterService.get_active_character_id()
	var cost = ShopService.get_reroll_cost(character_id)
	var reroll_count = ShopService.get_reroll_count()

	# Update info label with reroll count
	_reroll_info_label.text = "Rerolls: %d" % reroll_count

	# Update button text with cost
	_reroll_button.text = "Reroll (%d scrap)" % cost

	# Disable if can't afford
	var scrap = BankingService.get_balance(BankingService.CurrencyType.SCRAP)
	_reroll_button.disabled = scrap < cost


func _check_empty_stock_refresh() -> void:
	"""Check if shop is empty and trigger free refresh"""
	if ShopService.check_empty_stock_refresh():
		# Show notification
		ModalFactory.show_alert(
			self,
			"Shop Refreshed!",
			"The shop was empty, so it has been restocked for FREE!",
			Callable()
		)
		GameLogger.info("[Shop] Empty stock refresh triggered")


func _play_button_sound() -> void:
	"""Play button click sound"""
	if _audio_player and BUTTON_CLICK_SOUND:
		_audio_player.stream = BUTTON_CLICK_SOUND
		_audio_player.play()


func _on_purchase_requested(item_id: String) -> void:
	"""Handle purchase request from item card"""
	_play_button_sound()
	HapticManager.light()

	var character_id = CharacterService.get_active_character_id()

	# Validate character exists
	if character_id.is_empty():
		ModalFactory.show_alert(
			self, "No Character", "Select a character at the Barracks first.", Callable()
		)
		return

	# Get item for confirmation
	var item = ShopService.get_shop_item_by_id(item_id)
	if item.is_empty():
		return

	var price = ShopService.calculate_purchase_price(character_id, item.get("base_price", 0))

	# Show confirmation dialog
	var confirm_text = "Purchase %s for %d scrap?" % [item.get("name", "item"), price]
	ModalFactory.show_confirmation(
		self,
		"Confirm Purchase",
		confirm_text,
		func(): _execute_purchase(character_id, item_id),
		Callable(),
		"Purchase"
	)


func _execute_purchase(character_id: String, item_id: String) -> void:
	"""Execute the purchase after confirmation"""
	var result = ShopService.purchase_item(character_id, item_id)

	if not result.is_empty():
		# Purchase successful
		GameLogger.info("[Shop] Purchase successful", {"item_id": item_id})
		HapticManager.medium()

		# Mark card as sold
		for card in _item_cards:
			if card.get_item_id() == item_id:
				card.mark_as_sold()
				break

		# Add to inventory
		if InventoryService:
			var instance_id = InventoryService.add_item(character_id, item_id)
			if instance_id.is_empty():
				GameLogger.warning("[Shop] Failed to add item to inventory", {"item_id": item_id})
				ModalFactory.show_alert(
					self, "Inventory Full", "Could not add item to inventory.", Callable()
				)

		# Update displays
		_update_scrap_display()
		_update_reroll_display()

		# Check for empty stock refresh
		_check_empty_stock_refresh()
	else:
		GameLogger.warning("[Shop] Purchase failed", {"item_id": item_id})


func _on_reroll_pressed() -> void:
	"""Handle reroll button press"""
	_play_button_sound()
	HapticManager.light()

	var character_id = CharacterService.get_active_character_id()
	var cost = ShopService.get_reroll_cost(character_id)

	# Confirm reroll
	var confirm_text = "Reroll shop for %d scrap?\nThis will replace all items." % cost
	ModalFactory.show_confirmation(
		self,
		"Confirm Reroll",
		confirm_text,
		func(): _execute_reroll(character_id),
		Callable(),
		"Reroll"
	)


func _execute_reroll(character_id: String) -> void:
	"""Execute reroll after confirmation"""
	var result = ShopService.reroll_shop(character_id)

	if not result.is_empty():
		GameLogger.info("[Shop] Reroll successful", {"new_item_count": result.size()})
		HapticManager.medium()
		# Items will be reloaded via shop_refreshed signal
		_update_reroll_display()
	else:
		GameLogger.warning("[Shop] Reroll failed")


func _on_back_pressed() -> void:
	"""Handle back button - return to scrapyard"""
	_play_button_sound()
	HapticManager.light()

	if is_instance_valid(Analytics):
		Analytics.hub_button_pressed("Shop_Back")

	GameLogger.info("[Shop] Returning to scrapyard")
	get_tree().change_scene_to_file("res://scenes/hub/scrapyard.tscn")


func _on_shop_refreshed(_items: Array) -> void:
	"""Handle shop refresh signal"""
	_load_shop_items()
	_update_refresh_display()
	_update_reroll_display()


func _on_purchase_failed(reason: String) -> void:
	"""Handle purchase failure"""
	ModalFactory.show_alert(self, "Purchase Failed", reason, Callable())


func _on_currency_changed(_currency_type: BankingService.CurrencyType, _new_balance: int) -> void:
	"""Handle currency change from BankingService"""
	_update_scrap_display()
	_update_reroll_display()


func _on_refresh_timer_tick() -> void:
	"""Update refresh countdown every second"""
	_update_refresh_display()

	# Check if refresh is due
	if ShopService.should_refresh():
		ShopService.generate_shop()
