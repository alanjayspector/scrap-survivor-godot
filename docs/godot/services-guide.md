# Godot Services Guide

## GameState

### Overview
The GameState autoload manages global game state variables and emits signals when state changes. It should be configured in Project Settings → Autoload.

### API

**Properties:**
```gdscript
current_user: String       # Currently logged in user
current_character: String  # Selected character ID
is_gameplay_active: bool   # Whether gameplay is active
current_wave: int          # Current wave number
score: int                 # Current score
high_score: int            # Highest score achieved
difficulty: String         # Current difficulty
is_paused: bool            # Whether game is paused
```

**Signals:**
```gdscript
wave_changed(new_wave: int)
score_changed(new_score: int)
gameplay_state_changed(is_active: bool)
character_changed(character_id: String)
```

**Methods:**
```gdscript
set_current_wave(wave: int) → void
set_score(score: int) → void
add_score(amount: int) → void
set_gameplay_active(active: bool) → void
set_current_character(character_id: String) → void
reset_game_state() → void  # Resets all state except high_score
```

### Usage Example
```gdscript
# Set initial state
GameState.set_current_character("scavenger")
GameState.set_score(0)

# During gameplay
GameState.add_score(100)  # Adds 100 to score
GameState.set_current_wave(5)

# Connect to signals
GameState.wave_changed.connect(func(wave): print("Wave changed to", wave))
```

### Configuration
1. Add `game_state.gd` to Project Settings → Autoload
2. Set name as "GameState"
3. Enable

### Testing
Run `scenes/tests/test_game_state.tscn` to verify all functionality.
