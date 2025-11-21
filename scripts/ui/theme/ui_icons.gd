class_name UIIcons
extends RefCounted
## UIIcons - Centralized icon asset management
## Week 16: Kenney Game Icons integration
##
## Usage:
##   var icon = UIIcons.get_icon(UIIcons.Icon.SETTINGS)
##   texture_rect.texture = icon

## Icon identifiers mapped to game concepts
enum Icon {
	# Navigation
	HOME,
	BACK,
	NEXT,
	PREVIOUS,
	EXIT,
	# Actions
	PLAY,
	DELETE,
	CONFIRM,
	CANCEL,
	# Settings
	SETTINGS,
	AUDIO_ON,
	AUDIO_OFF,
	MUSIC_ON,
	MUSIC_OFF,
	# Game Stats
	HEALTH,  # plus.png (will use for HP)
	ARMOR,  # locked.png (shield-like)
	TARGET,  # target.png (for accuracy/damage)
	STAR,  # star.png (XP/level)
	TROPHY,  # trophy.png (achievements)
	MEDAL_GOLD,  # medal1.png
	MEDAL_SILVER,  # medal2.png
	# Feedback
	INFO,
	WARNING,
}

## Icon file paths (relative to res://themes/icons/game/)
const ICON_PATHS: Dictionary = {
	Icon.HOME: "home.png",
	Icon.BACK: "return.png",
	Icon.NEXT: "next.png",
	Icon.PREVIOUS: "previous.png",
	Icon.EXIT: "exitRight.png",
	Icon.PLAY: "fastForward.png",
	Icon.DELETE: "trashcan.png",
	Icon.CONFIRM: "checkmark.png",
	Icon.CANCEL: "cross.png",
	Icon.SETTINGS: "gear.png",
	Icon.AUDIO_ON: "audioOn.png",
	Icon.AUDIO_OFF: "audioOff.png",
	Icon.MUSIC_ON: "musicOn.png",
	Icon.MUSIC_OFF: "musicOff.png",
	Icon.HEALTH: "plus.png",
	Icon.ARMOR: "locked.png",
	Icon.TARGET: "target.png",
	Icon.STAR: "star.png",
	Icon.TROPHY: "trophy.png",
	Icon.MEDAL_GOLD: "medal1.png",
	Icon.MEDAL_SILVER: "medal2.png",
	Icon.INFO: "information.png",
	Icon.WARNING: "warning.png",
}

const ICON_BASE_PATH: String = "res://themes/icons/game/"


## Get icon texture by enum
static func get_icon(icon: Icon) -> Texture2D:
	var path = ICON_BASE_PATH + ICON_PATHS.get(icon, "")
	if ResourceLoader.exists(path):
		return load(path)
	push_warning("[UIIcons] Icon not found: %s" % path)
	return null


## Get icon path by enum (for preloading)
static func get_icon_path(icon: Icon) -> String:
	return ICON_BASE_PATH + ICON_PATHS.get(icon, "")


## Apply icon to a TextureRect with optional tint
static func apply_icon(texture_rect: TextureRect, icon: Icon, tint: Color = Color.WHITE) -> void:
	var tex = get_icon(icon)
	if tex:
		texture_rect.texture = tex
		texture_rect.modulate = tint


## Apply icon to a Button (icon property)
static func apply_button_icon(button: Button, icon: Icon) -> void:
	var tex = get_icon(icon)
	if tex:
		button.icon = tex
