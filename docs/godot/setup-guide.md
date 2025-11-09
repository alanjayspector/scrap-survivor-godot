# Godot 4 Setup Guide

## Prerequisites

- macOS (M4 Max recommended)
- Godot 4.4+
- Python 3.x
- VS Code (recommended)

## Installation

### 1. Godot 4.4

Download from https://godotengine.org/download/ and install to `/Applications/Godot.app`

Verify:
```bash
/Applications/Godot.app/Contents/MacOS/Godot --version
# Should output: 4.4.x.stable.official
```

### 2. gdtoolkit (Linter/Formatter)

```bash
pip3 install "gdtoolkit==4.*"

# Verify
gdlint --version  # 4.x.x
gdformat --version
```

### 3. VS Code Extension

```bash
code --install-extension geequlim.godot-tools
```

## Project Setup

1. Clone repository:
   ```bash
   cd ~/Developer
   git clone https://github.com/YOUR_USERNAME/scrap-survivor-godot
   cd scrap-survivor-godot
   ```

2. Open in Godot:
   ```bash
   open -a Godot
   # Import project from Project Manager
   ```

3. Configure environment:
   ```bash
   cp .env.example .env
   # Edit .env with your Supabase credentials
   ```

## First Run

1. Press F5 in Godot Editor
2. Should show blank screen (expected for new project)

## Troubleshooting

See docs/migration/godot-quick-start.md
