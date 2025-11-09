extends Node
## RecyclerService - Pure calculation service for item recycling
##
## Ported from packages/core/src/services/RecyclerService.ts
## Week 5: Local-first architecture (no Supabase, pure calculations)
##
## Calculates scrap and workshop components gained from dismantling items:
## - Scrap: Based on rarity, weapon multiplier, durability
## - Workshop Components: Based on rarity, luck modifiers, randomness
##
## Usage:
##   var preview = RecyclerService.preview_dismantle(input)
##   var outcome = RecyclerService.dismantle_item(input)

# Rarity enum matching TypeScript ItemRarity type
enum ItemRarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }


# Dismantle input structure
class DismantleInput:
	var template_id: String
	var rarity: ItemRarity
	var is_weapon: bool = false
	var luck: int = 0
	var radioactivity: int = 0
	var base_scrap_value: int = 0  # Optional override
	var durability: int = 100  # Default to full durability

	func _init(
		p_template_id: String, p_rarity: ItemRarity, p_is_weapon: bool = false, p_luck: int = 0
	):
		template_id = p_template_id
		rarity = p_rarity
		is_weapon = p_is_weapon
		luck = p_luck


# Dismantle outcome structure
class DismantleOutcome:
	var components_granted: int
	var scrap_granted: int
	var radioactivity: int
	var components_chance: float

	func _init(p_components: int, p_scrap: int, p_radio: int, p_chance: float):
		components_granted = p_components
		scrap_granted = p_scrap
		radioactivity = p_radio
		components_chance = p_chance


# Preview outcome (includes additional debug info)
class DismantlePreview:
	extends DismantleOutcome
	var normalized_luck: int
	var potential_components: int

	func _init(
		p_components: int,
		p_scrap: int,
		p_radio: int,
		p_chance: float,
		p_luck: int,
		p_potential: int
	):
		super._init(p_components, p_scrap, p_radio, p_chance)
		normalized_luck = p_luck
		potential_components = p_potential


# Scrap base values by rarity (from TypeScript SCRAP_BASE_BY_RARITY)
const SCRAP_BASE_BY_RARITY = {
	ItemRarity.COMMON: 12,
	ItemRarity.UNCOMMON: 20,
	ItemRarity.RARE: 35,
	ItemRarity.EPIC: 45,
	ItemRarity.LEGENDARY: 60,
}

# Workshop components base quantities by rarity (from TypeScript PARTS_BASE_BY_RARITY)
const COMPONENTS_BASE_BY_RARITY = {
	ItemRarity.COMMON: 0,
	ItemRarity.UNCOMMON: 1,
	ItemRarity.RARE: 2,
	ItemRarity.EPIC: 3,
	ItemRarity.LEGENDARY: 3,
}

# Workshop components drop chance by rarity (from TypeScript PARTS_CHANCE_BY_RARITY)
const COMPONENTS_CHANCE_BY_RARITY = {
	ItemRarity.COMMON: 0.0,
	ItemRarity.UNCOMMON: 0.4,
	ItemRarity.RARE: 0.65,
	ItemRarity.EPIC: 0.75,
	ItemRarity.LEGENDARY: 0.85,
}

# Signals
signal item_dismantled(template_id: String, outcome: DismantleOutcome)


## Preview dismantle outcome without actually dismantling
## Returns DismantlePreview with calculated values
func preview_dismantle(input: DismantleInput) -> DismantlePreview:
	var result = _compute_outcome(input, true)
	return DismantlePreview.new(
		result.components_granted,
		result.scrap_granted,
		result.radioactivity,
		result.components_chance,
		result.normalized_luck,
		result.potential_components
	)


## Dismantle an item and return the outcome
## Week 5: Pure calculation, no storage/database
func dismantle_item(input: DismantleInput) -> DismantleOutcome:
	if input.template_id.is_empty():
		GameLogger.error("RecyclerService.dismantle_item requires template_id")
		return DismantleOutcome.new(0, 0, 0, 0.0)

	var result = _compute_outcome(input, false)

	(
		GameLogger
		. info(
			"Recycler dismantle completed",
			{
				"template_id": input.template_id,
				"rarity": ItemRarity.keys()[input.rarity],
				"is_weapon": input.is_weapon,
				"luck": result.normalized_luck,
				"components_granted": result.components_granted,
				"scrap_granted": result.scrap_granted,
			}
		)
	)

	var outcome = DismantleOutcome.new(
		result.components_granted,
		result.scrap_granted,
		input.radioactivity,
		result.components_chance
	)

	item_dismantled.emit(input.template_id, outcome)
	return outcome


## Internal: Compute dismantle outcome
func _compute_outcome(input: DismantleInput, is_preview: bool) -> Dictionary:
	var normalized_luck = maxi(0, input.luck)

	# Calculate workshop components outcome (with randomness for actual dismantle)
	# Preview mode uses guaranteed outcome
	var components_result = _calculate_components_outcome(input.rarity, normalized_luck, is_preview)

	# Calculate scrap
	var scrap_granted = _calculate_scrap_granted(
		input.rarity, input.is_weapon, input.base_scrap_value, input.durability
	)

	return {
		"components_granted": components_result.components_granted,
		"scrap_granted": scrap_granted,
		"radioactivity": input.radioactivity,
		"components_chance": components_result.components_chance,
		"normalized_luck": normalized_luck,
		"potential_components": components_result.potential_components,
	}


## Calculate workshop components outcome with luck modifiers
## Returns: { components_granted, components_chance, potential_components }
func _calculate_components_outcome(rarity: ItemRarity, luck: int, is_preview: bool) -> Dictionary:
	var base_components = COMPONENTS_BASE_BY_RARITY.get(rarity, 0)
	var base_chance = COMPONENTS_CHANCE_BY_RARITY.get(rarity, 0.0)

	# Common items never drop workshop components
	if base_chance <= 0.0 or base_components <= 0:
		return {
			"components_granted": 0,
			"components_chance": 0.0,
			"potential_components": 0,
		}

	# Luck chance bonus: +2.5% per 10 luck, capped at +25%
	# Formula: min(0.25, luck * 0.0025)
	var luck_chance_bonus = minf(0.25, luck * 0.0025)
	var components_chance = minf(0.95, base_chance + luck_chance_bonus)

	# Luck components bonus: +1 component per 120 luck
	var luck_components_bonus = floori(luck / 120.0)
	var potential_components = base_components + luck_components_bonus

	# Determine if components drop (preview always shows potential)
	var will_drop: bool
	if is_preview:
		# Preview mode: show what COULD drop
		will_drop = true
	else:
		# Actual dismantle: roll for drop
		will_drop = randf() < components_chance

	var components_granted = potential_components if will_drop else 0

	return {
		"components_granted": components_granted,
		"components_chance": components_chance,
		"potential_components": potential_components,
	}


## Calculate scrap granted with weapon multiplier and durability check
func _calculate_scrap_granted(
	rarity: ItemRarity, is_weapon: bool, base_scrap_value: int, durability: int
) -> int:
	# Broken items (durability 0) return 0 scrap - they're just destroyed
	if durability <= 0:
		return 0

	# Use override or default base value
	var base = base_scrap_value if base_scrap_value > 0 else SCRAP_BASE_BY_RARITY.get(rarity, 10)

	# Weapons give 1.5x scrap
	var multiplier = 1.5 if is_weapon else 1.0

	return maxi(1, roundi(base * multiplier))


## Helper: Convert rarity string to enum
static func rarity_from_string(rarity_str: String) -> ItemRarity:
	match rarity_str.to_lower():
		"common":
			return ItemRarity.COMMON
		"uncommon":
			return ItemRarity.UNCOMMON
		"rare":
			return ItemRarity.RARE
		"epic":
			return ItemRarity.EPIC
		"legendary":
			return ItemRarity.LEGENDARY
		_:
			GameLogger.warn("Unknown rarity: " + rarity_str + ", defaulting to COMMON")
			return ItemRarity.COMMON


## Helper: Convert enum to rarity string
static func rarity_to_string(rarity: ItemRarity) -> String:
	return ItemRarity.keys()[rarity].to_lower()
