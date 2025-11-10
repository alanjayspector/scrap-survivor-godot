# Scrap Survivor - Godot 4

Roguelike survival game built with Godot 4.4

**Migrated from React+Phaser to native Godot engine for optimal mobile performance.**

## 🎮 Features

- **Wave-based Combat:** 50 waves of increasingly difficult enemies
- **23 Weapons:** From rusty pistols to quantum disruptors
- **Crafting System:** Weapon fusion and item crafting
- **Cloud Sync:** Supabase backend with offline-first architecture
- **Mobile-First:** Native iOS and Android support

## 🚨 For AI Assistants

**If you are an AI assistant (Claude Code, Copilot, etc.) working on this codebase:**

- ✅ **READ [docs/DEVELOPMENT-RULES.md](docs/DEVELOPMENT-RULES.md) FIRST**
- ❌ **NEVER use `git commit --no-verify`** or any flag that bypasses hooks
- ✅ **Pre-commit hooks are mandatory** - fix errors, don't bypass validation
- ✅ **If blocked after 2 fix attempts, ASK THE USER** - never bypass on your own

The pre-commit hooks are **critical protective layers** that catch bugs before they're committed. Bypassing them defeats their entire purpose.

---

## 🛠️ Tech Stack

- **Engine:** Godot 4.4
- **Language:** GDScript
- **Backend:** Supabase (PostgreSQL + Auth + Real-time)
- **Platforms:** iOS, Android, Web (HTML5 export)

## 📱 Target Performance

- **60 FPS** on mid-range devices (2021+)
- **15MB** app size (compressed)
- **150+ entities** on screen simultaneously

## 🚀 Development

See [docs/godot/setup-guide.md](docs/godot/setup-guide.md) for development setup.

## 📚 Migration

This is a port from the React+Phaser web version. See [docs/migration/](docs/migration/) for complete migration documentation.

## 📄 License

MIT
