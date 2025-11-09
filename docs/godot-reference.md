# Godot Engine AI Code Assistant Reference Guide

This is a concise reference guide designed for AI code assistants to quickly locate Godot Engine documentation, resources, and API information. Each section includes links to the full documentation.

---

## Core Documentation Structure

### Official Documentation Root
- **Main Docs**: https://docs.godotengine.org/en/stable/
- **Latest Version**: https://docs.godotengine.org/en/latest/
- **Available Languages & Versions**: Expandable panel in sidebar

---

## Getting Started Sections

### Introduction & Overview
- **Introduction**: https://docs.godotengine.org/en/stable/about/introduction.html
  - Overview of Godot features and capabilities
  - Is Godot right for your project?
  
- **Step by Step**: https://docs.godotengine.org/en/stable/getting_started/step_by_step/index.html
  - Editor interface and navigation
  - Nodes and scenes fundamentals
  - GDScript basics and first classes
  - Signals and node communication

- **Your First 2D Game**: https://docs.godotengine.org/en/stable/getting_started/first_2d_game/index.html
  - Complete step-by-step tutorial
  - Full game structure and architecture

### How to Read the API
- **API Documentation Guide**: https://docs.godotengine.org/en/stable/tutorials/best_practices/how_to_read_the_api.html
  - Understanding class references
  - Properties, methods, and signals
  - Data types and return values

---

## Scripting & GDScript

### GDScript Language
- **GDScript Reference**: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/index.html
  - Syntax fundamentals
  - Built-in types (int, float, String, Vector2, etc.)
  - Type hints and type inference
  - Variables, constants, and enums
  - Classes, inheritance, and inner classes
  - Functions and method definitions
  - Control flow (if, for, while, switch)
  - Keywords and statements

- **GDScript Style Guide**: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/style_guide.html
  - Code organization and structure
  - Naming conventions (snake_case, CONSTANT_CASE, PascalCase)
  - Function/method ordering (public â†’ private, properties â†’ methods)
  - Docstring conventions
  - Enum formatting
  - Signal and property definitions

### C# Scripting
- **C# Basics**: https://docs.godotengine.org/en/stable/tutorials/scripting/c_sharp/index.html
  - C# language integration
  - Equivalent APIs to GDScript

---

## Engine Fundamentals

### Nodes & Scenes
- **Nodes and Scene Instances**: https://docs.godotengine.org/en/stable/tutorials/3d/using_3d_characters/index.html
  - Getting node references
  - Creating nodes from code
  - Adding child nodes
  - Instantiating packed scenes
  - Scene tree structure

- **Scene System**: https://docs.godotengine.org/en/stable/tutorials/3d/index.html
  - Scene organization
  - Node hierarchy
  - Instancing and composition

### Signals & Communication
- **Using Signals**: https://docs.godotengine.org/en/stable/tutorials/scripting/signals.html
  - Signal basics and emission
  - Connecting signals
  - Signal patterns and best practices
  - Event autoload pattern

### Input Handling
- **Using InputEvent**: https://docs.godotengine.org/en/stable/tutorials/inputs/using_input_events.html
  - Input event types
  - Input propagation through scene tree
  - GUI input handling
  - Custom input events

- **Input Map**: https://docs.godotengine.org/en/stable/tutorials/inputs/using_input_actions.html
  - Input actions configuration
  - Keyboard, mouse, and controller input

---

## 2D Game Development

### 2D Graphics & Rendering
- **2D Overview**: https://docs.godotengine.org/en/stable/tutorials/2d/index.html
  - 2D renderer and physics engine
  - Tilemaps
  - Particles and animation systems

- **Sprite and 2D Basics**: https://docs.godotengine.org/en/stable/tutorials/2d/introduction_to_2d.html
  - Sprite2D nodes
  - Texture and material properties
  - Canvas and layers

- **Camera2D**: https://docs.godotengine.org/en/stable/api/classes/class_camera2d.html
  - Camera positioning and zoom
  - Smooth following and limits
  - Anchor modes and process callbacks

### Tilemaps
- **Tilemap Documentation**: https://docs.godotengine.org/en/stable/tutorials/2d/using_tilemaps.html
  - Tileset creation
  - Tilemap rendering
  - Physics layers in tilesets
  - Tilemap optimization

### Animation
- **2D Animation**: https://docs.godotengine.org/en/stable/tutorials/2d/2d_sprite_animation.html
  - AnimatedSprite2D nodes
  - Frame-based animation
  - Animation playback control

### Particles
- **2D Particle Systems**: https://docs.godotengine.org/en/stable/tutorials/2d/particle_systems_2d.html
  - GPUParticles2D and CPUParticles2D
  - ParticleProcessMaterial configuration
  - Animation flipbooks
  - Emission and lifetime settings

### Physics (2D)
- **Physics 2D**: https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html
  - RigidBody2D, CharacterBody2D, StaticBody2D
  - Collision detection and layers
  - Physics materials and properties
  - Raycasting

---

## 3D Game Development

### 3D Graphics & Rendering
- **3D Introduction**: https://docs.godotengine.org/en/stable/tutorials/3d/index.html
  - 3D nodes and scenes
  - Models and meshes
  - Materials and shaders

- **Lighting**: https://docs.godotengine.org/en/stable/tutorials/3d/using_3d_lights.html
  - DirectionalLight3D
  - OmniLight3D (point lights)
  - SpotLight3D
  - Shadows and global illumination

- **Camera3D**: https://docs.godotengine.org/en/stable/tutorials/3d/using_3d_cameras.html
  - Camera positioning and projection
  - FOV and clipping planes
  - Multiple cameras

### 3D Physics
- **Physics 3D**: https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html
  - RigidBody3D, CharacterBody3D, StaticBody3D
  - Collision shapes
  - Gravity and forces
  - Joints and constraints

---

## Advanced Rendering & Shaders

### Shaders
- **Shader Documentation**: https://docs.godotengine.org/en/stable/tutorials/shaders/index.html
  - Shader language and syntax
  - Canvas item shaders
  - Spatial shaders
  - Built-in shader variables
  - Texture sampling and operations

### Materials
- **Materials**: https://docs.godotengine.org/en/stable/tutorials/3d/standard_material_3d.html
  - StandardMaterial3D properties
  - CanvasItemMaterial
  - Custom material scripting

### Viewports & Canvas
- **Viewport and Canvas Transforms**: https://docs.godotengine.org/en/stable/tutorials/rendering/viewport_and_canvas_transforms.html
  - Screen coordinates and transforms
  - Canvas layers
  - Custom input event feeding
  - Drawing on canvas

---

## User Interface (UI)

### Control System
- **GUI Overview**: https://docs.godotengine.org/en/stable/tutorials/ui/index.html
  - Control nodes hierarchy
  - Anchors and margins
  - Layout containers (VBox, HBox, Grid, etc.)
  - Signal-driven UI

- **Control Class**: https://docs.godotengine.org/en/stable/api/classes/class_control.html
  - Input event handling
  - Theme properties
  - Focus management
  - Size and position properties

### Common UI Nodes
- **Button, Label, LineEdit, TextEdit**: https://docs.godotengine.org/en/stable/tutorials/ui/using_3d_characters.html
- **Containers**: HBoxContainer, VBoxContainer, GridContainer, TabContainer
- **Advanced**: TreeItem, ItemList, PopupMenu

---

## Audio

### Audio System
- **Audio Documentation**: https://docs.godotengine.org/en/stable/tutorials/audio/index.html
  - AudioStreamPlayer nodes
  - Audio buses and effects
  - 3D audio positioning
  - Audio mixing

- **AudioStreamPlayer**: https://docs.godotengine.org/en/stable/api/classes/class_audiostreamplayer.html
  - Audio playback control
  - Volume and pitch
  - Bus assignment

---

## Project Management

### Project Settings
- **Project Settings**: https://docs.godotengine.org/en/stable/tutorials/project/project_setup.html
  - Project configuration
  - Input map setup
  - Autoload (singletons)
  - Feature tags

### Exporting
- **Exporting Projects**: https://docs.godotengine.org/en/stable/tutorials/export/index.html
  - Export templates
  - Platform-specific exports (Windows, Linux, macOS, Android, Web, etc.)
  - Export presets and configuration
  - Environment variables for export

- **Exporting for Specific Platforms**:
  - Windows: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_windows.html
  - Linux: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_linux.html
  - macOS: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_macos.html
  - Android: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html
  - Web (HTML5): https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html

---

## Advanced Topics

### Performance & Optimization
- **Performance**: https://docs.godotengine.org/en/stable/tutorials/performance/index.html
  - Optimization strategies
  - Profiling and benchmarking

- **Using Servers**: https://docs.godotengine.org/en/stable/tutorials/performance/using_servers.html
  - Low-level server APIs (RenderingServer, PhysicsServer2D, PhysicsServer3D, AudioServer)
  - RID (Resource ID) management
  - Performance-critical code optimization

- **The Profiler**: https://docs.godotengine.org/en/stable/tutorials/scripting/debug/the_profiler.html
  - Frame time and physics frame monitoring
  - Visual profiler for CPU/GPU
  - Function call tracking

### Debugging
- **Debug Techniques**: https://docs.godotengine.org/en/stable/tutorials/scripting/debug/index.html
  - Debugger panel overview
  - Breakpoints and watch variables
  - Console output and printing
  - Remote debugging

- **Visual Profiler**: https://docs.godotengine.org/en/stable/tutorials/scripting/debug/the_profiler.html
  - CPU and GPU performance monitoring

### Networking & Multiplayer
- **High-Level Multiplayer**: https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html
  - MultiplayerSpawner and MultiplayerSynchronizer
  - RPC (Remote Procedure Call)
  - Network replication
  - Dedicated server setup
  - Port forwarding for Internet play

### Plugins & Extensions
- **Editor Plugins**: https://docs.godotengine.org/en/stable/tutorials/plugins/editor_plugins.html
  - Plugin scaffolding and structure
  - EditorPlugin class
  - Custom tools and shortcuts
  - Plugin configuration (plugin.cfg)

- **GDExtension**: https://docs.godotengine.org/en/stable/tutorials/scripting/gdextension/index.html
  - C++ extension development
  - Binding custom classes
  - Performance-critical implementations

### Asset Library
- **Asset Library**: https://docs.godotengine.org/en/stable/community/asset_library/about.html
  - Available asset types
  - Downloading assets in editor
  - Submitting assets

---

## API Reference

### Class Hierarchy
- **Root Classes**:
  - `Object`: Base class for all objects
  - `Node`: Base for scene tree nodes
  - `Node2D`: Base for 2D nodes (Sprite2D, CharacterBody2D, etc.)
  - `Node3D`: Base for 3D nodes
  - `Control`: Base for UI elements

### Commonly Used Classes
- **Node Management**: Node, PackedScene, SceneTree
- **2D Nodes**: Sprite2D, AnimatedSprite2D, TileMap, Camera2D, CharacterBody2D, RigidBody2D, Area2D
- **3D Nodes**: MeshInstance3D, Camera3D, Light3D, CharacterBody3D, RigidBody3D, StaticBody3D
- **UI**: Control, Button, Label, LineEdit, Container, VBoxContainer, HBoxContainer
- **Audio**: AudioStreamPlayer, AudioStreamPlayer2D, AudioStreamPlayer3D, AudioBus
- **Physics**: PhysicsBody2D, CollisionShape2D, RayCast2D, PhysicsBody3D, CollisionShape3D
- **Animation**: AnimatedSprite2D, Tween, AnimationPlayer
- **Input**: Input (singleton), InputEvent, InputEventMouseButton, InputEventKey

### Built-in Types
- **Numeric**: int, float, Vector2, Vector2i, Vector3, Vector3i, Quaternion
- **String**: String, StringName
- **Collections**: Array, Dictionary, PackedByteArray, PackedColorArray, PackedFloat32Array, PackedInt32Array, PackedInt64Array, PackedStringArray, PackedVector2Array, PackedVector3Array
- **Other**: Color, Rect2, Rect2i, Transform2D, Transform3D, AABB, Plane, Callable, Signal, RID

---

## Common Code Patterns

### Getting Node References
```gdscript
# Direct path
var sprite = get_node("Sprite2D")
var camera = get_node("Camera2D")

# Using $ shorthand
@onready var sprite = $Sprite2D
@onready var camera = $Camera2D
```

### Creating Nodes at Runtime
```gdscript
var sprite = Sprite2D.new()
add_child(sprite)

# Instantiate scene
var scene = load("res://player.tscn")
var instance = scene.instantiate()
add_child(instance)
```

### Signals
```gdscript
# Define custom signal
signal health_changed(new_health)

# Emit signal
emit_signal("health_changed", 100)

# Connect to signal
signal_name.connect(callback_function)
```

### Input Handling
```gdscript
func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_SPACE:
            # Handle space key
            pass

func _process(_delta: float) -> void:
    if Input.is_action_pressed("ui_right"):
        # Handle continuous input
        position.x += 5
```

---

## File Organization Best Practices

### Project Structure
```
res://
â”œâ”€â”€ scenes/           # Scene files
â”œâ”€â”€ scripts/          # GDScript files
â”œâ”€â”€ assets/
â”‚   â”œâ”€â”€ sprites/
â”‚   â”œâ”€â”€ audio/
â”‚   â”œâ”€â”€ models/       # 3D models
â”‚   â””â”€â”€ fonts/
â”œâ”€â”€ addons/           # Plugins and extensions
â”œâ”€â”€ project.godot     # Project configuration
â””â”€â”€ export_presets.cfg  # Export settings
```

### Script Organization
- Signals first
- Properties and exports
- Public methods
- Private methods
- Virtual callbacks (_ready, _process, _input)

---

## Version Information

This reference is for **Godot 4.4 stable** branch, the latest version as of 2025.

### Documentation Availability
- Offline downloads available (HTML, ePub)
- Updated weekly
- Available in multiple languages
- Different versions accessible via dropdown

---

## Additional Resources

### Community & Support
- **Official Forum**: https://forum.godotengine.org/
- **Discord**: Community chat channels
- **GitHub Issues**: Bug reports and feature requests
- **GDQuest**: Free interactive GDScript tutorials (Learn GDScript From Zero)

### External Learning
- Video tutorials on YouTube (official and community)
- Asset Library for plugins and utilities
- Community-maintained documentation and guides

---

## Quick Navigation Reference

| Need | Location |
|------|----------|
| Class API info | https://docs.godotengine.org/en/stable/api/classes/ |
| GDScript syntax | https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/ |
| 2D development | https://docs.godotengine.org/en/stable/tutorials/2d/ |
| 3D development | https://docs.godotengine.org/en/stable/tutorials/3d/ |
| UI/GUI | https://docs.godotengine.org/en/stable/tutorials/ui/ |
| Input handling | https://docs.godotengine.org/en/stable/tutorials/inputs/ |
| Physics | https://docs.godotengine.org/en/stable/tutorials/physics/ |
| Audio | https://docs.godotengine.org/en/stable/tutorials/audio/ |
| Exporting | https://docs.godotengine.org/en/stable/tutorials/export/ |
| Performance | https://docs.godotengine.org/en/stable/tutorials/performance/ |
| Debugging | https://docs.godotengine.org/en/stable/tutorials/scripting/debug/ |
| Networking | https://docs.godotengine.org/en/stable/tutorials/networking/ |
| Plugins | https://docs.godotengine.org/en/stable/tutorials/plugins/ |

---

**Last Updated**: November 2025
**Godot Version**: 4.4 Stable
**Documentation**: https://docs.godotengine.org/en/stable/
