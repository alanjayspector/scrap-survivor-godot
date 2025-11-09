# Architecture Decisions

## Overview
This document tracks key architectural decisions made during the Godot 4 migration of Scrap Survivor.

## Decision Log

### ADR-001: Autoload Service Pattern
**Date:** Week 4
**Decision:** Use Godot autoloads for core services (GameState, ErrorService)
**Rationale:** Provides global access similar to TypeScript singleton pattern while leveraging Godot's built-in lifecycle management.
**Alternatives Considered:** Dependency injection, manual singletons
**Status:** Implemented

### ADR-002: Resource-Based Data Storage
**Date:** Week 3
**Decision:** Use Godot Resource (.tres) files for game data instead of pure JSON
**Rationale:** Provides type safety, Godot inspector integration, and easier debugging. JSON serves as source of truth, .tres files are generated.
**Alternatives Considered:** JSON only, CSV, SQLite
**Status:** Implemented

### ADR-003: StatService as Static Class
**Date:** Week 4
**Decision:** Implement StatService using static methods instead of autoload
**Rationale:** Pure calculation service with no state doesn't need lifecycle management. Static methods reduce overhead.
**Alternatives Considered:** Autoload singleton
**Status:** Implemented

### ADR-004: Entity Class Architecture
**Date:** Week 3
**Decision:** Entity classes (Player, Enemy, Projectile) extend Godot nodes directly (CharacterBody2D, Area2D)
**Rationale:** Leverages Godot's built-in physics and scene tree. Simpler than composition pattern for this use case.
**Alternatives Considered:** Composition pattern with separate components
**Status:** Implemented

## Future Decisions

### Pending: Supabase Integration Pattern
**Target:** Week 6
**Question:** How to structure async database operations in Godot's single-threaded environment
**Options:** Await pattern, callback signals, state machine

### Pending: Mobile Input Handling
**Target:** Week 15
**Question:** Virtual joystick vs touch-to-move for mobile controls
**Options:** Virtual joystick, tap-to-move, swipe controls

## References
- [Godot Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html)
- Original TypeScript architecture: `../scrap-survivor/docs/ARCHITECTURE.md`
