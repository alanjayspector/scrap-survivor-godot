# Scrap Survivor: Mobile Controller Support Implementation Guide
## Godot 4.5.1 | Twin-Stick Roguelite | iOS/Android

---

## Executive Summary

This guide provides a comprehensive implementation strategy for controller support in **Scrap Survivor**, a twin-stick shooter roguelite for iOS and Android built in Godot 4.5.1. Key findings:

- **Godot 4.5.1** uses SDL3 as the primary gamepad driver for improved cross-platform support
- **Brotato** (reference title) offers full controller support in both free and premium versions
- **Backbone One** is the primary hardware target with MFi (iOS) and Bluetooth (Android) support
- **Recommendation**: Implement controller support as a **free feature** for all users (proven user expectation)

---

## Table of Contents

1. [Godot 4.5.1 Controller Architecture](#godot-451-controller-architecture)
2. [Brotato Controller Implementation Reference](#brotato-controller-implementation-reference)
3. [Backbone One Hardware Integration](#backbone-one-hardware-integration)
4. [Technical Implementation Guidance](#technical-implementation-guidance)
5. [Control Schemes & UX Patterns](#control-schemes--ux-patterns)
6. [Monetization Strategy](#monetization-strategy)

---

## Godot 4.5.1 Controller Architecture

### Overview of Changes

**Godot 4.5.1** represents a major shift in controller handling:

- **Migration to SDL3**: Godot 4.5 transitioned from its custom joypad driver to SDL3 (Simple DirectMedia Layer 3) as the primary gamepad input driver for all desktop and mobile platforms
- **Maintained Custom Drivers**: For platforms without SDL3 support, Godot 4.5.1 retains custom input drivers
- **Benefits**: SDL3 handles edge cases, unknown controller variants, and platform quirks that accumulated in Godot's custom implementation
- **Maintenance Release**: Godot 4.5.1 (released October 2025) contains ~92 bug fixes including input system stability improvements

### Input.get_connected_joypads() API

The foundation of controller detection in Godot 4.5.1:

```gdscript
# Get list of connected controller device IDs
var connected_controllers = Input.get_connected_joypads()

# Returns: Array[int] containing device indices (0, 1, 2, etc.)
# Empty array means no controllers connected
```

### Platform-Specific Controller Detection

#### iOS (MFi Controllers)

```gdscript
func detect_ios_mfi_controller():
    var joypads = Input.get_connected_joypads()
    if joypads.is_empty():
        print("No MFi controller detected")
        return false
    
    # MFi controllers automatically detected by iOS
    # Device ID 0 is typically the first connected controller
    var device_id = joypads[0]
    var controller_name = Input.get_joy_name(device_id)
    print("Connected controller: ", controller_name)
    
    # Get joy info for additional details (limited on iOS)
    var joy_info = Input.get_joy_info(device_id)
    # Note: Returns empty dict on iOS - no vendor/product IDs available
    
    return true
```

**Note**: Godot's `get_joy_info()` returns an empty dictionary on iOS due to platform restrictions. The OS automatically handles MFi detection; developers only need to poll `get_connected_joypads()`.

#### Android (Bluetooth Controllers)

```gdscript
func detect_android_bluetooth_controller():
    var joypads = Input.get_connected_joypads()
    
    for device_id in joypads:
        var controller_name = Input.get_joy_name(device_id)
        var joy_info = Input.get_joy_info(device_id)
        
        # Android provides more detailed info
        if joy_info:
            print("Controller: ", controller_name)
            print("Vendor ID: ", joy_info.get("vendor_id"))
            print("Product ID: ", joy_info.get("product_id"))
            
            # Use this to identify Backbone One specifically
            if is_backbone_controller(joy_info):
                print("Backbone One detected!")
    
    return not joypads.is_empty()
```

### Input Mapping System

Godot 4.5.1 uses the **InputMap** system to abstract controller inputs:

```gdscript
# Project Settings -> InputMap defines these actions
# Instead of hardcoding button numbers, use actions

# In your _ready() or _input() callback:
if Input.is_action_pressed("ui_accept"):  # Can be A button, space, or Enter
    pass

if Input.is_action_pressed("move_left"):  # Can be D-Pad Left, Left Stick Left, or A key
    pass

# For analog sticks (twin-stick shooter):
var move_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
var aim_vector = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
```

### Joy Axis Mapping

For raw axis access (not recommended, but useful for debugging):

```gdscript
# JOY_AXIS_LEFT_X = 0
# JOY_AXIS_LEFT_Y = 1
# JOY_AXIS_RIGHT_X = 2
# JOY_AXIS_RIGHT_Y = 3
# JOY_AXIS_TRIGGER_LEFT = 4 (LT/L2)
# JOY_AXIS_TRIGGER_RIGHT = 5 (RT/R2)

func get_twin_stick_input():
    var device_id = Input.get_connected_joypads()[0] if not Input.get_connected_joypads().is_empty() else -1
    
    if device_id == -1:
        return {"move": Vector2.ZERO, "aim": Vector2.ZERO}
    
    # Left stick (movement)
    var left_x = Input.get_joy_axis(device_id, JOY_AXIS_LEFT_X)
    var left_y = Input.get_joy_axis(device_id, JOY_AXIS_LEFT_Y)
    
    # Right stick (aiming)
    var right_x = Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_X)
    var right_y = Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_Y)
    
    # Apply deadzone (Godot handles this in InputMap, but raw axis needs manual handling)
    var move = Vector2(left_x, left_y).normalized() if Vector2(left_x, left_y).length() > 0.2 else Vector2.ZERO
    var aim = Vector2(right_x, right_y).normalized() if Vector2(right_x, right_y).length() > 0.2 else Vector2.ZERO
    
    return {"move": move, "aim": aim}
```

### Controller Connection/Disconnection Signals

```gdscript
# Godot automatically emits this signal
func _ready():
    Input.joy_connection_changed.connect(_on_joy_connection_changed)

func _on_joy_connection_changed(device_id: int, connected: bool):
    if connected:
        print("Controller connected: Device %d (%s)" % [device_id, Input.get_joy_name(device_id)])
        controller_connected_ui.show()
    else:
        print("Controller disconnected: Device %d" % device_id)
        controller_connected_ui.hide()
        # Optionally: show on-screen touch controls fallback
```

---

## Brotato Controller Implementation Reference

### Control Scheme Analysis

**Brotato** (twin-stick shooter similar to Scrap Survivor) implements the following scheme:

#### Movement & Aiming

| Input | Brotato Implementation | Notes |
|-------|----------------------|-------|
| **Left Stick** | Player movement (4-directional or analog) | Continuous input, supports 8-directional movement |
| **Right Stick** | Aim direction / weapon aiming | Game features auto-firing by default, right stick aims manual fire |
| **D-Pad** | Alternative movement (toggle-able) | Many players prefer D-Pad for responsive movement in twin-stick |
| **Triggers (LT/RT)** | Weapon fire / ability activation | Optional in Brotato; game auto-fires by default |

#### Button Mapping (Xbox Layout)

| Button | Brotato Function |
|--------|-----------------|
| **A (Green)** | Confirm / Select / Ability |
| **B (Red)** | Cancel / Back |
| **X (Blue)** | Item cycling / Menu scroll |
| **Y (Yellow)** | Pause / Menu toggle |
| **LB / RB** | Weapon swap / Cycle weapons |
| **Start** | Pause menu |
| **Back/Select** | Stats / Info panel |

### Menu Navigation Pattern

Brotato's menu navigation uses **D-Pad Primary** approach:

```gdscript
# Recommended for mobile roguelites
# D-Pad OR Left Stick handles vertical/horizontal navigation

func handle_menu_input():
    # Primary: Use D-Pad for menus
    var menu_vertical = Input.get_axis("ui_down", "ui_up")  # D-Pad
    var menu_horizontal = Input.get_axis("ui_left", "ui_right")  # D-Pad
    
    # Secondary: Allow Left Stick as fallback
    if menu_vertical == 0:
        menu_vertical = Input.get_axis("move_down", "move_up")  # Left Stick
    if menu_horizontal == 0:
        menu_horizontal = Input.get_axis("move_left", "move_right")  # Left Stick
    
    # Apply navigation
    if menu_vertical != 0:
        current_menu_index += int(menu_vertical)
```

### Accessibility Features in Brotato

- **Difficulty adjusters**: Enemy health, damage, speed customizable
- **Auto-aim toggle**: Manual vs. automatic aiming modes
- **Button remapping**: In-game button customization (important for controller players)
- **Colorblind mode**: UI adjustments
- **Controller vibration**: Haptic feedback on weapon fire

### Brotato Monetization Model

**Critical Finding**: Brotato offers **full controller support in BOTH free and premium versions**

- Free version (Brotato VIP): Full controller support, monetized via ads and cosmetics
- Premium version (Brotato: Premium): Full controller support, purchased one-time or subscription
- Controller support is **NOT gated behind premium**

---

## Backbone One Hardware Integration

### Hardware Specifications

#### Button Layout (Nintendo-Style Mapping)

```
        Y
    X       A
        B
    
LB          RB
L3          R3  (Stick clicks)

       Menu/Start
```

#### Feature Set

| Feature | Availability | Notes |
|---------|--------------|-------|
| **D-Pad** | Yes | 4-directional input |
| **Analog Sticks** | Yes (x2) | Full-range analog, clickable (L3/R3) |
| **Buttons** | Yes (A/B/X/Y) | Standard layout |
| **Shoulder Buttons** | Yes (LB/RB) | Digital buttons |
| **Triggers** | No analog range | Some variants have digital L2/R2 equivalents |
| **Vibration/Haptics** | Yes | Force feedback supported on iOS 14+/Android |
| **Pass-through Audio** | Yes | Headphone jack or USB-C audio |
| **MFi Certification** | iOS | Apple Game Controller framework compatible |

### Platform-Specific Integration

#### iOS (Backbone One for iPhone)

```gdscript
func initialize_ios_backbone():
    # MFi controllers are automatically detected via Input.get_connected_joypads()
    # No special API calls required
    
    # Backbone One appears as standard MFi controller in Godot
    var controller_name = Input.get_joy_name(0)  # "Backbone One" or similar
    
    # Enable haptics (iOS 14+)
    if OS.get_name() == "iOS":
        setup_haptic_feedback(0)
```

#### Android (Backbone One for Android)

```gdscript
func initialize_android_backbone():
    # Backbone One for Android connects via Bluetooth or USB-C
    var joypads = Input.get_connected_joypads()
    
    for device_id in joypads:
        var joy_info = Input.get_joy_info(device_id)
        var name = Input.get_joy_name(device_id)
        
        # Identify Backbone One by name or vendor ID
        if "Backbone" in name or joy_info.get("product_id") == BACKBONE_PRODUCT_ID:
            print("Backbone One detected on Android")
            setup_haptic_feedback(device_id)
```

### Backbone API Considerations

Backbone does NOT provide special APIs for Godot games; it behaves as a standard Bluetooth/MFi gamepad:

- No special SDK integration needed
- Uses standard Android KeyEvent / iOS Game Controller framework
- Godot's Input system handles everything automatically
- **Haptic feedback**: Use `Input.start_joy_vibration()` for rumble effects

### Known Compatibility

- âœ… Backbone One works with SDL3 driver (Godot 4.5.1+)
- âœ… Full button support on both iOS and Android
- âœ… Analog stick support (movement and aiming)
- âš ï¸ Haptic feedback requires platform-specific implementation
- âœ… No known issues with Godot games (widely used in indie mobile games)

---

## Technical Implementation Guidance

### Project Setup (Godot 4.5.1)

#### Step 1: Create Input Actions

In **Project Settings â†’ Input Map**, define these actions:

```
[Movement]
- ui_up â†’ D-Pad Up, W key, Left Stick Up
- ui_down â†’ D-Pad Down, S key, Left Stick Down
- ui_left â†’ D-Pad Left, A key, Left Stick Left
- ui_right â†’ D-Pad Right, D key, Left Stick Right

[Aiming - Twin-Stick Specific]
- aim_up â†’ Right Stick Up
- aim_down â†’ Right Stick Down
- aim_left â†’ Right Stick Left
- aim_right â†’ Right Stick Right

[Actions]
- ui_accept â†’ A button, Space, Return
- ui_cancel â†’ B button, Escape
- ui_focus_next â†’ Right Shoulder (RB), Tab
- ui_focus_prev â†’ Left Shoulder (LB), Shift+Tab

[Weapons]
- fire_primary â†’ RT trigger, Left Mouse, hold
- ability_one â†’ X button
- ability_two â†’ Y button
- weapon_swap_prev â†’ LB button
- weapon_swap_next â†’ RB button

[Menu]
- ui_menu_pause â†’ Start button, P key
```

#### Step 2: Controller Detection Script

```gdscript
# controller_manager.gd
extends Node

var controller_connected: bool = false
var active_device_id: int = -1

signal controller_connected_signal
signal controller_disconnected_signal

func _ready():
    Input.joy_connection_changed.connect(_on_joy_connection_changed)
    
    # Check for already-connected controllers
    var joypads = Input.get_connected_joypads()
    if not joypads.is_empty():
        active_device_id = joypads[0]
        controller_connected = true
        controller_connected_signal.emit()

func _on_joy_connection_changed(device_id: int, connected: bool):
    if connected:
        print("Controller connected: ", Input.get_joy_name(device_id))
        active_device_id = device_id
        controller_connected = true
        controller_connected_signal.emit()
    else:
        print("Controller disconnected: ", Input.get_joy_name(device_id))
        if active_device_id == device_id:
            active_device_id = -1
            controller_connected = false
            controller_disconnected_signal.emit()
        
        # Fallback: Check if other controllers still connected
        var joypads = Input.get_connected_joypads()
        if not joypads.is_empty():
            active_device_id = joypads[0]
            controller_connected = true

func get_controller_name() -> String:
    if not controller_connected:
        return "Keyboard/Touch"
    return Input.get_joy_name(active_device_id)

func is_controller_connected() -> bool:
    return controller_connected
```

#### Step 3: Twin-Stick Input Handler

```gdscript
# player_input.gd
extends Node

@onready var controller_manager = get_tree().root.get_child(0).get_node("ControllerManager")

var move_vector: Vector2 = Vector2.ZERO
var aim_vector: Vector2 = Vector2.ZERO
var using_controller: bool = false

func _process(_delta):
    update_input()

func update_input():
    # Movement - Primary input (stick), fallback to D-Pad
    move_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    
    # Aiming - Twin-stick specific
    aim_vector = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
    
    # Apply deadzone to analog sticks (if using raw axis, apply 0.2 threshold)
    if move_vector.length() < 0.2:
        move_vector = Vector2.ZERO
    else:
        move_vector = move_vector.normalized()
    
    if aim_vector.length() < 0.2:
        aim_vector = Vector2.ZERO
    else:
        aim_vector = aim_vector.normalized()
    
    using_controller = controller_manager.is_controller_connected()

func get_move_vector() -> Vector2:
    return move_vector

func get_aim_vector() -> Vector2:
    return aim_vector

func is_using_controller() -> bool:
    return using_controller
```

#### Step 4: UI Prompt System

```gdscript
# input_prompt.gd
extends Control

@onready var prompt_label = $Label
@onready var controller_manager = get_tree().root.get_child(0).get_node("ControllerManager")

var action_name: String = "ui_accept"
var prompt_map = {
    "ui_accept": {"keyboard": "[SPACE]", "controller": "[A]"},
    "ui_cancel": {"keyboard": "[ESC]", "controller": "[B]"},
    "fire_primary": {"keyboard": "[CLICK]", "controller": "[RT]"},
    "weapon_swap_next": {"keyboard": "[E]", "controller": "[RB]"},
}

func _ready():
    controller_manager.controller_connected_signal.connect(_on_controller_changed)
    controller_manager.controller_disconnected_signal.connect(_on_controller_changed)
    update_prompt()

func set_action(action: String):
    action_name = action
    update_prompt()

func update_prompt():
    var is_controller = controller_manager.is_controller_connected()
    var input_type = "controller" if is_controller else "keyboard"
    
    if prompt_map.has(action_name):
        var prompt_text = prompt_map[action_name].get(input_type, "")
        prompt_label.text = prompt_text

func _on_controller_changed():
    update_prompt()
```

#### Step 5: Haptic Feedback

```gdscript
# haptic_manager.gd
extends Node

var haptics_enabled: bool = true
var controller_id: int = -1

@onready var controller_manager = get_tree().root.get_child(0).get_node("ControllerManager")

func _ready():
    controller_manager.controller_connected_signal.connect(_on_controller_connected)

func _on_controller_connected():
    controller_id = controller_manager.active_device_id
    print("Haptics ready for device: ", controller_id)

func vibrate_weak(duration: float = 0.2):
    if not haptics_enabled or controller_id == -1:
        return
    # Weak motor only
    Input.start_joy_vibration(controller_id, 0.5, 0.0, duration)

func vibrate_strong(duration: float = 0.3):
    if not haptics_enabled or controller_id == -1:
        return
    # Strong motor only
    Input.start_joy_vibration(controller_id, 0.0, 0.8, duration)

func vibrate_impact(duration: float = 0.15):
    if not haptics_enabled or controller_id == -1:
        return
    # Both motors for punchy feedback
    Input.start_joy_vibration(controller_id, 0.7, 0.7, duration)

func vibrate_explosion(duration: float = 0.5):
    if not haptics_enabled or controller_id == -1:
        return
    # Strong then fade
    Input.start_joy_vibration(controller_id, 0.0, 1.0, duration)

func stop_vibration():
    if controller_id != -1:
        Input.stop_joy_vibration(controller_id)
```

### Mobile-Specific Considerations

#### Mixed Input (Touch + Controller)

```gdscript
# input_mode_manager.gd
extends Node

var touch_input_detected: bool = false
var controller_input_detected: bool = false
var last_input_method: String = "touch"  # or "controller"

@onready var controller_manager = get_tree().root.get_child(0).get_node("ControllerManager")

func _input(event: InputEvent):
    if event is InputEventScreenTouch or event is InputEventScreenDrag:
        touch_input_detected = true
        last_input_method = "touch"
    
    if event is InputEventJoypadButton or event is InputEventJoypadMotion:
        controller_input_detected = true
        last_input_method = "controller"

func should_show_touch_controls() -> bool:
    # Show touch controls if:
    # 1. No controller connected, OR
    # 2. Controller connected but last input was touch
    return not controller_manager.is_controller_connected() or last_input_method == "touch"

func should_show_controller_hints() -> bool:
    return controller_manager.is_controller_connected() and last_input_method == "controller"
```

#### Handling Controller Disconnect Mid-Game

```gdscript
# game_state.gd
extends Node

var game_paused_by_disconnect: bool = false

@onready var controller_manager = get_tree().root.get_child(0).get_node("ControllerManager")

func _ready():
    controller_manager.controller_disconnected_signal.connect(_on_controller_disconnected)

func _on_controller_disconnected():
    if not game_paused_by_disconnect:
        show_reconnect_dialog()
        get_tree().paused = true
        game_paused_by_disconnect = true

func show_reconnect_dialog():
    var dialog = AlertDialog.new()
    dialog.title = "Controller Disconnected"
    dialog.text = "Reconnect your controller to continue playing.\n\nYou can also use touch controls."
    dialog.add_button("Continue with Touch")
    dialog.add_button("Wait for Controller")
    
    await dialog.custom_action.emit as String
    
    if game_paused_by_disconnect:
        get_tree().paused = false
        game_paused_by_disconnect = false
```

---

## Control Schemes & UX Patterns

### Recommended Twin-Stick Shooter Layout (Scrap Survivor)

| Function | Control | Rationale |
|----------|---------|-----------|
| **Move** | Left Stick / D-Pad | Standard twin-stick convention |
| **Aim** | Right Stick | Dual-analog aiming |
| **Fire** | Right Trigger (RT) or Hold Right Stick | Auto-fire or hold-to-aim |
| **Ability 1** | X button | Left hand access |
| **Ability 2** | Y button | Left hand access |
| **Weapon Swap** | RB/LB | Shoulder buttons for quick access |
| **Menu/Pause** | Start button | Standard pause location |
| **Back/Cancel** | B button | Standard back action |

### Menu Navigation Best Practices

**Recommendation: Hybrid Approach**

```gdscript
# Ideal for mobile roguelites
# Use D-Pad as PRIMARY, Left Stick as SECONDARY (both work)

func navigate_menu(event: InputEvent):
    if event is InputEventJoypadButton:
        match event.button_index:
            JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_DOWN, JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_RIGHT:
                # D-Pad is primary
                handle_d_pad_navigation(event)
    
    elif event is InputEventJoypadMotion:
        if event.axis in [JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y]:
            # Left Stick secondary (with deadzone)
            if abs(event.axis_value) > 0.5:  # Only register significant stick movement
                handle_stick_navigation(event)
```

**Why this approach?**
- D-Pad: Precise, digital, no drift, preferred by many gamers
- Left Stick: Natural fallback for those preferring analog, reduces accidental input
- Prevents rapid focus cycling from analog stick noise

### Input Prompt System (Critical UX Feature)

**Shows "Press A" instead of "Tap to continue"**

```gdscript
# hud_prompt_manager.gd
extends CanvasLayer

var prompts: Dictionary = {}

@onready var controller_manager = get_tree().root.get_child(0).get_node("ControllerManager")

const BUTTON_TEXTURES = {
    JOY_BUTTON_A: "res://assets/ui/button_a.png",
    JOY_BUTTON_B: "res://assets/ui/button_b.png",
    JOY_BUTTON_X: "res://assets/ui/button_x.png",
    JOY_BUTTON_Y: "res://assets/ui/button_y.png",
}

const KEYBOARD_ICONS = {
    "ui_accept": "SPACE",
    "ui_cancel": "ESC",
    "fire_primary": "CLICK",
}

func add_prompt(id: String, action: String, position: Vector2, label: String):
    var prompt_ui = Control.new()
    
    if controller_manager.is_controller_connected():
        # Show controller button icon
        var icon = TextureRect.new()
        icon.texture = load(BUTTON_TEXTURES.get(action, "res://assets/ui/button_default.png"))
        prompt_ui.add_child(icon)
    else:
        # Show keyboard key
        var label_node = Label.new()
        label_node.text = KEYBOARD_ICONS.get(action, "?")
        prompt_ui.add_child(label_node)
    
    prompt_ui.global_position = position
    add_child(prompt_ui)
    prompts[id] = prompt_ui
```

---

## Monetization Strategy

### Market Research: Controller Support Expectations

**Key Finding**: Users expect controller support to be **FREE** in mobile games, not premium.

#### Evidence from Successful Games

| Game | Controller Support | Monetization Model | User Reception |
|------|-------------------|-------------------|-----------------|
| **Brotato** (Free) | âœ… Full support | Free with ads | âœ… Highly positive |
| **Brotato: Premium** | âœ… Full support | One-time/Subscription | âœ… Purchased for offline play, not controller access |
| **Dead Cells** | âœ… Full support | Premium (~$25) | âœ… Controller expected at this price point |
| **Hades** | âœ… Full support | Premium (~$20) | âœ… Standard feature |
| **Brawlhalla** | âœ… Full support | Free-to-play | âœ… Competitive game requires controller support |

### Monetization Recommendations

#### âŒ DO NOT Gate Controller Support Behind Premium

**Reasons**:

1. **Market Expectation**: Controller support is considered a baseline feature in 2024-2025 for games with complex controls
2. **Platform Standards**: Apple and Google treat controller support as expected, not a premium feature
3. **Player Frustration**: Gatekeeping input methods creates negative reviews (Reddit: "Why Hate Controller Support On Mobile Games!")
4. **Competitive Disadvantage**: Free competitors offering full controller support will dominate

#### âœ… RECOMMENDED: Free Controller Support + Premium Features

**Better monetization approaches**:

1. **Cosmetics Gating** (Most Effective)
   - Controller skins / button customization themes
   - Premium controller-exclusive emote animations
   - Charge $0.99-$2.99 per cosmetic set

2. **Content Gating** (Alternative)
   - Premium cosmetic characters with special abilities
   - Controller-themed battle pass skins
   - Exclusive controller vibration patterns (low-value, high-perception)

3. **Gameplay Features** (Not Tied to Input)
   - Difficulty modifiers
   - Character unlocks
   - Item packs
   - Cosmetics

**Monetization Model Example (Brotato Strategy)**:

```
FREE VERSION:
- Full controller support
- All gameplay features
- Monetized via: Ad watches for rewards, cosmetics

PREMIUM VERSION:
- Same full controller support
- Offline play (no ads)
- Cloud save (important for roguelites)
- Cosmetics exclusive to premium tier
- Monetized via: One-time purchase or subscription
```

### Pricing Strategy (If Premium Version Exists)

- **One-time purchase**: $2.99-$4.99 (lower barrier for mobile)
- **Subscription**: $0.99/month or $4.99/year
- **Never**: "Premium Controller Support" (breaks user trust)

---

## Implementation Timeline

### Phase 1: MVP (Week 1-2)
- âœ… Input action setup in ProjectSettings/InputMap
- âœ… Controller detection script
- âœ… Twin-stick input handler (movement + aiming)
- âœ… Basic button mapping

**Test on**: Backbone One iOS simulator, Android emulator with gamepad

### Phase 2: UX Polish (Week 3-4)
- âœ… Input prompt system (controller-aware UI)
- âœ… Menu navigation (D-Pad + Stick hybrid)
- âœ… Controller disconnect handling
- âœ… Mixed input (touch + controller switching)

**Test on**: Actual iOS device with Backbone, Actual Android device

### Phase 3: Feedback & Accessibility (Week 5-6)
- âœ… Haptic feedback implementation
- âœ… Button remapping system
- âœ… Accessibility options (sensitivity, aim assist)
- âœ… Controller profile presets (Backbone optimized)

**Test on**: Multiple controller types, various hand sizes

### Phase 4: QA & Polish (Week 7-8)
- âœ… Platform-specific testing (MFi vs Bluetooth quirks)
- âœ… Edge cases (controller disconnect/reconnect mid-gameplay)
- âœ… Performance optimization (input processing overhead)
- âœ… Documentation for support team

---

## Appendix: Code Templates

### Complete Minimal Example

```gdscript
# minimal_controller_example.gd
extends Node2D

@onready var player = $Player
@onready var controller_manager = get_node("ControllerManager")

func _ready():
    Input.joy_connection_changed.connect(_on_joy_changed)

func _on_joy_changed(device: int, connected: bool):
    print("Controller %s: %s" % ["connected" if connected else "disconnected", Input.get_joy_name(device)])

func _process(_delta):
    # Get input
    var move = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    var aim = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
    
    # Update player
    player.velocity = move * 200
    player.aim_direction = aim
    
    # Fire on input
    if Input.is_action_pressed("fire_primary"):
        player.fire_weapon(aim)
        
        # Haptic feedback
        if controller_manager.is_controller_connected():
            var device_id = controller_manager.active_device_id
            Input.start_joy_vibration(device_id, 0.3, 0.8, 0.1)
```

### GDExtension for Advanced Haptics (Future)

Currently, Godot 4.5.1's vibration API is limited. For advanced haptics (adaptive triggers on PS5, etc.), consider:

1. Custom GDExtension wrapping platform APIs
2. Waiting for Godot 4.6 improvements (planned)
3. Using platform-native plugins (limited for indie teams)

---

## References & Further Reading

### Official Documentation
- **Godot 4.5.1 Input Docs**: https://docs.godotengine.org/en/stable/classes/class_input.html
- **Input Map Guide**: https://docs.godotengine.org/en/stable/tutorials/input/using_gamepads.html
- **SDL3 Integration** (Godot 4.5+): GH-106218

### Community Resources
- Godot Input Forum: https://forum.godotengine.org (search "controller input mobile")
- Twin-stick Shooter Tutorial (Godot 4): YouTube - "Twin Stick Control in Godot 4"
- Backbone Integration: app.backbone.com game database

### Tools
- **SDL2 Gamepad Tool**: Test controller mapping and detect button layout
- **Godot Input Map Editor**: Project Settings > InputMap (visual button assignment)
- **Backbone App**: View connected controller info (iOS/Android)

---

## Troubleshooting Checklist

### Controller Not Detected

```gdscript
# Debug script
func debug_controllers():
    var joypads = Input.get_connected_joypads()
    print("Connected joypads: ", joypads)
    
    for device_id in joypads:
        print("Device %d: %s" % [device_id, Input.get_joy_name(device_id)])
        print("  Info: ", Input.get_joy_info(device_id))
        
        # Test all axes
        for axis in range(6):
            var value = Input.get_joy_axis(device_id, axis)
            if abs(value) > 0.1:
                print("  Axis %d: %.2f" % [axis, value])
```

### Buttons Not Registering

1. Check InputMap configuration (Project Settings)
2. Verify controller is detected (`debug_controllers()`)
3. Test with SDL Gamepad Tool for GUID/mapping
4. Check for input consumption by UI nodes (GUI focus issue)

### Haptic Not Working

- âœ… Ensure device is connected
- âœ… Check platform (haptics may be limited on some devices)
- âœ… Verify controller supports vibration (most modern controllers do)
- âœ… Test with `Input.vibrate_handheld()` for fallback

---

**Document Version**: 1.0
**Last Updated**: November 2025
**Godot Version**: 4.5.1
**Target Platforms**: iOS (MFi) | Android (Bluetooth)
**Primary Hardware**: Backbone One
