extends GutTest
## Test script for CombatService using GUT framework
##
## USER STORY: "As a player, I want my weapon attacks and character stats
## to combine into powerful damage against enemies, with auras automatically
## damaging nearby foes"
##
## Tests damage calculation, enemy damage application, aura damage, and
## integration between CharacterService, WeaponService, and EnemyService.

class_name CombatServiceTest


func before_each() -> void:
	# Reset services
	CharacterService.reset()
	WeaponService.reset_cooldowns()
	WeaponService.equipped_weapons.clear()
	EnemyService.reset()

	# Set PREMIUM tier
	CharacterService.set_tier(CharacterService.UserTier.PREMIUM)
	WeaponService.set_tier(WeaponService.UserTier.PREMIUM)


func after_each() -> void:
	# Cleanup
	pass


## ============================================================================
## SECTION 1: Damage Calculation Tests
## User Story: "As a player, I want my character stats to boost weapon damage"
## ============================================================================


func test_calculate_damage_includes_character_stats() -> void:
	# Arrange
	var weapon_id = "rusty_blade"  # Base damage: 15
	var character_stats = {"damage": 10, "melee_damage": 5, "ranged_damage": 0}

	# Act
	var damage = CombatService.calculate_damage(weapon_id, character_stats)

	# Assert
	# 15 (base) + 10 (character) + 5 (melee bonus) = 30
	assert_almost_eq(damage, 30.0, 0.01, "Should sum base + character + type bonus")


func test_calculate_damage_adds_melee_bonus() -> void:
	# Arrange
	var weapon_id = "rusty_blade"  # MELEE weapon
	var character_stats = {"damage": 0, "melee_damage": 12, "ranged_damage": 50}

	# Act
	var damage = CombatService.calculate_damage(weapon_id, character_stats)

	# Assert
	# 15 (base) + 0 (character) + 12 (melee) = 27
	# Should ignore ranged_damage for melee weapon
	assert_almost_eq(damage, 27.0, 0.01, "Should add melee bonus, ignore ranged")


func test_calculate_damage_adds_ranged_bonus() -> void:
	# Arrange
	var weapon_id = "plasma_pistol"  # RANGED weapon
	var character_stats = {"damage": 5, "melee_damage": 50, "ranged_damage": 8}

	# Act
	var damage = CombatService.calculate_damage(weapon_id, character_stats)

	# Assert
	# 20 (base, Week 12 balance) + 5 (character) + 8 (ranged) = 33
	# Should ignore melee_damage for ranged weapon
	assert_almost_eq(damage, 33.0, 0.01, "Should add ranged bonus, ignore melee")


## ============================================================================
## SECTION 2: Enemy Damage Application Tests
## User Story: "As a player, I want to damage and kill enemies"
## ============================================================================


func test_apply_damage_to_enemy_reduces_hp() -> void:
	# Arrange
	var enemy_id = EnemyService.spawn_enemy("scrap_bot", Vector2.ZERO)

	# Act
	var result = CombatService.apply_damage_to_enemy(enemy_id, 20.0)

	# Assert
	assert_false(result.killed, "Enemy should not be killed yet")
	assert_almost_eq(result.remaining_hp, 30.0, 0.01, "Should have 30 HP remaining (50 - 20)")


func test_apply_damage_to_enemy_returns_drops_when_killed() -> void:
	# Arrange
	var enemy_id = EnemyService.spawn_enemy("scrap_bot", Vector2(50, 75))

	# Act
	var result = CombatService.apply_damage_to_enemy(enemy_id, 100.0)  # Overkill

	# Assert
	assert_true(result.killed, "Enemy should be killed")
	assert_true(result.has("drops"), "Should include drop data")
	assert_eq(result.drops.enemy_id, enemy_id, "Drop data should include enemy ID")
	assert_eq(result.drops.enemy_type, "scrap_bot", "Drop data should include enemy type")


func test_apply_damage_to_invalid_enemy_returns_safe_result() -> void:
	# Arrange & Act
	var result = CombatService.apply_damage_to_enemy("invalid_enemy", 50.0)

	# Assert
	assert_false(result.killed, "Should return killed=false for invalid enemy")
	assert_almost_eq(result.remaining_hp, 0.0, 0.01, "Should return 0 HP for invalid enemy")


## ============================================================================
## SECTION 3: Aura Damage Calculation Tests
## User Story: "As a player, I want my resonance stat to boost aura damage"
## ============================================================================


func test_calculate_aura_damage_scales_with_resonance() -> void:
	# Arrange
	var character_stats_low = {"resonance": 0}
	var character_stats_high = {"resonance": 20}

	# Act
	var damage_low = CombatService.calculate_aura_damage(character_stats_low)
	var damage_high = CombatService.calculate_aura_damage(character_stats_high)

	# Assert
	# damage aura: base 5.0 + (resonance * 0.5)
	assert_almost_eq(damage_low, 5.0, 0.01, "Low resonance should have base damage (5)")
	assert_almost_eq(damage_high, 15.0, 0.01, "High resonance should boost damage (5 + 20*0.5)")


func test_calculate_aura_damage_with_no_resonance_stat() -> void:
	# Arrange
	var character_stats = {}  # Missing resonance

	# Act
	var damage = CombatService.calculate_aura_damage(character_stats)

	# Assert
	# Should default to 0 resonance
	assert_almost_eq(damage, 5.0, 0.01, "Should use base damage when resonance missing")


## ============================================================================
## SECTION 4: Aura Damage Application Tests
## User Story: "As a player, I want my damage aura to hurt nearby enemies"
## ============================================================================


func test_apply_aura_damage_to_nearby_enemies() -> void:
	# Arrange
	var enemy1 = EnemyService.spawn_enemy("scrap_bot", Vector2(30, 0))  # Within 100 radius
	var enemy2 = EnemyService.spawn_enemy("mutant_rat", Vector2(50, 0))  # Within 100 radius
	var enemy3 = EnemyService.spawn_enemy("rust_spider", Vector2(200, 0))  # Outside radius

	# Act
	var results = CombatService.apply_aura_damage_to_nearby_enemies(Vector2.ZERO, 100.0, 10.0)  # Center, radius, damage

	# Assert
	assert_eq(results.size(), 2, "Should damage 2 enemies within radius")

	# Verify enemy1 was damaged
	var enemy1_data = EnemyService.get_enemy(enemy1)
	assert_almost_eq(enemy1_data.current_hp, 40.0, 0.01, "Enemy1 should have 40 HP (50-10)")

	# Verify enemy3 was NOT damaged
	var enemy3_data = EnemyService.get_enemy(enemy3)
	assert_almost_eq(enemy3_data.current_hp, 40.0, 0.01, "Enemy3 should still have full HP")


func test_apply_aura_damage_can_kill_enemies() -> void:
	# Arrange
	var enemy_id = EnemyService.spawn_enemy("scrap_bot", Vector2(10, 0))

	# Act
	var results = CombatService.apply_aura_damage_to_nearby_enemies(Vector2.ZERO, 100.0, 100.0)  # Massive damage

	# Assert
	assert_eq(results.size(), 1, "Should affect 1 enemy")
	assert_true(results[0].result.killed, "Enemy should be killed by aura damage")


func test_apply_aura_damage_to_empty_area() -> void:
	# Arrange - no enemies spawned

	# Act
	var results = CombatService.apply_aura_damage_to_nearby_enemies(Vector2.ZERO, 100.0, 10.0)

	# Assert
	assert_eq(results.size(), 0, "Should return empty array when no enemies in range")


## ============================================================================
## SECTION 5: Weapon Attack Integration Tests
## User Story: "As a player, I want to attack enemies with equipped weapons"
## ============================================================================


func test_get_weapon_attack_damage() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestWarrior", "scavenger")
	var weapon_id = "rusty_blade"

	# Act
	var damage = CombatService.get_weapon_attack_damage(weapon_id, character_id)

	# Assert
	# Scavenger has: damage=10 (default), melee_damage=0
	# Rusty blade: base_damage=15, type=MELEE
	# Total: 15 + 10 + 0 = 25
	assert_almost_eq(damage, 25.0, 0.01, "Should calculate total damage for scavenger")


func test_get_weapon_attack_damage_with_invalid_character() -> void:
	# Arrange
	var weapon_id = "plasma_pistol"
	var invalid_character_id = "invalid_char"

	# Act
	var damage = CombatService.get_weapon_attack_damage(weapon_id, invalid_character_id)

	# Assert
	assert_almost_eq(damage, 0.0, 0.01, "Should return 0 for invalid character")


func test_apply_weapon_attack() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestWarrior", "scavenger")
	var enemy_id = EnemyService.spawn_enemy("scrap_bot", Vector2.ZERO)
	var weapon_id = "rusty_blade"

	# Act
	var result = CombatService.apply_weapon_attack(weapon_id, character_id, enemy_id)

	# Assert
	assert_true(result.has("damage"), "Should include damage dealt")
	assert_gt(result.damage, 0.0, "Should deal positive damage")
	assert_false(result.killed, "Enemy should not be killed by one hit")


func test_apply_weapon_attack_can_kill() -> void:
	# Arrange
	var character_id = CharacterService.create_character("TestWarrior", "scavenger")
	var enemy_id = EnemyService.spawn_enemy("mutant_rat", Vector2.ZERO)  # 30 HP
	var weapon_id = "steel_sword"  # High damage weapon

	# Act
	var result = CombatService.apply_weapon_attack(weapon_id, character_id, enemy_id)

	# Assert
	assert_true(result.killed, "Strong weapon should kill weak enemy")
	assert_true(result.has("drops"), "Should include drops when killed")
