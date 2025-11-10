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

## Character slot limits per tier
const SLOT_LIMITS = {
	UserTier.FREE: 3,
	UserTier.PREMIUM: 10,
	UserTier.SUBSCRIPTION: -1,  # -1 = unlimited
}

## XP progression constants (linear for simplicity, can change to exponential later)
const XP_PER_LEVEL = 100  # Level 2 = 100 XP, Level 3 = 200 XP, etc.

## Default character type (Week 6: single type, expand in Week 7+)
const DEFAULT_CHARACTER_TYPE = "scavenger"

## Character type definitions (Week 7 Phase 2)
const CHARACTER_TYPES = {
	"scavenger":
	{
		"tier_required": UserTier.FREE,
		"display_name": "Scavenger",
		"description": "Efficient resource gatherer with auto-collect aura",
		"color": Color(0.6, 0.6, 0.6),  # Gray
		"stat_modifiers": {"scavenging": 5, "pickup_range": 20},
		"aura_type": "collect",  # Auto-collect currency (quality of life)
		"unlock_condition": "default"  # Always unlocked
	},
	"tank":
	{
		"tier_required": UserTier.PREMIUM,
		"display_name": "Tank",
		"description": "Heavy armor specialist with protective aura",
		"color": Color(0.3, 0.5, 0.3),  # Olive green
		"stat_modifiers": {"max_hp": 20, "armor": 3, "speed": -20},
		"aura_type": "shield",  # +Armor while in aura radius
		"unlock_condition": "premium_purchase"
	},
	"commando":
	{
		"tier_required": UserTier.SUBSCRIPTION,
		"display_name": "Commando",
		"description": "High DPS glass cannon with no defensive aura",
		"color": Color(0.8, 0.2, 0.2),  # Red
		"stat_modifiers": {"ranged_damage": 5, "attack_speed": 15, "armor": -2},
		"aura_type": null,  # No aura (trade-off for raw DPS)
		"unlock_condition": "subscription_active"
	},
	"mutant":
	{
		"tier_required": UserTier.SUBSCRIPTION,
		"display_name": "Mutant",
		"description": "Mutation specialist with powerful damage aura",
		"color": Color(0.5, 0.2, 0.7),  # Purple (mutation theme)
		"stat_modifiers": {"resonance": 10, "luck": 5, "pickup_range": 20},
		"aura_type": "damage",  # Damage aura that scales with Resonance
		"unlock_condition": "subscription_active"
	}
}

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

	# Validate character type exists
	if not CHARACTER_TYPES.has(character_type):
		GameLogger.error("Invalid character type", {"type": character_type})
		return ""

	# Check tier restrictions
	var type_def = CHARACTER_TYPES[character_type]
	if type_def.tier_required > current_tier:
		GameLogger.warning(
			"Character type requires higher tier",
			{"type": character_type, "required": type_def.tier_required, "current": current_tier}
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

	# Apply character type stat modifiers
	for stat_name in type_def.stat_modifiers.keys():
		if base_stats.has(stat_name):
			base_stats[stat_name] += type_def.stat_modifiers[stat_name]

	# Build character data
	var character_data = {
		"id": character_id,
		"name": character_name,
		"character_type": character_type,
		"level": 1,
		"experience": 0,
		"stats": base_stats,
		"created_at": Time.get_unix_time_from_system(),
		"last_played": Time.get_unix_time_from_system(),
		"death_count": 0,
		"total_kills": 0,
		"highest_wave": 0,
		"current_wave": 0,
		"aura": {"type": type_def.aura_type, "enabled": true, "level": 1}
	}

	# Fire pre-hook (perks can modify starting stats/items)
	var pre_context = {
		"character_type": character_data.character_type,
		"base_stats": character_data.stats.duplicate(true),
		"starting_items": [],
		"starting_currency": {"scrap": 0, "premium": 0, "nanites": 0},
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

	# Fire post-hook (perks can grant welcome bonuses)
	var post_context = {
		"character_id": character_id,
		"character_data": character_data.duplicate(true),
		"player_tier": current_tier
	}

	character_create_post.emit(post_context)

	# Emit service signal
	character_created.emit(character_data.duplicate(true))

	GameLogger.info(
		"Character created",
		{"character_id": character_id, "name": character_name, "type": character_type}
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

	# -1 means unlimited
	if limit == -1:
		return true

	return characters.size() < limit


## Get character slot limit for current tier
func get_character_slot_limit() -> int:
	return SLOT_LIMITS[current_tier]


## Get number of available slots remaining
func get_available_slots() -> int:
	var limit = SLOT_LIMITS[current_tier]

	# -1 means unlimited
	if limit == -1:
		return 999  # Return large number for UI display

	return max(0, limit - characters.size())


## Set user tier (called by TierService or for testing)
func set_tier(tier: UserTier) -> void:
	current_tier = tier
	GameLogger.info("User tier set", {"tier": tier})


## Get current user tier
func get_tier() -> UserTier:
	return current_tier


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
