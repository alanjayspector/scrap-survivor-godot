# Controller Support

## Table of Contents
1. [System Overview](#system-overview)
2. [Design Philosophy](#design-philosophy)
3. [SDL3 Integration](#sdl3-integration)
4. [Control Schemes](#control-schemes)
5. [UI Adaptation](#ui-adaptation)
6. [Input Detection & Auto-Switching](#input-detection--auto-switching)
7. [Haptic Feedback & Rumble](#haptic-feedback--rumble)
8. [On-Screen Button Prompts](#on-screen-button-prompts)
9. [Remapping & Customization](#remapping--customization)
10. [Accessibility Features](#accessibility-features)
11. [Technical Architecture](#technical-architecture)
12. [Implementation Strategy](#implementation-strategy)
13. [Balancing Considerations](#balancing-considerations)
14. [Open Questions & Future Enhancements](#open-questions--future-enhancements)
15. [Summary](#summary)

---

## System Overview

**Controller Support** provides full gamepad compatibility for players who prefer controllers over keyboard/mouse. Based on market research (Brotato analysis), controller support is a **FREE feature available to all players**, not gated behind Premium/Subscription tiers.

### Core Concepts

- **FREE Access**: All players have full controller support (not Premium-gated)
- **SDL3 Backend**: Godot 4.5.1 uses SDL3 for gamepad detection and input
- **Multiple Control Schemes**: Pre-configured layouts (Modern, Classic, Custom) with full remapping
- **UI Adaptation**: All menus and HUD elements adapt to gamepad navigation
- **Auto-Detection**: Seamless switching between keyboard/mouse and controller
- **Feature Parity**: Controllers can access all game features (no degraded experience)
- **Platform Support**: Works on PC, Steam Deck, and future console ports

### Value Proposition

**For Players**:
- Play from couch/bed with comfortable controller
- Accessibility option for players with mobility issues
- Familiar controls for console gamers
- Better ergonomics for long sessions
- Steam Deck compatibility out of the box

**For Business**:
- Market research shows controller support expected as baseline feature (not Premium)
- Enables Steam Deck market (fast-growing segment)
- Positions game for future console ports (Switch, Xbox, PlayStation)
- Improves accessibility (larger addressable market)
- Competitive parity with similar games (Brotato, Vampire Survivors)
- Prevents negative reviews ("no controller support")

### Key Features

1. **Plug-and-Play**: Controllers work immediately, no setup required
2. **Multiple Schemes**: Modern (dual-stick shooter), Classic (d-pad movement), Custom (full remapping)
3. **Adaptive UI**: Button prompts change dynamically (Xbox: A button, PlayStation: ✕, Nintendo: B)
4. **Rumble Support**: Haptic feedback for hits, deaths, boss spawns
5. **Gyro Aiming** (optional): Steam Deck / Switch Pro Controller gyro for precise aiming
6. **One-Handed Mode** (accessibility): Play with single hand using adaptive controls
7. **Deadzone Customization**: Adjust stick sensitivity for drift compensation
8. **On-Screen Prompts**: Context-sensitive button hints (e.g., "Press A to confirm")

---

## Design Philosophy

Controller support must feel natural, not like an afterthought.

### Core Principles

#### 1. Free for All, Not Premium-Gated

**Research Finding**: Brotato offers full controller support in both free and premium versions. Players expect controller support as baseline feature.

**Decision**: Controller support is **FREE** for all tiers.

**Rationale**:
- Market expectation is that controllers are basic accessibility feature
- Gating behind paywall would generate negative reviews
- Steam Deck users expect controller support (growing market)
- Future console ports require controller support anyway

**What This Means**:
- ✅ All control schemes available to Free tier
- ✅ Full remapping available to Free tier
- ✅ All UI adaptations available to Free tier
- ✅ Rumble/haptics available to Free tier

**No Premium Features**: Controller support has no tier differentiation.

---

#### 2. Feature Parity, Not Degraded Experience

**Problem**: Some games make controllers second-class citizens (missing features, clunky menus).

**Solution**:
- **Every feature accessible via controller**: Shop, inventory, perks, settings, everything
- **Optimized navigation**: D-pad/stick jumps between sections efficiently
- **No mouse cursor required**: Never force player to use mouse while on controller
- **Equal precision**: Aiming with controller feels as good as mouse (aim assist if needed)

**Test**: Player should be able to complete entire playthrough without touching keyboard/mouse.

---

#### 3. Instant Switching, Not Manual Toggle

**Problem**: Some games require settings menu visit to switch input methods.

**Solution**:
- **Auto-detection**: Game detects controller input and switches immediately
- **Seamless switching**: Press keyboard key → keyboard mode, press controller button → controller mode
- **No confirmation dialogs**: Just works, no "Switch to controller mode?" popups

**Implementation**:
```gdscript
func _input(event):
    if event is InputEventJoypadButton or event is InputEventJoypadMotion:
        if current_input_mode != InputMode.CONTROLLER:
            switch_to_controller_mode()
    elif event is InputEventKey or event is InputEventMouse:
        if current_input_mode != InputMode.KEYBOARD_MOUSE:
            switch_to_keyboard_mouse_mode()
```

---

#### 4. Adaptive Prompts, Not Generic Icons

**Problem**: Showing Xbox buttons to PlayStation players (or vice versa) is confusing.

**Solution**:
- **Device Detection**: Detect controller type (Xbox, PlayStation, Nintendo, Generic)
- **Dynamic Prompts**: Show correct button icons based on detected controller
- **Fallback**: If controller unknown, show generic prompts ("Button 0", "Button 1")

**Examples**:
```
Xbox Controller detected:
  "Press A to confirm"   [A button icon]

PlayStation Controller detected:
  "Press ✕ to confirm"   [✕ button icon]

Nintendo Switch Pro Controller detected:
  "Press B to confirm"   [B button icon]
```

---

#### 5. Comfortable, Not Frustrating

**Problem**: Poor default bindings or lack of customization frustrates players.

**Solution**:
- **Sensible defaults**: Modern dual-stick shooter layout (left stick move, right stick aim)
- **Multiple presets**: Modern, Classic (d-pad movement), Custom
- **Full remapping**: Every button remappable
- **Deadzone adjustment**: Compensate for stick drift
- **Sensitivity curves**: Linear, exponential, custom

**Accessibility**: One-handed mode for players with mobility limitations.

---

## SDL3 Integration

Godot 4.5.1 uses **SDL3** as its gamepad backend. SDL3 provides cross-platform controller support with extensive device database.

### SDL3 Features Used

1. **Controller Database**: SDL3 includes mappings for 600+ controllers
2. **Hot-Plugging**: Detect controllers connected/disconnected during gameplay
3. **Rumble/Haptics**: Access to controller vibration motors
4. **Gyroscope**: Steam Deck / Switch Pro Controller gyro data
5. **Touchpad**: DualSense touchpad support (future)
6. **Adaptive Triggers**: DualSense trigger resistance (future)

### Godot API

```gdscript
# Detect connected controllers
func get_connected_controllers() -> Array[int]:
    var controllers = []
    for joy_id in Input.get_connected_joypads():
        controllers.append(joy_id)
    return controllers

# Get controller name
func get_controller_name(joy_id: int) -> String:
    return Input.get_joy_name(joy_id)

# Start rumble
func rumble(joy_id: int, weak_magnitude: float, strong_magnitude: float, duration: float):
    Input.start_joy_vibration(joy_id, weak_magnitude, strong_magnitude, duration)

# Stop rumble
func stop_rumble(joy_id: int):
    Input.stop_joy_vibration(joy_id)

# Get gyro data (if supported)
func get_gyro(joy_id: int) -> Vector3:
    return Input.get_joy_axis(joy_id, JOY_AXIS_GYRO_X_Y_Z)
```

### Controller Detection

**Identifying Controller Type**:
```gdscript
func detect_controller_type(joy_id: int) -> ControllerType:
    var name = Input.get_joy_name(joy_id).to_lower()

    if "xbox" in name or "xinput" in name:
        return ControllerType.XBOX
    elif "playstation" in name or "dualshock" in name or "dualsense" in name:
        return ControllerType.PLAYSTATION
    elif "nintendo" in name or "switch" in name:
        return ControllerType.NINTENDO
    elif "steam" in name:
        return ControllerType.STEAM_DECK
    else:
        return ControllerType.GENERIC

enum ControllerType {
    XBOX,
    PLAYSTATION,
    NINTENDO,
    STEAM_DECK,
    GENERIC
}
```

---

## Control Schemes

### Scheme 1: Modern (Default - Dual-Stick Shooter)

**Target Audience**: Players familiar with modern twin-stick shooters.

**Layout**:
```
Left Stick: Movement (8-directional)
Right Stick: Aim direction (auto-fire when moving stick)

Face Buttons:
  A / ✕ / B: Interact / Confirm
  B / ○ / A: Cancel / Back
  X / □ / Y: Use item / Heal
  Y / △ / X: Special ability

Bumpers:
  LB / L1: Previous weapon
  RB / R1: Next weapon

Triggers:
  LT / L2: Dodge roll
  RT / R2: Manual fire (if auto-fire disabled)

D-Pad:
  Up: Open shop
  Down: Open inventory
  Left: Quick-select item 1
  Right: Quick-select item 2

Menu Button: Pause menu
View Button: Stats overlay
```

**Philosophy**: Hands never leave sticks during combat. All actions accessible without repositioning thumbs.

---

### Scheme 2: Classic (D-Pad Movement)

**Target Audience**: Players who prefer traditional 4-directional movement.

**Layout**:
```
D-Pad: Movement (4-directional: up/down/left/right)
Right Stick: Aim direction

Face Buttons:
  A / ✕ / B: Shoot
  B / ○ / A: Dodge roll
  X / □ / Y: Use item
  Y / △ / X: Interact

Bumpers:
  LB / L1: Previous weapon
  RB / R1: Next weapon

Triggers:
  LT / L2: Secondary fire
  RT / R2: Primary fire

Left Stick: (Unused in movement, available for other functions)

Menu Button: Pause menu
View Button: Stats overlay
```

**Philosophy**: Inspired by classic arcade games. Precise 4-directional movement.

---

### Scheme 3: Custom

**Target Audience**: Players who want full control over bindings.

**Features**:
- Every button remappable
- Save up to 5 custom profiles
- Share bindings via code (similar to trading cards)
- Import popular community layouts

**Remapping UI**:
```
┌────────────────────────────────────────┐
│  Controller Remapping                  │
├────────────────────────────────────────┤
│                                        │
│  Movement: [Left Stick ▼]              │
│  Aim: [Right Stick ▼]                  │
│  Fire: [RT ▼]                          │
│  Dodge: [A Button ▼]                   │
│  Interact: [X Button ▼]                │
│  ...                                   │
│                                        │
│  [Reset to Default]                    │
│  [Save Profile]                        │
│  [Load Profile]                        │
│                                        │
└────────────────────────────────────────┘
```

---

### One-Handed Mode (Accessibility)

**Target Audience**: Players with mobility limitations affecting one hand.

**Concept**: All essential functions accessible with one hand.

**Layout (Left Hand Only)**:
```
Left Stick: Movement
L3 (Stick Click): Auto-aim toggle (aims at nearest enemy)

D-Pad:
  Up: Fire weapon
  Down: Dodge roll
  Left: Previous weapon
  Right: Next weapon

LB: Use item
LT: Interact

(Right hand controls completely unused)
```

**Auto-Aim**: When enabled, automatically aims at nearest enemy. Player only controls movement and firing.

---

## UI Adaptation

All UI screens must be navigable with controller.

### Menu Navigation

**D-Pad / Left Stick**:
- Up/Down: Navigate menu items vertically
- Left/Right: Navigate tabs horizontally or adjust sliders

**Face Buttons**:
- A / ✕: Confirm selection
- B / ○: Back / Cancel

**Bumpers**:
- LB / L1: Previous tab
- RB / R1: Next tab

**Visual Feedback**:
- Selected item highlighted with border
- Hold A to confirm (prevents accidental purchases)

---

### Shop UI (Controller-Optimized)

**Layout**:
```
┌──────────────────────────────────────────────────┐
│  SHOP                                     [LB/RB]│
│  [Weapons]  [Items]  [Perks]                     │
├──────────────────────────────────────────────────┤
│                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │  Pistol  │  │ Shotgun  │  │  Rifle   │ ◄─┐   │
│  │  100 $   │  │  250 $   │  │  400 $   │   │   │
│  └──────────┘  └──────────┘  └──────────┘   │   │
│      ▲                                       │   │
│      └─ Selected (highlighted border)       │   │
│                                              │   │
│  ┌──────────────────────────────────────┐   │   │
│  │  Pistol                              │   │   │
│  │  Damage: 10  |  Fire Rate: 2.0/s     │   │   │
│  │  Range: Medium                       │   │   │
│  │                                      │   │   │
│  │  💡 Advisor: Good starter weapon     │   │   │
│  │     for balanced playstyles          │   │   │
│  │                                      │   │   │
│  │  [Hold A to Purchase]                │   │   │
│  └──────────────────────────────────────┘   │   │
│                                              │   │
│  D-Pad: Navigate items                      │   │
│  A: Purchase  |  B: Close Shop               │   │
│  LB/RB: Switch tabs                          │   │
│                                              │   │
└──────────────────────────────────────────────────┘
```

**Navigation**:
- D-Pad / Left Stick: Move selection between items (grid layout)
- LB / RB: Switch tabs (Weapons, Items, Perks)
- A: Purchase selected item (hold to confirm)
- B: Close shop

**Features**:
- Grid layout (not list) optimized for controller cursor movement
- Large item cards easy to see from couch
- Hold-to-confirm prevents accidental purchases
- Button hints always visible at bottom

---

### Pause Menu (Controller)

**Layout**:
```
┌──────────────────────────┐
│   PAUSED                 │
├──────────────────────────┤
│                          │
│  ▶ Resume                │
│    Settings              │
│    Achievements          │
│    Feature Requests      │
│    Quit to Menu          │
│                          │
│  A: Select  |  B: Resume │
│                          │
└──────────────────────────┘
```

**Navigation**:
- Up/Down: Select menu item
- A: Confirm
- B: Resume game (quick exit)

---

### Inventory Management (Controller)

**Challenge**: Inventory can have 30+ items, controller navigation must be efficient.

**Layout**:
```
┌────────────────────────────────────────────────┐
│  INVENTORY                          [LB/RB]    │
│  [All]  [Weapons]  [Items]  [Sort: Rarity ▼]  │
├────────────────────────────────────────────────┤
│                                                │
│  [Pistol] [Shotgun] [Rifle] [Minigun]         │
│  [Body A] [Helmet ] [Boots ] [Gloves ]        │
│  [Ring  ] [Amulet ] [Belt  ] [...]            │
│      ▲                                         │
│      └─ Selected                               │
│                                                │
│  ┌────────────────────────────────┐            │
│  │  Pistol                        │            │
│  │  Equipped | Durability: 80/100 │            │
│  │                                │            │
│  │  [A] Unequip  [X] Repair       │            │
│  │  [Y] Drop                      │            │
│  └────────────────────────────────┘            │
│                                                │
│  D-Pad: Navigate  |  LB/RB: Tabs               │
│  A: Equip/Unequip |  B: Close                  │
│                                                │
└────────────────────────────────────────────────┘
```

**Features**:
- Grid layout with clear visual separation
- Selected item details show at bottom
- Context actions (Equip, Repair, Drop) on face buttons
- Sort options accessible via dropdown (A to expand, D-pad to select)

---

### In-Game HUD (Controller-Friendly)

**Minimal Obstruction**: HUD elements positioned to avoid blocking gameplay.

**Layout**:
```
Top-Left:
  HP: [████████░░] 80/100
  Scrap: 1,234

Top-Right:
  Wave: 15
  Timer: 12:34

Bottom-Left:
  Weapon 1: Pistol [LB]
  Weapon 2: Shotgun [RB]
  Active: Pistol ▸

Bottom-Right:
  Item: Health Potion [X]
  Uses: 3

Bottom-Center:
  [Current objective/hint]
  "Press A to pick up item"
```

**No Cursor**: Controller mode hides mouse cursor entirely.

---

## Input Detection & Auto-Switching

### Seamless Mode Switching

**Goal**: Game feels native to whichever input device player is using.

**Implementation**:
```gdscript
# services/InputModeService.gd
class_name InputModeService
extends Node

signal input_mode_changed(new_mode: InputMode)

enum InputMode {
    KEYBOARD_MOUSE,
    CONTROLLER
}

var current_mode: InputMode = InputMode.KEYBOARD_MOUSE
var last_input_time: float = 0.0
var mode_switch_cooldown: float = 0.2  # Prevent rapid switching

func _ready():
    # Detect controllers at startup
    if Input.get_connected_joypads().size() > 0:
        # Default to controller if one is connected
        current_mode = InputMode.CONTROLLER
        emit_signal("input_mode_changed", current_mode)

func _input(event):
    var now = Time.get_ticks_msec() / 1000.0

    # Ignore inputs too close together (debounce)
    if now - last_input_time < mode_switch_cooldown:
        return

    # Detect controller input
    if event is InputEventJoypadButton or event is InputEventJoypadMotion:
        # Ignore tiny stick drift
        if event is InputEventJoypadMotion:
            if abs(event.axis_value) < 0.3:
                return

        if current_mode != InputMode.CONTROLLER:
            switch_mode(InputMode.CONTROLLER)
            last_input_time = now

    # Detect keyboard/mouse input
    elif event is InputEventKey or event is InputEventMouse:
        if current_mode != InputMode.KEYBOARD_MOUSE:
            switch_mode(InputMode.KEYBOARD_MOUSE)
            last_input_time = now

func switch_mode(new_mode: InputMode):
    current_mode = new_mode
    emit_signal("input_mode_changed", new_mode)

    # Update UI prompts
    UIPromptService.update_prompts(new_mode)

    # Show/hide mouse cursor
    if new_mode == InputMode.CONTROLLER:
        Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
    else:
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
```

### UI Prompt Updates

**Dynamic Button Hints**:
```gdscript
# services/UIPromptService.gd
class_name UIPromptService
extends Node

var current_controller_type: ControllerType = ControllerType.XBOX

func update_prompts(input_mode: InputMode):
    if input_mode == InputMode.CONTROLLER:
        # Detect controller type
        if Input.get_connected_joypads().size() > 0:
            var joy_id = Input.get_connected_joypads()[0]
            current_controller_type = detect_controller_type(joy_id)

        # Update all button prompts in UI
        update_all_prompt_icons()
    else:
        # Show keyboard/mouse prompts
        update_all_prompt_icons()

func get_button_icon(action: String) -> Texture2D:
    if InputModeService.current_mode == InputMode.KEYBOARD_MOUSE:
        return get_keyboard_icon(action)
    else:
        return get_controller_icon(action, current_controller_type)

func get_controller_icon(action: String, controller_type: ControllerType) -> Texture2D:
    match action:
        "ui_accept":
            match controller_type:
                ControllerType.XBOX:
                    return load("res://assets/ui/prompts/xbox_a.png")
                ControllerType.PLAYSTATION:
                    return load("res://assets/ui/prompts/ps_cross.png")
                ControllerType.NINTENDO:
                    return load("res://assets/ui/prompts/switch_b.png")
        "ui_cancel":
            match controller_type:
                ControllerType.XBOX:
                    return load("res://assets/ui/prompts/xbox_b.png")
                ControllerType.PLAYSTATION:
                    return load("res://assets/ui/prompts/ps_circle.png")
                ControllerType.NINTENDO:
                    return load("res://assets/ui/prompts/switch_a.png")
        # ... etc
```

---

## Haptic Feedback & Rumble

### Rumble Events

**When to Rumble**:
1. **Taking Damage**: Light rumble (weak motor)
2. **Death**: Heavy rumble (strong motor, 1 second)
3. **Boss Spawn**: Heavy rumble pulse (3 short bursts)
4. **Item Pickup**: Very light rumble (tactile feedback)
5. **Weapon Fire**: Continuous light rumble while firing (immersion)
6. **Level Up**: Medium rumble (celebration)

**Implementation**:
```gdscript
# services/HapticService.gd
class_name HapticService
extends Node

var joy_id: int = 0  # Primary controller

func rumble_damage_taken(damage: float):
    # Rumble intensity scales with damage
    var intensity = clamp(damage / 100.0, 0.1, 1.0)
    Input.start_joy_vibration(joy_id, intensity * 0.3, intensity * 0.6, 0.2)

func rumble_death():
    # Strong rumble for 1 second
    Input.start_joy_vibration(joy_id, 0.8, 1.0, 1.0)

func rumble_boss_spawn():
    # Three short pulses
    for i in range(3):
        Input.start_joy_vibration(joy_id, 0.5, 0.7, 0.15)
        await get_tree().create_timer(0.2).timeout

func rumble_item_pickup():
    # Very light tactile feedback
    Input.start_joy_vibration(joy_id, 0.1, 0.1, 0.1)

func rumble_weapon_fire():
    # Continuous while firing
    Input.start_joy_vibration(joy_id, 0.15, 0.0, 0.05)

func rumble_level_up():
    # Medium celebration rumble
    Input.start_joy_vibration(joy_id, 0.4, 0.6, 0.5)
```

### User Settings

**Rumble Settings**:
```
Rumble Enabled: [✓]
Rumble Intensity: [████████░░] 80%

Rumble Events:
  [✓] Damage
  [✓] Death
  [✓] Boss Spawns
  [✓] Item Pickups
  [✓] Weapon Fire
  [✓] Level Up
```

**Implementation**:
```gdscript
# Allow users to disable specific rumble events
var rumble_settings = {
    "damage": true,
    "death": true,
    "boss_spawn": true,
    "item_pickup": true,
    "weapon_fire": true,
    "level_up": true,
    "intensity": 0.8
}

func rumble_damage_taken(damage: float):
    if not rumble_settings.damage:
        return

    var intensity = clamp(damage / 100.0, 0.1, 1.0) * rumble_settings.intensity
    Input.start_joy_vibration(joy_id, intensity * 0.3, intensity * 0.6, 0.2)
```

---

## On-Screen Button Prompts

### Context-Sensitive Prompts

**Show button hints for current context**:

**Example (Near Item)**:
```
[Item on ground]
    ↓
"Press [A] to pick up"
```

**Example (Shop Open)**:
```
[Shop UI]
Bottom of screen:
"[A] Purchase  |  [B] Close  |  [LB/RB] Switch Tab"
```

**Example (Inventory)**:
```
[Selected Item]
"[A] Equip  |  [X] Drop  |  [Y] Repair"
```

**Implementation**:
```gdscript
# UI/ContextPrompt.gd
extends Label

func show_prompt(action: String, context: String):
    var icon = UIPromptService.get_button_icon(action)
    var button_name = UIPromptService.get_button_name(action)

    # Example: "Press [A] to pick up"
    text = "Press %s to %s" % [button_name, context]

    # If we have icon texture, replace [A] with actual icon
    # (Using RichTextLabel for inline images)
```

---

## Remapping & Customization

### Full Button Remapping

**Remapping UI**:
```
┌────────────────────────────────────────────────┐
│  Controller Settings                           │
├────────────────────────────────────────────────┤
│                                                │
│  Control Scheme: [Modern ▼]                    │
│                                                │
│  ──── MOVEMENT ────                            │
│  Move: [Left Stick]                 [Remap]    │
│  Dodge: [LT]                        [Remap]    │
│                                                │
│  ──── COMBAT ────                              │
│  Aim: [Right Stick]                 [Remap]    │
│  Fire: [Auto-aim]                   [Remap]    │
│  Previous Weapon: [LB]              [Remap]    │
│  Next Weapon: [RB]                  [Remap]    │
│                                                │
│  ──── ACTIONS ────                             │
│  Interact: [A]                      [Remap]    │
│  Use Item: [X]                      [Remap]    │
│  Special: [Y]                       [Remap]    │
│                                                │
│  ──── ADVANCED ────                            │
│  Left Stick Deadzone: [████░░░░░░] 20%        │
│  Right Stick Deadzone: [████░░░░░░] 20%       │
│  Stick Sensitivity: [███████░░░] 70%          │
│                                                │
│  [Reset to Default] [Save Profile] [Load]      │
│                                                │
└────────────────────────────────────────────────┘
```

**Remapping Process**:
1. Select action to remap
2. Press "Remap" button
3. Prompt: "Press new button for [Action]"
4. Player presses desired button
5. Binding updated, prompt shows new binding
6. Save profile

**Implementation**:
```gdscript
# services/InputRemappingService.gd
class_name InputRemappingService
extends Node

signal binding_changed(action: String, new_binding: String)

var custom_bindings: Dictionary = {}

func start_remapping(action: String):
    # Show prompt
    RemappingDialog.show("Press new button for %s" % action)

    # Wait for next controller input
    await wait_for_controller_input()

    # Get input
    var new_binding = get_last_controller_input()

    # Update binding
    custom_bindings[action] = new_binding
    InputMap.action_erase_events(action)
    InputMap.action_add_event(action, new_binding)

    # Save
    save_bindings()

    emit_signal("binding_changed", action, new_binding)

func save_bindings():
    var save_data = {
        "bindings": custom_bindings,
        "deadzone": deadzone_settings,
        "sensitivity": sensitivity_settings
    }

    var file = FileAccess.open("user://controller_bindings.json", FileAccess.WRITE)
    file.store_string(JSON.stringify(save_data))
    file.close()

func load_bindings():
    if not FileAccess.file_exists("user://controller_bindings.json"):
        return

    var file = FileAccess.open("user://controller_bindings.json", FileAccess.READ)
    var json = JSON.parse_string(file.get_as_text())
    file.close()

    custom_bindings = json.bindings
    # Apply bindings to InputMap
    for action in custom_bindings:
        InputMap.action_erase_events(action)
        InputMap.action_add_event(action, custom_bindings[action])
```

---

### Deadzone Configuration

**Why Needed**: Controllers develop "stick drift" over time (stick reports input when untouched).

**Deadzone**: Ignore stick input below threshold.

**UI**:
```
Left Stick Deadzone: [████░░░░░░] 20%

Test: Move left stick slightly
[Visualization showing stick position and deadzone circle]
```

**Implementation**:
```gdscript
var left_stick_deadzone: float = 0.2
var right_stick_deadzone: float = 0.2

func get_stick_input(stick: Stick) -> Vector2:
    var raw_input = Vector2.ZERO

    if stick == Stick.LEFT:
        raw_input.x = Input.get_joy_axis(joy_id, JOY_AXIS_LEFT_X)
        raw_input.y = Input.get_joy_axis(joy_id, JOY_AXIS_LEFT_Y)
        var deadzone = left_stick_deadzone
    else:
        raw_input.x = Input.get_joy_axis(joy_id, JOY_AXIS_RIGHT_X)
        raw_input.y = Input.get_joy_axis(joy_id, JOY_AXIS_RIGHT_Y)
        var deadzone = right_stick_deadzone

    # Apply deadzone
    if raw_input.length() < deadzone:
        return Vector2.ZERO
    else:
        # Rescale to remove deadzone (so deadzone→1.0 maps to 0→1.0)
        return (raw_input - raw_input.normalized() * deadzone) / (1.0 - deadzone)
```

---

### Sensitivity Curves

**Linear** (default): Input maps directly to output (1:1 ratio).

**Exponential**: Small inputs have less effect (precise aiming), large inputs have more effect (fast turns).

**Custom**: Player-defined curve.

**UI**:
```
Stick Sensitivity Curve:

[ Graph showing input (x-axis) vs output (y-axis) ]

● Linear
○ Exponential
○ Custom

Sensitivity: [███████░░░] 70%
```

**Implementation**:
```gdscript
enum SensitivityCurve {
    LINEAR,
    EXPONENTIAL,
    CUSTOM
}

var sensitivity_curve: SensitivityCurve = SensitivityCurve.LINEAR
var sensitivity_multiplier: float = 0.7

func apply_sensitivity_curve(input: Vector2) -> Vector2:
    var length = input.length()

    match sensitivity_curve:
        SensitivityCurve.LINEAR:
            return input * sensitivity_multiplier

        SensitivityCurve.EXPONENTIAL:
            # Square the input magnitude (keeps direction)
            var curved_length = pow(length, 2) * sensitivity_multiplier
            return input.normalized() * curved_length

        SensitivityCurve.CUSTOM:
            # Use custom curve data
            return apply_custom_curve(input)
```

---

## Accessibility Features

### One-Handed Mode

**For players with mobility limitations affecting one hand**.

**Mode 1: Left Hand Only**:
```
Movement: Left Stick
Auto-Aim: L3 click (aims at nearest enemy)
Fire: D-Pad Up
Dodge: D-Pad Down
Switch Weapon: D-Pad Left/Right
Use Item: LB
Interact: LT
```

**Mode 2: Right Hand Only**:
```
Movement: D-Pad (4-directional)
Aim: Right Stick
Fire: RT
Dodge: RB
Switch Weapon: R3 click
Use Item: A
Interact: B
```

**Auto-Aim**: When enabled, automatically aims at closest enemy. Player only controls movement and firing timing.

---

### Button Hold Duration

**Problem**: Some players have difficulty with rapid button presses or precise timing.

**Solution**: Adjust hold duration for actions.

**UI**:
```
Button Hold Duration:

Confirm Action: [███░░░░░░░] 0.3 seconds
  (How long to hold A to confirm purchases)

Instant: No hold required (tap to confirm)
Short:   0.3 seconds
Medium:  0.5 seconds
Long:    1.0 seconds
```

**Implementation**:
```gdscript
var confirm_hold_duration: float = 0.3

# In shop UI
func _on_purchase_button_pressed():
    if confirm_hold_duration > 0:
        # Show hold progress
        hold_timer = 0.0
        while hold_timer < confirm_hold_duration:
            hold_timer += get_process_delta_time()
            update_hold_progress(hold_timer / confirm_hold_duration)
            await get_tree().process_frame

            # If button released, cancel
            if not Input.is_action_pressed("ui_accept"):
                cancel_purchase()
                return

        # Hold completed
        complete_purchase()
    else:
        # Instant purchase
        complete_purchase()
```

---

### Colorblind Mode Integration

**Controller prompts must respect colorblind mode**.

**Example**: Don't rely on color alone to distinguish buttons.
```
❌ Bad: "Press the red button"
✅ Good: "Press A (red button)" [shows A icon]
```

**Implementation**: Button icons already include letters/symbols, not just colors.

---

## Technical Architecture

### Input Action Map

**Godot InputMap Configuration**:
```gdscript
# project.godot (or via code)

# Movement
InputMap.add_action("move_up")
InputMap.action_add_event("move_up", key_event(KEY_W))
InputMap.action_add_event("move_up", joypad_axis_event(JOY_AXIS_LEFT_Y, -1.0))

InputMap.add_action("move_down")
InputMap.action_add_event("move_down", key_event(KEY_S))
InputMap.action_add_event("move_down", joypad_axis_event(JOY_AXIS_LEFT_Y, 1.0))

InputMap.add_action("move_left")
InputMap.action_add_event("move_left", key_event(KEY_A))
InputMap.action_add_event("move_left", joypad_axis_event(JOY_AXIS_LEFT_X, -1.0))

InputMap.add_action("move_right")
InputMap.action_add_event("move_right", key_event(KEY_D))
InputMap.action_add_event("move_right", joypad_axis_event(JOY_AXIS_LEFT_X, 1.0))

# Aim (right stick)
InputMap.add_action("aim")
InputMap.action_add_event("aim", joypad_axis_event(JOY_AXIS_RIGHT_X))  # X component
InputMap.action_add_event("aim", joypad_axis_event(JOY_AXIS_RIGHT_Y))  # Y component

# Actions
InputMap.add_action("fire")
InputMap.action_add_event("fire", key_event(KEY_SPACE))
InputMap.action_add_event("fire", mouse_button_event(MOUSE_BUTTON_LEFT))
InputMap.action_add_event("fire", joypad_button_event(JOY_BUTTON_RIGHT_SHOULDER))  # RT

InputMap.add_action("dodge")
InputMap.action_add_event("dodge", key_event(KEY_SHIFT))
InputMap.action_add_event("dodge", joypad_button_event(JOY_BUTTON_LEFT_SHOULDER))  # LT

InputMap.add_action("interact")
InputMap.action_add_event("interact", key_event(KEY_E))
InputMap.action_add_event("interact", joypad_button_event(JOY_BUTTON_A))

# UI Navigation
InputMap.add_action("ui_accept")
InputMap.action_add_event("ui_accept", key_event(KEY_ENTER))
InputMap.action_add_event("ui_accept", joypad_button_event(JOY_BUTTON_A))

InputMap.add_action("ui_cancel")
InputMap.action_add_event("ui_cancel", key_event(KEY_ESCAPE))
InputMap.action_add_event("ui_cancel", joypad_button_event(JOY_BUTTON_B))

# ... etc
```

---

### Controller State Manager

```gdscript
# services/ControllerService.gd
class_name ControllerService
extends Node

signal controller_connected(joy_id: int)
signal controller_disconnected(joy_id: int)

var connected_controllers: Array[int] = []
var primary_controller_id: int = -1

func _ready():
    # Detect controllers at startup
    refresh_controllers()

    # Listen for connection/disconnection events
    Input.joy_connection_changed.connect(_on_joy_connection_changed)

func refresh_controllers():
    connected_controllers = Input.get_connected_joypads()

    if connected_controllers.size() > 0 and primary_controller_id == -1:
        primary_controller_id = connected_controllers[0]
        emit_signal("controller_connected", primary_controller_id)

func _on_joy_connection_changed(device_id: int, connected: bool):
    if connected:
        if device_id not in connected_controllers:
            connected_controllers.append(device_id)
            emit_signal("controller_connected", device_id)

            # Set as primary if no primary
            if primary_controller_id == -1:
                primary_controller_id = device_id

    else:
        if device_id in connected_controllers:
            connected_controllers.erase(device_id)
            emit_signal("controller_disconnected", device_id)

            # If primary disconnected, assign new primary
            if device_id == primary_controller_id:
                if connected_controllers.size() > 0:
                    primary_controller_id = connected_controllers[0]
                else:
                    primary_controller_id = -1

func get_primary_controller() -> int:
    return primary_controller_id

func get_controller_name(joy_id: int) -> String:
    return Input.get_joy_name(joy_id)

func get_controller_type(joy_id: int) -> ControllerType:
    var name = Input.get_joy_name(joy_id).to_lower()

    if "xbox" in name or "xinput" in name:
        return ControllerType.XBOX
    elif "playstation" in name or "dualshock" in name or "dualsense" in name:
        return ControllerType.PLAYSTATION
    elif "nintendo" in name or "switch" in name:
        return ControllerType.NINTENDO
    elif "steam" in name:
        return ControllerType.STEAM_DECK
    else:
        return ControllerType.GENERIC
```

---

## Implementation Strategy

### Phase 1: Core Controller Input (Week 18 Day 1-2) - 2 days

**Goal**: Basic controller input working.

**Tasks**:
1. Configure InputMap with controller bindings
2. Implement InputModeService (auto-detection)
3. Build ControllerService (connection/disconnection)
4. Create Modern control scheme
5. Test movement and basic actions with controller

**Deliverables**:
- InputMap configuration
- InputModeService (150 lines)
- ControllerService (200 lines)
- Basic gameplay works with controller

**Testing**:
- Plug in controller, verify auto-detection
- Test movement, aiming, firing with controller
- Verify seamless keyboard ↔ controller switching

---

### Phase 2: UI Adaptation (Week 18 Day 3-4) - 2 days

**Goal**: All UI navigable with controller.

**Tasks**:
1. Adapt shop UI for controller navigation
2. Adapt inventory UI for controller
3. Implement pause menu controller navigation
4. Add button prompts to all UI screens
5. Create UIPromptService for dynamic button icons

**Deliverables**:
- Controller-optimized shop (200 lines)
- Controller-optimized inventory (200 lines)
- UIPromptService (150 lines)
- All menus navigable with controller

**Testing**:
- Navigate all menus using only controller
- Verify button prompts show correct icons
- Test with Xbox, PlayStation, generic controllers

---

### Phase 3: Schemes & Remapping (Week 18 Day 5) - 1 day

**Goal**: Multiple control schemes and full remapping.

**Tasks**:
1. Implement Classic control scheme (d-pad movement)
2. Build remapping UI
3. Implement InputRemappingService
4. Add deadzone and sensitivity settings
5. Profile save/load system

**Deliverables**:
- Classic control scheme
- Remapping UI (250 lines)
- InputRemappingService (200 lines)
- Settings persistence

**Testing**:
- Remap controls, verify bindings save
- Test deadzone compensation
- Test sensitivity curves

---

### Phase 4: Haptics & Polish (Week 19 Day 1) - 1 day

**Goal**: Rumble support and UX polish.

**Tasks**:
1. Implement HapticService
2. Add rumble events (damage, death, boss, etc.)
3. Build rumble settings UI
4. Polish button prompts (context-sensitive)
5. Add controller connection notifications

**Deliverables**:
- HapticService (150 lines)
- Rumble settings
- Polished button prompts
- Connection notifications

**Testing**:
- Verify rumble works on supported controllers
- Test rumble intensity scaling
- Confirm rumble can be disabled

---

### Phase 5: Accessibility (Week 19 Day 2) - 1 day

**Goal**: Accessibility features for all players.

**Tasks**:
1. Implement one-handed mode (left & right variants)
2. Add auto-aim option
3. Build button hold duration settings
4. Add large text mode
5. Integrate with colorblind mode

**Deliverables**:
- One-handed mode (100 lines)
- Auto-aim system (150 lines)
- Hold duration settings
- Accessibility options menu

**Testing**:
- Test one-handed mode (can play with single hand?)
- Verify auto-aim works reliably
- Test hold duration prevents accidental inputs

---

### Phase 6: Testing & Refinement (Week 19 Day 3) - 1 day

**Goal**: Polish and test across devices.

**Tasks**:
1. Test on Steam Deck
2. Test with Xbox, PlayStation, Nintendo controllers
3. Test with generic controllers
4. Optimize performance (input latency)
5. Final UX polish

**Deliverables**:
- Steam Deck compatibility confirmed
- Multi-controller support verified
- Performance optimizations
- Polish pass

**Testing**:
- Full playthrough on Steam Deck
- Test all control schemes
- Verify no input lag
- User testing for comfort/clarity

---

### Timeline Summary

| Phase | Duration | Effort | Dependencies |
|-------|----------|--------|--------------|
| 1. Core Controller Input | 2 days | 12 hours | Godot InputMap |
| 2. UI Adaptation | 2 days | 12 hours | All UI screens |
| 3. Schemes & Remapping | 1 day | 6 hours | Phase 1 |
| 4. Haptics & Polish | 1 day | 6 hours | Phase 1 |
| 5. Accessibility | 1 day | 6 hours | Phase 1-2 |
| 6. Testing & Refinement | 1 day | 6 hours | All previous |
| **Total** | **8 days** | **~48 hours** | - |

---

## Balancing Considerations

### Aim Assist Strength

**Problem**: Controllers are less precise than mouse for aiming.

**Solution**: Optional aim assist (disabled by default for competitive integrity).

**Aim Assist Levels**:
- **None** (default): No assistance, full player control
- **Light**: Slight magnetism toward enemies when aiming near them (5° cone)
- **Medium**: Moderate magnetism + slight slowdown when cursor over enemy
- **Heavy**: Strong magnetism + significant slowdown (essentially auto-aim)

**Implementation**:
```gdscript
var aim_assist_level: AimAssistLevel = AimAssistLevel.NONE

func get_aim_direction(stick_input: Vector2) -> Vector2:
    if aim_assist_level == AimAssistLevel.NONE:
        return stick_input.normalized()

    # Find nearest enemy
    var nearest_enemy = find_nearest_enemy_in_cone(stick_input, assist_cone_degrees[aim_assist_level])

    if nearest_enemy:
        # Blend between stick input and enemy direction
        var enemy_direction = (nearest_enemy.position - player.position).normalized()
        var blend_factor = assist_strength[aim_assist_level]
        return stick_input.normalized().lerp(enemy_direction, blend_factor)
    else:
        return stick_input.normalized()
```

**Balance**: Aim assist available to all (FREE), but disabled by default to preserve skill ceiling.

---

### Input Latency

**Problem**: Controller input lag feels terrible.

**Solution**:
- **Polling rate**: Poll controller at 120 Hz (not 60 Hz)
- **Input buffering**: Buffer inputs to avoid dropped commands
- **Prediction**: Predict movement to reduce perceived latency

**Target**: <50ms input latency (from button press to on-screen action).

**Measurement**:
```gdscript
# Debug tool: measure input latency
func measure_input_latency():
    var start_time = Time.get_ticks_usec()

    # Wait for button press
    await wait_for_button_press()

    var button_press_time = Time.get_ticks_usec()

    # Wait for action to complete (e.g., weapon fire)
    await action_completed

    var action_complete_time = Time.get_ticks_usec()

    var latency_ms = (action_complete_time - button_press_time) / 1000.0

    print("Input latency: %.1f ms" % latency_ms)
```

---

### Stick Drift Mitigation

**Problem**: Controllers develop stick drift, causing unintended movement.

**Solution**:
- Default deadzone: 20% (ignores small stick movements)
- User-adjustable deadzone (10%-40%)
- Deadzone test UI (visualize stick position)

**Automatic Calibration** (future):
- Measure stick center position when idle
- Adjust deadzone dynamically to compensate

---

## Open Questions & Future Enhancements

### Open Questions

1. **Should we support simultaneous keyboard + controller?**
   - Example: Controller movement + mouse aim
   - Pro: Best of both worlds for some players
   - Con: Complexity, balance concerns

2. **Should we have Steam Input integration?**
   - Steam Input allows community controller configs
   - Pro: Players can share configs
   - Con: Bypasses our in-game remapping

3. **How to handle multiple controllers (local co-op)?**
   - Current design: Single player only
   - Future: Local co-op would need multi-controller support
   - Player 1 = controller 0, Player 2 = controller 1, etc.

4. **Should mobile (touch) use controller UI or separate UI?**
   - Mobile will have virtual joystick
   - Question: Use controller-style UI on mobile, or separate mobile-optimized UI?

---

### Future Enhancements

#### 1. Gyro Aiming (Steam Deck / Switch Pro)

**Concept**: Use controller gyroscope for precise aiming.

**Implementation**:
- Right stick: Coarse aiming
- Gyro: Fine adjustments (activated when aiming)
- Sensitivity settings (low = subtle, high = aggressive)

**Platforms**: Steam Deck, Switch Pro Controller, DualSense

---

#### 2. Adaptive Triggers (DualSense)

**Concept**: Use DualSense adaptive triggers for immersive feedback.

**Examples**:
- Bow weapon: Trigger resistance increases as you "draw" the bow
- Reload: Trigger locks briefly during reload
- Low ammo: Trigger vibrates

**Platform**: DualSense only

---

#### 3. Touchpad Support (DualSense / Steam Deck)

**Concept**: Use touchpad for quick menu access or precision cursor.

**Examples**:
- Swipe touchpad: Quick inventory access
- Tap touchpad: Ping system (mark location)
- Cursor mode: Touchpad controls cursor for UI

**Platforms**: DualSense, Steam Deck

---

#### 4. Voice Commands (Future)

**Concept**: Voice commands for common actions.

**Examples**:
- "Shop" → Opens shop
- "Heal" → Uses health item
- "Switch weapon" → Cycles weapons

**Accessibility**: Helps players with limited mobility.

---

#### 5. Community Controller Configs

**Concept**: Share controller configurations like trading cards.

**Implementation**:
- Export config to shareable code
- Browse top community configs
- Import configs with one click

**Example**:
```
"SpeedRunner Pro Config"
Optimized for fast weapon swapping and dodge rolling
Created by: ProPlayer #1234
Downloads: 1,245

[Import Config]
```

---

#### 6. Controller LED Support

**Concept**: Use controller LEDs for status feedback.

**Examples**:
- HP Low: Red LED
- Boss Spawn: Pulsing LED
- Level Up: Green LED flash

**Platforms**: DualShock 4, DualSense, some Xbox controllers

---

## Summary

**Controller Support** provides full gamepad compatibility as a **FREE feature available to all players**. Based on market research showing Brotato and similar games offer controller support as a baseline feature, we provide complete feature parity between keyboard/mouse and controller with no tier restrictions.

### Key Features

1. **FREE Access**: All controller features available to Free, Premium, and Subscription tiers equally
2. **SDL3 Backend**: Godot 4.5.1's SDL3 integration supports 600+ controllers with hot-plugging
3. **Multiple Control Schemes**: Modern (dual-stick), Classic (d-pad), Custom (full remapping)
4. **Auto-Detection**: Seamless switching between keyboard/mouse and controller (no manual toggle)
5. **Adaptive Prompts**: Dynamic button icons based on detected controller (Xbox A, PlayStation ✕, Nintendo B)
6. **Full UI Compatibility**: All menus, shop, inventory navigable with controller
7. **Haptic Feedback**: Rumble for damage, death, boss spawns, item pickups, weapon fire, level-ups
8. **Accessibility**: One-handed mode, auto-aim option, hold duration settings
9. **Full Remapping**: Every button remappable, deadzone adjustment, sensitivity curves
10. **Steam Deck Ready**: Optimized for Steam Deck with gyro support (future)

### Technical Architecture

- **InputModeService**: Auto-detects input device, switches UI prompts (150 lines)
- **ControllerService**: Manages connection/disconnection, device detection (200 lines)
- **HapticService**: Rumble events with intensity scaling and user settings (150 lines)
- **InputRemappingService**: Full button remapping with profile save/load (200 lines)
- **UIPromptService**: Dynamic button prompt icons based on controller type (150 lines)
- **Godot InputMap**: Maps keyboard/mouse/controller to unified actions

### Implementation Timeline

- **Phase 1-2** (4 days): Core controller input + UI adaptation
- **Phase 3-4** (2 days): Schemes/remapping + haptics/polish
- **Phase 5-6** (2 days): Accessibility + testing/refinement
- **Total**: ~8 days / ~48 hours

### Success Metrics

- **Adoption**: 30%+ of players use controller at least once per month
- **Steam Deck**: 80%+ of Steam Deck players use controller (not keyboard/mouse)
- **Accessibility**: 5%+ of players use one-handed mode or auto-aim (accessibility features utilized)
- **Satisfaction**: 85%+ of controller users rate experience as "good" or "excellent" (survey)
- **Review Sentiment**: No negative reviews mentioning "poor controller support" or "no gamepad"
- **Platform Expansion**: Controller support enables future console ports (Switch, Xbox, PlayStation)

### Business Value

Controller Support increases addressable market, player satisfaction, and platform flexibility by:
- **Steam Deck Market**: Full compatibility with fastest-growing PC gaming platform
- **Accessibility**: Enables players with mobility limitations or ergonomic preferences
- **Console Port Ready**: Foundation for future Switch/Xbox/PlayStation releases (additional revenue streams)
- **Competitive Parity**: Matches or exceeds controller support in similar games (Brotato, Vampire Survivors)
- **Positive Reviews**: Prevents negative reviews, positions game as polished and accessible
- **Couch Gaming**: Enables comfortable play from couch/bed (expands when/where players engage)

By providing controller support as a FREE baseline feature with full feature parity, comprehensive customization, and strong accessibility options, we meet market expectations while creating a foundation for future platform expansion and ensuring all players can enjoy the game comfortably.
