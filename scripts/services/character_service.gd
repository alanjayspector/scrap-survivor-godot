extends Node
## CharacterService - Character management with progression, slots, and perk hooks
##
## Week 6 Days 4-5: Character CRUD with tier-based slots and perk integration
##
## Responsibilities:
## - Character CRUD (create, read, update, delete)
## - Active character tracking
## - Tier-based character slots (FREE=3, PREMIUM=10, SUBSCRIPTION=unlimited)
## - Level progression (XP tracking, level up)
## - SaveManager integration (serialize/deserialize)
## - 6 perk hooks (character_create_pre/post, character_level_up_pre/post, character_death_pre/post)
##
## Based on: docs/core-architecture/PERKS-ARCHITECTURE.md (lines 78-173)

## User tier levels (matches TierService.ts and BankingService)
enum UserTier { FREE, PREMIUM, SUBSCRIPTION }

## Character slot limits per tier (from docs/tier-experiences/)
const SLOT_LIMITS = {
	UserTier.FREE: 3,  # Free tier: 3 character slots
	UserTier.PREMIUM: 15,  # Premium tier: 15 character slots (+ purchasable slot packs)
	UserTier.SUBSCRIPTION: 50,  # Subscription tier: 50 active character slots (+ 200 Hall of Fame archived slots)
}

## XP progression constants (linear for simplicity, can change to exponential later)
const XP_PER_LEVEL = 100  # Level 2 = 100 XP, Level 3 = 200 XP, etc.

## Default character type (Week 6: single type, expand in Week 7+)
const DEFAULT_CHARACTER_TYPE = "scavenger"

## Character type definitions are now in CharacterTypeDatabase (Week 18 Phase 2)
## Access via: CharacterTypeDatabase.get_type(type_id)
## Valid types: scavenger, rustbucket, hotshot, tinkerer, salvager, overclocked

## Default base stats for new characters (Week 7: expanded from 8 to 14 stats)
const DEFAULT_BASE_STATS = {
	# Core Survival Stats (4)
	"max_hp": 100,
	"hp_regen": 0,  # HP per second during waves
	"life_steal": 0.0,  # % damage converted to HP (0-90% cap)
	"armor": 0,
	# Offense Stats (6)
	"damage": 10,
	"melee_damage": 0,  # Bonus damage for melee weapons only
	"ranged_damage": 0,  # Bonus damage for ranged weapons only
	"attack_speed": 0.0,  # % cooldown reduction for weapons
	"crit_chance": 0.05,  # 5%
	"resonance": 0,  # Drives aura effectiveness (NEW CONCEPT)
	# Defense Stats (1)
	"dodge": 0.0,  # 0%
	# Utility Stats (3)
	"speed": 200,
	"luck": 0,
	"pickup_range": 100,
	"scavenging": 0  # % currency multiplier (scrap, components, nanites) - cap +50%
}

## Stat gains per level up (Week 7: added scavenging for economy growth)
## +5 HP, +2 damage, +1 armor (diminishing returns), +1 scavenging (economy growth)
const LEVEL_UP_STAT_GAINS = {"max_hp": 5, "damage": 2, "armor": 1, "scavenging": 1}

## Perk hook signals (as per PERKS-ARCHITECTURE.md)
signal character_create_pre(context: Dictionary)
signal character_create_post(context: Dictionary)
signal character_level_up_pre(context: Dictionary)
signal character_level_up_post(context: Dictionary)
signal character_death_pre(context: Dictionary)
signal character_death_post(context: Dictionary)

## Service state signals
signal character_created(character: Dictionary)
signal character_deleted(character_id: String)
signal active_character_changed(character_id: String)
signal character_stats_changed(character_id: String)
signal state_loaded

## Character storage (Dictionary keyed by character_id)
var characters: Dictionary = {}

## Active character ID (currently selected character)
var active_character_id: String = ""

## Current user tier (set by TierService, defaults to FREE)
var current_tier: UserTier = UserTier.FREE

## Next available character ID
var _next_character_id: int = 1


## Create a new character
## Returns character_id on success, empty string on failure
func create_character(character_name: String, character_type: String = "scavenger") -> String:
	# Validate name
	if character_name.strip_edges().is_empty():
		GameLogger.warning("Cannot create character with empty name")
		return ""

	# Validate character type exists (Week 18: use CharacterTypeDatabase)
	if not CharacterTypeDatabase.has_type(character_type):
		GameLogger.error("Invalid character type", {"type": character_type})
		return ""

	# Get type definition from database
	var type_def = CharacterTypeDatabase.get_type(character_type)

	# Check tier restrictions
	var tier_required = type_def.get("tier_required", CharacterTypeDatabase.Tier.FREE)
	if tier_required > current_tier:
		GameLogger.warning(
			"Character type requires higher tier",
			{"type": character_type, "required": tier_required, "current": current_tier}
		)
		return ""

	# Check slot limits
	if not can_create_character():
		GameLogger.warning(
			"Cannot create character: slot limit reached",
			{"tier": current_tier, "count": characters.size()}
		)
		return ""

	# Generate character ID
	var character_id = "char_%d" % _next_character_id
	_next_character_id += 1

	# Build base stats with character type modifiers
	var base_stats = DEFAULT_BASE_STATS.duplicate(true)

	# Apply character type stat modifiers (Week 18: from CharacterTypeDatabase)
	var stat_modifiers = type_def.get("stat_modifiers", {})
	for stat_name in stat_modifiers.keys():
		if base_stats.has(stat_name):
			base_stats[stat_name] += stat_modifiers[stat_name]

	# Get slot limits from type definition (Week 18 Phase 2)
	var weapon_slots = type_def.get("weapon_slots", 6)
	var inventory_slots = type_def.get(
		"inventory_slots", CharacterTypeDatabase.DEFAULT_INVENTORY_SLOTS
	)

	# Get starting items from type definition (Week 18 Phase 2)
	var starting_items = type_def.get("starting_items", []).duplicate()

	# Get special mechanics (Week 18 Phase 2)
	var special_mechanics = type_def.get("special_mechanics", {}).duplicate(true)

	# Build character data
	var character_data = {
		"id": character_id,
		"name": character_name,
		"character_type": character_type,
		"level": 1,
		"experience": 0,
		"stats": base_stats,
		"weapon_slots": weapon_slots,  # Week 18: per-type weapon slot limit
		"inventory_slots": inventory_slots,  # Week 18: per-type inventory slot limit
		"special_mechanics": special_mechanics,  # Week 18: type-specific mechanics
		"created_at": Time.get_unix_time_from_system(),
		"last_played": Time.get_unix_time_from_system(),
		"death_count": 0,
		"total_kills": 0,
		"highest_wave": 0,
		"current_wave": 0,
		"starting_currency": {"scrap": 0, "nanites": 0, "components": 0}
	}

	# Fire pre-hook (perks can modify starting stats/items)
	var pre_context = {
		"character_type": character_data.character_type,
		"base_stats": character_data.stats.duplicate(true),
		"starting_items": starting_items,  # Week 18: type-specific starting items
		"starting_currency": {"scrap": 0, "nanites": 0, "components": 0},
		"allow_create": true
	}

	character_create_pre.emit(pre_context)

	# Check if perks blocked creation
	if not pre_context.allow_create:
		GameLogger.info("Character creation blocked by perk")
		return ""

	# Apply perk modifications
	character_data.stats = pre_context.base_stats

	# Store character
	characters[character_id] = character_data

	# Set as active if first character
	if characters.size() == 1:
		active_character_id = character_id

	# Fire post-hook (perks can grant welcome bonuses, handle starting_items)
	var post_context = {
		"character_id": character_id,
		"character_data": character_data.duplicate(true),
		"player_tier": current_tier,
		"starting_items": pre_context.starting_items,  # Week 18: for InventoryService to consume
	}

	character_create_post.emit(post_context)

	# Emit service signal
	character_created.emit(character_data.duplicate(true))

	GameLogger.info(
		"Character created",
		{
			"character_id": character_id,
			"name": character_name,
			"type": character_type,
			"weapon_slots": weapon_slots,
			"starting_items": starting_items.size()
		}
	)

	return character_id


## Get character by ID
## Returns character dictionary or empty dict if not found
func get_character(character_id: String) -> Dictionary:
	if not characters.has(character_id):
		GameLogger.warning("Character not found", {"character_id": character_id})
		return {}

	return characters[character_id].duplicate(true)


## Get all characters
## Returns array of character dictionaries
func get_all_characters() -> Array:
	var result = []
	for character in characters.values():
		result.append(character.duplicate(true))
	return result


## Update character data
## Returns true on success
func update_character(character_id: String, updates: Dictionary) -> bool:
	if not characters.has(character_id):
		GameLogger.warning("Cannot update: character not found", {"character_id": character_id})
		return false

	# Apply updates
	for key in updates.keys():
		characters[character_id][key] = updates[key]

	# Update last_played timestamp
	characters[character_id]["last_played"] = Time.get_unix_time_from_system()

	character_stats_changed.emit(character_id)

	GameLogger.info("Character updated", {"character_id": character_id, "updates": updates.keys()})

	return true


## Delete character
## Returns true on success
func delete_character(character_id: String) -> bool:
	if not characters.has(character_id):
		GameLogger.warning("Cannot delete: character not found", {"character_id": character_id})
		return false

	# If deleting active character, clear active state
	if active_character_id == character_id:
		active_character_id = ""

		# Set first remaining character as active
		if characters.size() > 1:
			for id in characters.keys():
				if id != character_id:
					active_character_id = id
					break

	# Remove character
	characters.erase(character_id)

	character_deleted.emit(character_id)

	GameLogger.info("Character deleted", {"character_id": character_id})

	return true


## Set active character
## Returns true on success
func set_active_character(character_id: String) -> bool:
	if not characters.has(character_id):
		GameLogger.warning("Cannot set active: character not found", {"character_id": character_id})
		return false

	active_character_id = character_id

	# Update last_played
	characters[character_id]["last_played"] = Time.get_unix_time_from_system()

	active_character_changed.emit(character_id)

	GameLogger.info("Active character changed", {"character_id": character_id})

	return true


## Get active character ID
func get_active_character_id() -> String:
	return active_character_id


## Get active character data
func get_active_character() -> Dictionary:
	if active_character_id.is_empty():
		return {}

	return get_character(active_character_id)


## Add experience to character and handle level up
## Returns true if character leveled up
func add_experience(character_id: String, xp_amount: int) -> bool:
	if not characters.has(character_id):
		GameLogger.warning("Cannot add XP: character not found", {"character_id": character_id})
		return false

	if xp_amount <= 0:
		return false

	var character = characters[character_id]
	var old_level = character.level

	# Add XP
	character.experience += xp_amount

	# Check for level up
	var xp_needed = old_level * XP_PER_LEVEL
	var leveled_up = false

	while character.experience >= xp_needed:
		# Level up!
		var new_level = character.level + 1

		# Fire pre-hook (perks can modify stat gains)
		var pre_context = {
			"character_id": character_id,
			"old_level": character.level,
			"new_level": new_level,
			"stat_gains": LEVEL_UP_STAT_GAINS.duplicate(true),
			"allow_level_up": true
		}

		character_level_up_pre.emit(pre_context)

		# Check if perks blocked level up
		if not pre_context.allow_level_up:
			GameLogger.info("Level up blocked by perk", {"character_id": character_id})
			break

		# Apply level up
		character.level = new_level
		character.experience -= xp_needed

		# Apply stat gains
		for stat_name in pre_context.stat_gains.keys():
			if character.stats.has(stat_name):
				character.stats[stat_name] += pre_context.stat_gains[stat_name]

		# Fire post-hook (perks can grant milestone rewards)
		var post_context = {
			"character_id": character_id,
			"new_level": new_level,
			"total_stat_gains": pre_context.stat_gains
		}

		character_level_up_post.emit(post_context)

		leveled_up = true

		GameLogger.info(
			"Character leveled up", {"character_id": character_id, "new_level": new_level}
		)

		# Recalculate XP needed for next level
		xp_needed = new_level * XP_PER_LEVEL

	if leveled_up:
		character_stats_changed.emit(character_id)

	return leveled_up


## Increment total kills counter
## Week 15 Phase 4: Track lifetime kill count
func increment_total_kills(character_id: String) -> bool:
	if not characters.has(character_id):
		GameLogger.warning(
			"Cannot increment kills: character not found", {"character_id": character_id}
		)
		return false

	characters[character_id].total_kills += 1
	return true


## Update highest wave reached
## Week 15 Phase 4: Track progression milestone
func update_highest_wave(character_id: String, wave: int) -> bool:
	if not characters.has(character_id):
		GameLogger.warning(
			"Cannot update highest_wave: character not found", {"character_id": character_id}
		)
		return false

	var character = characters[character_id]
	if wave > character.highest_wave:
		character.highest_wave = wave
		GameLogger.info(
			"New highest wave record",
			{"character_id": character_id, "old_record": character.highest_wave, "new_record": wave}
		)
		return true

	return false


## Add currency to character
## Week 15 Phase 4: Track economy (scrap, nanites, components)
func add_currency(character_id: String, currency_type: String, amount: int) -> bool:
	if not characters.has(character_id):
		GameLogger.warning(
			"Cannot add currency: character not found", {"character_id": character_id}
		)
		return false

	var character = characters[character_id]

	# Validate currency type exists
	if not character.starting_currency.has(currency_type):
		GameLogger.warning(
			"Invalid currency type", {"character_id": character_id, "currency_type": currency_type}
		)
		return false

	# Add currency
	character.starting_currency[currency_type] += amount

	GameLogger.info(
		"Currency added",
		{
			"character_id": character_id,
			"currency": currency_type,
			"amount": amount,
			"new_total": character.starting_currency[currency_type]
		}
	)

	return true


## Handle character death (durability loss, perks, resurrection)
## Returns true if character was resurrected by perk
func on_character_death(character_id: String, death_context: Dictionary = {}) -> bool:
	if not characters.has(character_id):
		GameLogger.warning(
			"Cannot process death: character not found", {"character_id": character_id}
		)
		return false

	var character = characters[character_id]

	# Fire pre-hook (perks can reduce penalties or grant resurrection)
	var pre_context = {
		"character_id": character_id,
		"death_context": death_context,
		"durability_loss_pct": 0.10,  # Default 10% durability loss
		"allow_death": true,
		"resurrection_granted": false
	}

	character_death_pre.emit(pre_context)

	# Check for resurrection
	if pre_context.resurrection_granted:
		GameLogger.info("Character resurrected by perk", {"character_id": character_id})
		return true

	# Process death
	character.death_count += 1

	# Calculate final stats for post-hook
	var final_stats = {
		"wave_reached": character.current_wave,
		"kills": character.total_kills,
		"level": character.level,
		"experience": character.experience
	}

	# Fire post-hook (perks can grant XP bonuses, track stats)
	var post_context = {
		"character_id": character_id,
		"final_stats": final_stats,
		"death_count": character.death_count
	}

	character_death_post.emit(post_context)

	character_stats_changed.emit(character_id)

	GameLogger.info(
		"Character death processed",
		{"character_id": character_id, "death_count": character.death_count}
	)

	return false


## Check if user can create more characters
func can_create_character() -> bool:
	var limit = SLOT_LIMITS[current_tier]
	return characters.size() < limit


## Get character slot limit for current tier
func get_character_slot_limit() -> int:
	return SLOT_LIMITS[current_tier]


## Get number of available slots remaining
func get_available_slots() -> int:
	var limit = SLOT_LIMITS[current_tier]
	return max(0, limit - characters.size())


## Set user tier (called by TierService or for testing)
func set_tier(tier: UserTier) -> void:
	current_tier = tier
	GameLogger.info("User tier set", {"tier": tier})


## Get current user tier
func get_tier() -> UserTier:
	return current_tier


## Get character count (convenience method)
func get_character_count() -> int:
	return characters.size()


## Get weapon slots for a character (Week 18 Phase 2)
## Returns 6 as default if character not found
func get_weapon_slots(character_id: String) -> int:
	if not characters.has(character_id):
		return 6  # Default
	return characters[character_id].get("weapon_slots", 6)


## Get inventory slots for a character (Week 18 Phase 2)
## Returns 30 as default if character not found
func get_inventory_slots(character_id: String) -> int:
	if not characters.has(character_id):
		return CharacterTypeDatabase.DEFAULT_INVENTORY_SLOTS  # Default
	return characters[character_id].get(
		"inventory_slots", CharacterTypeDatabase.DEFAULT_INVENTORY_SLOTS
	)


## Get special mechanics for a character (Week 18 Phase 2)
## Returns empty dictionary if character not found
func get_special_mechanics(character_id: String) -> Dictionary:
	if not characters.has(character_id):
		return {}
	return characters[character_id].get("special_mechanics", {}).duplicate(true)


## Check if character has a specific special mechanic (Week 18 Phase 2)
func has_special_mechanic(character_id: String, mechanic_name: String) -> bool:
	var mechanics = get_special_mechanics(character_id)
	return mechanics.has(mechanic_name)


## Get a specific special mechanic value (Week 18 Phase 2)
## Returns default_value if not found
func get_special_mechanic(character_id: String, mechanic_name: String, default_value = null):
	var mechanics = get_special_mechanics(character_id)
	return mechanics.get(mechanic_name, default_value)


## Get all available character types (Week 18 Phase 2)
## Returns array of type IDs that the current tier can access
func get_available_character_types() -> Array:
	var result = []
	for type_id in CharacterTypeDatabase.get_type_ids():
		if CharacterTypeDatabase.can_access_type(type_id, current_tier):
			result.append(type_id)
	return result


## Check if current tier can create a specific character type (Week 18 Phase 2)
func can_create_character_type(character_type: String) -> bool:
	return CharacterTypeDatabase.can_access_type(character_type, current_tier)


## Add XP to character with detailed level-up information
## Returns dictionary with level-up details
func add_xp(character_id: String, xp: int) -> Dictionary:
	if not characters.has(character_id):
		GameLogger.warning("Cannot add XP: character not found", {"character_id": character_id})
		return {"leveled_up": false, "new_level": 1, "xp_overflow": 0, "levels_gained": 0}

	if xp <= 0:
		return {"leveled_up": false, "new_level": 1, "xp_overflow": 0, "levels_gained": 0}

	var character = characters[character_id]
	var old_level = character.level

	# Use existing add_experience method
	var leveled_up = add_experience(character_id, xp)

	# Calculate detailed results
	var new_level = character.level
	var levels_gained = new_level - old_level
	var xp_overflow = character.experience

	return {
		"leveled_up": leveled_up,
		"new_level": new_level,
		"xp_overflow": xp_overflow,
		"levels_gained": levels_gained
	}


## Reset service state (for testing or new game)
func reset() -> void:
	characters.clear()
	active_character_id = ""
	current_tier = UserTier.FREE
	_next_character_id = 1

	GameLogger.info("CharacterService reset")


## Serialize service state to dictionary (for SaveManager)
func serialize() -> Dictionary:
	return {
		"version": 1,
		"characters": characters.duplicate(true),
		"active_character_id": active_character_id,
		"tier": current_tier,
		"next_character_id": _next_character_id,
		"timestamp": Time.get_unix_time_from_system()
	}


## Deserialize service state from dictionary (from SaveManager)
func deserialize(data: Dictionary) -> void:
	if data.get("version", 0) != 1:
		GameLogger.warning("CharacterService: Unknown save version", data)
		return

	# Restore characters
	if data.has("characters"):
		characters = data.characters.duplicate(true)
	else:
		characters = {}

	# Restore active character
	if data.has("active_character_id"):
		active_character_id = data.active_character_id
	else:
		active_character_id = ""

	# Restore tier
	if data.has("tier"):
		current_tier = data.tier
	else:
		current_tier = UserTier.FREE

	# Restore next ID
	if data.has("next_character_id"):
		_next_character_id = data.next_character_id
	else:
		_next_character_id = 1

	# Emit signals
	state_loaded.emit()

	if not active_character_id.is_empty():
		active_character_changed.emit(active_character_id)

	GameLogger.info(
		"CharacterService state loaded",
		{"character_count": characters.size(), "active": active_character_id, "tier": current_tier}
	)
