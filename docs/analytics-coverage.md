# Analytics Coverage - Event Tracking Inventory

**Purpose**: Track all user actions and events for product decisions, funnel analysis, and bug detection

**Created**: 2025-11-18 (Week 16 Phase 0b)

**Last Updated**: 2025-11-18

---

## Implementation Status

**Current State**: STUB / PLACEHOLDER

- **File**: `scripts/autoload/analytics.gd` (132 lines)
- **Registered**: Autoload in `project.godot` as `Analytics`
- **Backend**: Not yet wired up (logs to GameLogger only)
- **Week 16 Goal**: Add ~20-25 new event stubs
- **Week 17 Plan**: Wire up to actual analytics backend (Firebase, Mixpanel, PostHog, etc.)

**Method Signature**:
```gdscript
Analytics.track_event(event_name: String, properties: Dictionary = {})
```

**Event Naming Convention**: `snake_case`, descriptive, past-tense action verbs

---

## Current Event Coverage (25 events)

### Helper Functions in Analytics Autoload (15 events)

**File**: [scripts/autoload/analytics.gd](../scripts/autoload/analytics.gd)

#### Hub Events (2 events)
| Event Name | Helper Function | Properties | Use Case |
|------------|----------------|------------|----------|
| `hub_opened` | `Analytics.hub_opened()` | - | Hub/Scrapyard scene opened |
| `hub_button_pressed` | `Analytics.hub_button_pressed(button)` | `button: String` | Button pressed in hub |

#### Character Events (3 events)
| Event Name | Helper Function | Properties | Use Case |
|------------|----------------|------------|----------|
| `character_created` | `Analytics.character_created(type)` | `type: String` | New character created |
| `character_deleted` | `Analytics.character_deleted(type, level)` | `type: String`<br>`level: int` | Character deleted |
| `character_selected` | `Analytics.character_selected(type, level)` | `type: String`<br>`level: int` | Character selected for play |

#### Run Events (2 events)
| Event Name | Helper Function | Properties | Use Case |
|------------|----------------|------------|----------|
| `run_started` | `Analytics.run_started(type, level)` | `type: String`<br>`level: int` | Combat run started |
| `run_ended` | `Analytics.run_ended(wave, kills, duration)` | `wave: int`<br>`kills: int`<br>`duration_seconds: float` | Combat run ended (death) |

#### First-Run Events (3 events)
| Event Name | Helper Function | Properties | Use Case |
|------------|----------------|------------|----------|
| `first_launch` | `Analytics.first_launch()` | - | First time app launched |
| `tutorial_started` | `Analytics.tutorial_started()` | - | Tutorial overlay shown |
| `tutorial_completed` | `Analytics.tutorial_completed()` | - | Tutorial dismissed/completed |

#### Save Corruption Events (3 events)
| Event Name | Helper Function | Properties | Use Case |
|------------|----------------|------------|----------|
| `save_corruption_detected` | `Analytics.save_corruption_detected(source, error)` | `source: String`<br>`error: String` | Save file corruption detected |
| `save_recovered_from_backup` | `Analytics.save_recovered_from_backup()` | - | Save recovered from backup |
| `save_recovered_from_cloud` | `Analytics.save_recovered_from_cloud()` | - | Save recovered from cloud |

#### Session Events (2 events)
| Event Name | Helper Function | Properties | Use Case |
|------------|----------------|------------|----------|
| `session_started` | `Analytics.session_started()` | `platform: String`<br>`version: String` | App session started |
| `session_ended` | `Analytics.session_ended()` | - | App session ended (quit) |

---

### Direct track_event() Calls in UI Code (10 events)

**File**: [scripts/ui/character_creation.gd](../scripts/ui/character_creation.gd)

| Event Name | Line | Properties | Use Case |
|------------|------|------------|----------|
| `character_creation_opened` | 57 | - | Character creation scene opened |
| `character_type_selected` | 203 | `type: String` | User selected character type |
| `slot_usage_banner_shown` | 238-241 | `tier: String`<br>`slots_used: int`<br>`slots_total: int` | Slot usage warning displayed |
| `name_input_started` | 256 | - | User began typing character name |
| `slot_limit_reached` | 323-326 | `tier: String`<br>`count: int`<br>`limit: int` | User hit character slot limit |
| `character_creation_cancelled` | 378 | - | User tapped Back button |
| `slot_limit_cta_shown` | 399-401 | `tier: String`<br>`tier_name: String`<br>`slot_count: int` | Upgrade CTA modal shown |
| `slot_limit_cta_clicked` | 504-507 | `action: String`<br>`tier: String`<br>`tier_name: String` | User clicked upgrade CTA |
| `slot_limit_cta_dismissed` | 538-541 | `tier: String`<br>`tier_name: String`<br>`method: String` | User dismissed upgrade CTA |
| `locked_character_clicked` | 627-630 | `character_type: String`<br>`required_tier: String`<br>`tier_name: String` | User tapped locked character |

---

## Week 16 Planned Events (~25 new events)

**Goal**: Instrument all UI interactions for Week 17 backend wireup

### Phase 3: Touch Targets (1 event)
| Event Name | Properties | Use Case |
|------------|------------|----------|
| `button_pressed` | `screen: String`<br>`button: String`<br>`timestamp: int` | Track all button interactions |

### Phase 4: Dialogs & Modals (7 events)
| Event Name | Properties | Use Case |
|------------|------------|----------|
| `dialog_opened` | `dialog_type: String`<br>`screen: String` | Any dialog/modal shown |
| `dialog_confirmed` | `dialog_type: String`<br>`action: String` | User confirmed action |
| `dialog_cancelled` | `dialog_type: String`<br>`method: String` | User cancelled dialog |
| `dialog_dismissed` | `method: String` | Non-button dismissal (swipe, tap outside) |
| `delete_confirmation_step_1` | `item_type: String` | Progressive delete first tap |
| `delete_confirmation_confirmed` | `item_type: String` | Progressive delete second tap |
| `delete_confirmation_timeout` | `item_type: String` | Progressive delete timed out |
| `delete_undone` | `item_type: String` | User used undo toast |

### Phase 5: Visual Feedback (4 events)
| Event Name | Properties | Use Case |
|------------|------------|----------|
| `scene_transition_started` | `from_scene: String`<br>`to_scene: String` | Scene loading begins |
| `scene_transition_completed` | `scene: String`<br>`duration_ms: int` | Scene loaded successfully |
| `animation_preference_changed` | `enabled: bool` | User toggled animations setting |
| `haptic_preference_changed` | `enabled: bool` | User toggled haptics setting |

### Phase 7: Combat HUD (4 events)
| Event Name | Properties | Use Case |
|------------|------------|----------|
| `pause_button_pressed` | `source: String`<br>`wave: int`<br>`timestamp: int` | User paused from HUD |
| `combat_started` | `character_type: String`<br>`level: int` | Combat begins |
| `combat_ended` | `duration_seconds: float`<br>`wave_reached: int` | Combat ends |
| `hud_toggled` | `visible: bool` | HUD show/hide toggle (if implemented) |

### Additional UI Events (9 events)
| Event Name | Properties | Use Case |
|------------|------------|----------|
| `character_roster_opened` | - | Character roster scene opened |
| `character_card_tapped` | `character_id: String`<br>`character_type: String` | User tapped character card |
| `character_details_opened` | `character_id: String`<br>`character_type: String` | Character details panel shown |
| `settings_opened` | `source: String` | Settings menu opened |
| `settings_changed` | `setting: String`<br>`value: Variant` | Settings value changed |
| `death_screen_opened` | `wave: int`<br>`kills: int`<br>`xp_earned: int` | Death screen shown |
| `retry_button_pressed` | `wave_reached: int` | User retried from death screen |
| `return_to_hub_pressed` | `source: String` | User returned to hub |
| `app_backgrounded` | `duration_seconds: float` | App went to background |

---

## Total Event Coverage

| Category | Current Events | Week 16 Planned | Total After Week 16 |
|----------|----------------|-----------------|---------------------|
| Hub | 2 | 1 | 3 |
| Character | 13 | 3 | 16 |
| Run/Combat | 2 | 4 | 6 |
| Dialogs | 0 | 8 | 8 |
| Visual Feedback | 0 | 4 | 4 |
| Settings | 0 | 3 | 3 |
| Session | 5 | 1 | 6 |
| Save/Corruption | 3 | 0 | 3 |
| **TOTAL** | **25** | **24** | **49** |

---

## Implementation Guidelines

### Adding New Events

**Pattern 1: Helper function in Analytics autoload** (preferred for reusable events)
```gdscript
# In scripts/autoload/analytics.gd
func button_pressed(screen: String, button: String) -> void:
    """Track button press event"""
    track_event("button_pressed", {"screen": screen, "button": button})

# Usage
Analytics.button_pressed("hub", "play")
```

**Pattern 2: Direct track_event() call** (for one-off events)
```gdscript
# In any script
Analytics.track_event("custom_event", {"property": "value"})
```

### Event Naming

- **Format**: `noun_past_tense_verb` (e.g., `button_pressed`, `character_created`)
- **Use snake_case**: Not camelCase or PascalCase
- **Be specific**: `character_type_selected` not `option_clicked`
- **Past tense**: Events describe what already happened

### Properties

- **Use Dictionary**: `{"key": value}`
- **Common properties**:
  - `screen: String` - Where event occurred
  - `source: String` - What triggered event
  - `timestamp: int` - Time.get_ticks_msec()
  - `duration_ms: int` - For timed events
- **Type-safe values**: Use enums and constants, not magic strings

---

## Week 17: Backend Wireup Checklist

When connecting to actual analytics backend:

- [ ] Choose analytics provider (Firebase, Mixpanel, PostHog, Amplitude)
- [ ] Add provider SDK to project
- [ ] Update `Analytics.track_event()` to send to backend
- [ ] Add user identification (set user ID from CharacterService)
- [ ] Add session management (session ID, session duration)
- [ ] Test event delivery in production
- [ ] Set up analytics dashboard and funnels
- [ ] Document funnel tracking and KPIs

---

## Usage Examples

```gdscript
# Simple event (no properties)
Analytics.track_event("tutorial_completed", {})

# Event with properties
Analytics.track_event("character_created", {"type": "Scavenger", "level": 1})

# Using helper function
Analytics.character_selected("Engineer", 5)

# Event with timestamp
Analytics.track_event("button_pressed", {
    "screen": "hub",
    "button": "play",
    "timestamp": Time.get_ticks_msec()
})

# Event with complex properties
Analytics.track_event("run_ended", {
    "wave": 15,
    "kills": 234,
    "duration_seconds": 480.5,
    "character_type": "Scavenger",
    "character_level": 8,
    "upgrades_selected": ["damage", "speed", "health"]
})
```

---

## Related Documentation

- [Week 16 Implementation Plan](migration/week16-implementation-plan.md) - Full mobile UI overhaul plan
- [Week 16 Pre-Work Findings](migration/week16-pre-work-findings.md) - Research notes
- [Analytics Autoload](../scripts/autoload/analytics.gd) - Current implementation

---

**Last Updated**: 2025-11-18 by Claude Code (Week 16 Phase 0b)
