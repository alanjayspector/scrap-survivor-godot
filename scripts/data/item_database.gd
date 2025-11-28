extends RefCounted
class_name ItemDatabase
## ItemDatabase - Centralized item definitions for all item types
##
## Week 18 Phase 1: Unified item database for shop, inventory, and combat systems
##
## Design Principles:
## - Single source of truth for all item definitions
## - Prefixed IDs for namespace clarity (weapon_, armor_, trinket_, consumable_)
## - Stats match CharacterService.DEFAULT_BASE_STATS keys
## - Rarity determines stack limits and price ranges
##
## Based on: docs/migration/week18-plan.md (Implementation Conventions)

## Rarity definitions with stack limits and price ranges
const RARITY_CONFIG = {
	"common":
	{
		"stack_limit": 5,
		"price_min": 50,
		"price_max": 150,
		"color": Color(0.42, 0.45, 0.50),  # Gray #6B7280
		"drop_weight": 0.60,
		"base_durability": 100  # Per INVENTORY-SYSTEM.md Section 6
	},
	"uncommon":
	{
		"stack_limit": 4,
		"price_min": 150,
		"price_max": 400,
		"color": Color(0.06, 0.73, 0.51),  # Green #10B981
		"drop_weight": 0.30,
		"base_durability": 200
	},
	"rare":
	{
		"stack_limit": 3,
		"price_min": 400,
		"price_max": 800,
		"color": Color(0.23, 0.51, 0.96),  # Blue #3B82F6
		"drop_weight": 0.08,
		"base_durability": 400
	},
	"epic":
	{
		"stack_limit": 2,
		"price_min": 800,
		"price_max": 1500,
		"color": Color(0.66, 0.33, 0.97),  # Purple #A855F7
		"drop_weight": 0.015,
		"base_durability": 800
	},
	"legendary":
	{
		"stack_limit": 1,
		"price_min": 1500,
		"price_max": 3000,
		"color": Color(0.96, 0.62, 0.04),  # Gold #F59E0B
		"drop_weight": 0.005,
		"base_durability": 1600
	}
}

## Item type enumeration
enum ItemType { WEAPON, ARMOR, TRINKET, CONSUMABLE }

## Weapon subtype enumeration
enum WeaponType { MELEE, RANGED }

## =============================================================================
## WEAPON DEFINITIONS (10 items)
## Migrated from WeaponService.WEAPON_DEFINITIONS
## NOTE: Combat data (cooldown, range, projectile, visuals) stays in WeaponService
## =============================================================================

const WEAPONS = {
	# --- COMMON WEAPONS (FREE tier origin) ---
	"weapon_rusty_blade":
	{
		"id": "weapon_rusty_blade",
		"name": "Rusty Blade",
		"description": "A weathered blade. Still cuts.",
		"type": "weapon",
		"rarity": "common",
		"base_price": 75,
		"stats": {"damage": 15, "melee_damage": 5},
		"stack_limit": 5,
		"weapon_type": "melee"
	},
	"weapon_plasma_pistol":
	{
		"id": "weapon_plasma_pistol",
		"name": "Plasma Pistol",
		"description": "Standard-issue energy sidearm. Reliable.",
		"type": "weapon",
		"rarity": "common",
		"base_price": 100,
		"stats": {"damage": 20, "ranged_damage": 5},
		"stack_limit": 5,
		"weapon_type": "ranged"
	},
	# --- UNCOMMON WEAPONS (PREMIUM tier origin) ---
	"weapon_scrap_cleaver":
	{
		"id": "weapon_scrap_cleaver",
		"name": "Scrap Cleaver",
		"description": "Heavy blade forged from salvaged metal.",
		"type": "weapon",
		"rarity": "uncommon",
		"base_price": 200,
		"stats": {"damage": 25, "melee_damage": 10},
		"stack_limit": 4,
		"weapon_type": "melee"
	},
	"weapon_arc_blaster":
	{
		"id": "weapon_arc_blaster",
		"name": "Arc Blaster",
		"description": "Fires arcs of electrical energy.",
		"type": "weapon",
		"rarity": "uncommon",
		"base_price": 250,
		"stats": {"damage": 30, "ranged_damage": 10},
		"stack_limit": 4,
		"weapon_type": "ranged"
	},
	"weapon_scattergun":
	{
		"id": "weapon_scattergun",
		"name": "Scattergun",
		"description": "Spray and pray. Close range devastation.",
		"type": "weapon",
		"rarity": "uncommon",
		"base_price": 275,
		"stats": {"damage": 8, "ranged_damage": 5},
		"stack_limit": 4,
		"weapon_type": "ranged"
	},
	# --- RARE WEAPONS (PREMIUM tier origin) ---
	"weapon_dead_eye":
	{
		"id": "weapon_dead_eye",
		"name": "Dead Eye",
		"description": "Precision sniper rifle. One shot, one kill.",
		"type": "weapon",
		"rarity": "rare",
		"base_price": 500,
		"stats": {"damage": 50, "ranged_damage": 15, "crit_chance": 0.10},
		"stack_limit": 3,
		"weapon_type": "ranged"
	},
	"weapon_scorcher":
	{
		"id": "weapon_scorcher",
		"name": "Scorcher",
		"description": "Continuous flame stream. Burns everything.",
		"type": "weapon",
		"rarity": "rare",
		"base_price": 550,
		"stats": {"damage": 4, "ranged_damage": 2},
		"stack_limit": 3,
		"weapon_type": "ranged"
	},
	"weapon_beam_gun":
	{
		"id": "weapon_beam_gun",
		"name": "Beam Gun",
		"description": "Near-instant laser beam. Surgical precision.",
		"type": "weapon",
		"rarity": "rare",
		"base_price": 600,
		"stats": {"damage": 27, "ranged_damage": 10},
		"stack_limit": 3,
		"weapon_type": "ranged"
	},
	# --- EPIC WEAPONS (SUBSCRIPTION tier origin) ---
	"weapon_shredder":
	{
		"id": "weapon_shredder",
		"name": "Shredder",
		"description": "High-speed minigun. Overwhelming firepower.",
		"type": "weapon",
		"rarity": "epic",
		"base_price": 1000,
		"stats": {"damage": 7, "ranged_damage": 3, "attack_speed": 10.0},
		"stack_limit": 2,
		"weapon_type": "ranged"
	},
	"weapon_boom_tube":
	{
		"id": "weapon_boom_tube",
		"name": "Boom Tube",
		"description": "Rocket launcher. Big boom, big damage.",
		"type": "weapon",
		"rarity": "epic",
		"base_price": 1200,
		"stats": {"damage": 60, "ranged_damage": 20},
		"stack_limit": 2,
		"weapon_type": "ranged"
	}
}

## =============================================================================
## ARMOR DEFINITIONS (10 items)
## Defensive items providing HP, armor, and survivability bonuses
## =============================================================================

const ARMOR = {
	# --- COMMON ARMOR ---
	"armor_scrap_vest":
	{
		"id": "armor_scrap_vest",
		"name": "Scrap Vest",
		"description": "Cobbled together from junk. Better than nothing.",
		"type": "armor",
		"rarity": "common",
		"base_price": 50,
		"stats": {"armor": 5, "max_hp": 10},
		"stack_limit": 5
	},
	"armor_rusty_helmet":
	{
		"id": "armor_rusty_helmet",
		"name": "Rusty Helmet",
		"description": "Dented but functional head protection.",
		"type": "armor",
		"rarity": "common",
		"base_price": 60,
		"stats": {"armor": 3, "max_hp": 15},
		"stack_limit": 5
	},
	"armor_leather_scraps":
	{
		"id": "armor_leather_scraps",
		"name": "Leather Scraps",
		"description": "Salvaged leather strips. Light protection.",
		"type": "armor",
		"rarity": "common",
		"base_price": 50,
		"stats": {"armor": 2, "dodge": 0.02},
		"stack_limit": 5
	},
	# --- UNCOMMON ARMOR ---
	"armor_reinforced_plate":
	{
		"id": "armor_reinforced_plate",
		"name": "Reinforced Plate",
		"description": "Welded metal plates. Solid protection.",
		"type": "armor",
		"rarity": "uncommon",
		"base_price": 175,
		"stats": {"armor": 10, "max_hp": 20},
		"stack_limit": 4
	},
	"armor_scavenger_coat":
	{
		"id": "armor_scavenger_coat",
		"name": "Scavenger Coat",
		"description": "Many pockets. Light and practical.",
		"type": "armor",
		"rarity": "uncommon",
		"base_price": 200,
		"stats": {"armor": 5, "pickup_range": 15, "speed": 10},
		"stack_limit": 4
	},
	"armor_shock_absorbers":
	{
		"id": "armor_shock_absorbers",
		"name": "Shock Absorbers",
		"description": "Reduces impact damage. Springs still work.",
		"type": "armor",
		"rarity": "uncommon",
		"base_price": 225,
		"stats": {"armor": 8, "max_hp": 25, "hp_regen": 1},
		"stack_limit": 4
	},
	# --- RARE ARMOR ---
	"armor_wasteland_exosuit":
	{
		"id": "armor_wasteland_exosuit",
		"name": "Wasteland Exosuit",
		"description": "Powered frame. Heavy but powerful.",
		"type": "armor",
		"rarity": "rare",
		"base_price": 500,
		"stats": {"armor": 15, "max_hp": 40, "speed": -15},
		"stack_limit": 3
	},
	"armor_hazmat_suit":
	{
		"id": "armor_hazmat_suit",
		"name": "Hazmat Suit",
		"description": "Protects against environmental hazards.",
		"type": "armor",
		"rarity": "rare",
		"base_price": 550,
		"stats": {"armor": 12, "max_hp": 30, "hp_regen": 2},
		"stack_limit": 3
	},
	"armor_nanite_weave":
	{
		"id": "armor_nanite_weave",
		"name": "Nanite Weave",
		"description": "Self-repairing armor mesh. Advanced tech.",
		"type": "armor",
		"rarity": "rare",
		"base_price": 650,
		"stats": {"armor": 10, "hp_regen": 3, "life_steal": 0.05},
		"stack_limit": 3
	},
	"armor_combat_chassis":
	{
		"id": "armor_combat_chassis",
		"name": "Combat Chassis",
		"description": "Military-grade body frame. Battle-tested.",
		"type": "armor",
		"rarity": "rare",
		"base_price": 700,
		"stats": {"armor": 18, "max_hp": 50, "dodge": 0.05},
		"stack_limit": 3
	}
}

## =============================================================================
## TRINKET DEFINITIONS (10 items)
## Utility items providing luck, crit, XP, and special bonuses
## =============================================================================

const TRINKETS = {
	# --- UNCOMMON TRINKETS ---
	"trinket_lucky_coin":
	{
		"id": "trinket_lucky_coin",
		"name": "Lucky Coin",
		"description": "Found it in the wasteland. Feels... lucky.",
		"type": "trinket",
		"rarity": "uncommon",
		"base_price": 150,
		"stats": {"luck": 10, "scavenging": 5},
		"stack_limit": 4
	},
	"trinket_speed_chip":
	{
		"id": "trinket_speed_chip",
		"name": "Speed Chip",
		"description": "Neural accelerator. Think faster, move faster.",
		"type": "trinket",
		"rarity": "uncommon",
		"base_price": 175,
		"stats": {"speed": 20, "attack_speed": 5.0},
		"stack_limit": 4
	},
	"trinket_targeting_module":
	{
		"id": "trinket_targeting_module",
		"name": "Targeting Module",
		"description": "Improves aim and critical hit chance.",
		"type": "trinket",
		"rarity": "uncommon",
		"base_price": 200,
		"stats": {"crit_chance": 0.05, "ranged_damage": 5},
		"stack_limit": 4
	},
	"trinket_magnet_core":
	{
		"id": "trinket_magnet_core",
		"name": "Magnet Core",
		"description": "Attracts nearby pickups. Very convenient.",
		"type": "trinket",
		"rarity": "uncommon",
		"base_price": 180,
		"stats": {"pickup_range": 30, "scavenging": 3},
		"stack_limit": 4
	},
	# --- RARE TRINKETS ---
	"trinket_vampiric_fang":
	{
		"id": "trinket_vampiric_fang",
		"name": "Vampiric Fang",
		"description": "Drain life from enemies. Unsettling but effective.",
		"type": "trinket",
		"rarity": "rare",
		"base_price": 450,
		"stats": {"life_steal": 0.08, "damage": 5},
		"stack_limit": 3
	},
	"trinket_resonance_crystal":
	{
		"id": "trinket_resonance_crystal",
		"name": "Resonance Crystal",
		"description": "Amplifies aura effects. Glows faintly.",
		"type": "trinket",
		"rarity": "rare",
		"base_price": 500,
		"stats": {"resonance": 15, "luck": 5},
		"stack_limit": 3
	},
	"trinket_berserker_chip":
	{
		"id": "trinket_berserker_chip",
		"name": "Berserker Chip",
		"description": "Damage boost at low health. High risk, high reward.",
		"type": "trinket",
		"rarity": "rare",
		"base_price": 475,
		"stats": {"damage": 15, "crit_chance": 0.08, "max_hp": -10},
		"stack_limit": 3
	},
	# --- EPIC TRINKETS ---
	"trinket_quantum_dice":
	{
		"id": "trinket_quantum_dice",
		"name": "Quantum Dice",
		"description": "Probability manipulation. Luck is no longer random.",
		"type": "trinket",
		"rarity": "epic",
		"base_price": 900,
		"stats": {"luck": 25, "crit_chance": 0.10, "scavenging": 10},
		"stack_limit": 2
	},
	"trinket_neural_amplifier":
	{
		"id": "trinket_neural_amplifier",
		"name": "Neural Amplifier",
		"description": "Overclocks your reflexes. Everything feels slower.",
		"type": "trinket",
		"rarity": "epic",
		"base_price": 1100,
		"stats": {"attack_speed": 15.0, "speed": 25, "dodge": 0.08},
		"stack_limit": 2
	},
	"trinket_void_shard":
	{
		"id": "trinket_void_shard",
		"name": "Void Shard",
		"description": "Fragment of the unknown. Power at a cost.",
		"type": "trinket",
		"rarity": "epic",
		"base_price": 1200,
		"stats": {"damage": 25, "resonance": 20, "max_hp": -20},
		"stack_limit": 2
	}
}

## =============================================================================
## CONSUMABLE DEFINITIONS (5 items)
## Temporary buffs while owned (auto-active like other items)
## =============================================================================

const CONSUMABLES = {
	# --- COMMON CONSUMABLES ---
	"consumable_repair_kit":
	{
		"id": "consumable_repair_kit",
		"name": "Repair Kit",
		"description": "Basic repair supplies. Keeps you running.",
		"type": "consumable",
		"rarity": "common",
		"base_price": 75,
		"stats": {"hp_regen": 2, "armor": 2},
		"stack_limit": 5
	},
	"consumable_stim_pack":
	{
		"id": "consumable_stim_pack",
		"name": "Stim Pack",
		"description": "Adrenaline boost. Temporary but potent.",
		"type": "consumable",
		"rarity": "common",
		"base_price": 80,
		"stats": {"speed": 15, "attack_speed": 5.0},
		"stack_limit": 5
	},
	"consumable_scrap_magnet":
	{
		"id": "consumable_scrap_magnet",
		"name": "Scrap Magnet",
		"description": "Attracts more scrap from enemies.",
		"type": "consumable",
		"rarity": "common",
		"base_price": 60,
		"stats": {"scavenging": 8, "pickup_range": 20},
		"stack_limit": 5
	},
	# --- UNCOMMON CONSUMABLES ---
	"consumable_combat_stims":
	{
		"id": "consumable_combat_stims",
		"name": "Combat Stims",
		"description": "Military-grade performance enhancer.",
		"type": "consumable",
		"rarity": "uncommon",
		"base_price": 200,
		"stats": {"damage": 10, "attack_speed": 8.0, "crit_chance": 0.05},
		"stack_limit": 4
	},
	"consumable_nano_repair":
	{
		"id": "consumable_nano_repair",
		"name": "Nano Repair",
		"description": "Nanites that continuously repair damage.",
		"type": "consumable",
		"rarity": "uncommon",
		"base_price": 225,
		"stats": {"hp_regen": 5, "life_steal": 0.03, "max_hp": 15},
		"stack_limit": 4
	}
}

## =============================================================================
## COMBINED DATABASE
## All items merged into single dictionary for unified access
## =============================================================================


## Get all items as a single dictionary
## This is the primary data source for ItemService
static func get_all_items() -> Dictionary:
	var all_items = {}
	all_items.merge(WEAPONS)
	all_items.merge(ARMOR)
	all_items.merge(TRINKETS)
	all_items.merge(CONSUMABLES)
	return all_items


## Get item count
static func get_item_count() -> int:
	return WEAPONS.size() + ARMOR.size() + TRINKETS.size() + CONSUMABLES.size()


## Get rarity configuration
static func get_rarity_config(rarity: String) -> Dictionary:
	if RARITY_CONFIG.has(rarity):
		return RARITY_CONFIG[rarity]
	return {}


## Get stack limit for rarity
static func get_stack_limit_for_rarity(rarity: String) -> int:
	var config = get_rarity_config(rarity)
	return config.get("stack_limit", 1)


## Get rarity color
static func get_rarity_color(rarity: String) -> Color:
	var config = get_rarity_config(rarity)
	return config.get("color", Color.WHITE)


## Get base durability for rarity (per INVENTORY-SYSTEM.md Section 6)
## Common: 100, Uncommon: 200, Rare: 400, Epic: 800, Legendary: 1600
static func get_base_durability_for_rarity(rarity: String) -> int:
	var config = get_rarity_config(rarity)
	return config.get("base_durability", 100)
