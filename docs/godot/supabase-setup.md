# Supabase Addon Setup

## Status: NOT INSTALLED ⚠️

The Supabase addon is **required** for Week 6+ but is not currently installed.

## Installation Steps

### Option 1: AssetLib (Recommended)
1. Open Godot Editor
2. Click **AssetLib** tab at top
3. Search for "supabase"
4. Click **Download** on "Supabase" addon
5. Click **Install**
6. Restart Godot
7. Verify `addons/supabase/` directory exists

### Option 2: Manual Installation
1. Download from: https://github.com/supabase-community/godot-engine.supabase
2. Extract to `addons/supabase/`
3. Restart Godot
4. Enable in Project → Project Settings → Plugins

## Configuration

After installation, configure in `project.godot` or via GUI:

```ini
[editor_plugins]
enabled=PackedStringArray("res://addons/supabase/plugin.cfg")
```

## Environment Variables

Create `.env` file (add to .gitignore):
```
SUPABASE_URL=your_project_url
SUPABASE_ANON_KEY=your_anon_key
```

## Usage

```gdscript
var client = Supabase.create_client(
    OS.get_environment("SUPABASE_URL"),
    OS.get_environment("SUPABASE_ANON_KEY")
)

# Auth
var result = await client.auth.sign_up(email, password)

# Database
var data = await client.from("characters").select("*")
```

## Timeline

- **Week 6:** Supabase client setup and authentication
- **Week 7:** Database operations and sync service

## References

- [Godot Supabase Addon](https://github.com/supabase-community/godot-engine.supabase)
- [Supabase Documentation](https://supabase.com/docs)
