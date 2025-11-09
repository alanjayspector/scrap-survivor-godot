# GDScript Coding Conventions

## Naming

- **Files:** snake_case (e.g., `weapon_system.gd`)
- **Classes:** PascalCase (e.g., `WeaponSystem`)
- **Functions:** snake_case (e.g., `calculate_damage`)
- **Variables:** snake_case (e.g., `current_health`)
- **Constants:** SCREAMING_SNAKE_CASE (e.g., `MAX_HEALTH`)
- **Signals:** snake_case, past tense (e.g., `health_changed`)

## Type Hints

Always use type hints:

```gdscript
func calculate_damage(base: float, modifier: float) -> float:
    return base * modifier

var health: float = 100.0
var enemies: Array[Enemy] = []
```

## Documentation

Use doc comments:

```gdscript
## Calculates damage after armor reduction.
##
## @param base_damage: Raw damage value
## @param armor: Target's armor stat
## @return: Final damage amount
func calculate_damage(base_damage: float, armor: float) -> float:
    return max(1, base_damage - armor * 0.5)
```

See official style guide: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html
