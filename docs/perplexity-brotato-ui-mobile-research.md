# Brotato Mobile UI Analysis

**Analysis Date**: November 18, 2025  
**Videos Analyzed**: YouTube gameplay footage (limited measurement data available)  
**Critical Limitation**: Video analysis cannot provide precise UI measurements

## Executive Summary

I've thoroughly researched the available Brotato mobile gameplay videos and documentation, but **I cannot provide the specific measurements you've requested** (button sizes in iOS points, exact spacing values, precise typography scales, etc.) for the following reasons:

### Why Precise Measurements Are Unavailable

1. **Video Limitation**: YouTube videos don't display UI specifications or allow frame-by-frame measurement of iOS points/Android dp values. The videos show gameplay but don't include overlays with dimensions.

2. **No Official Design Documentation**: Brotato's mobile version (developed by Erabit Studios) doesn't have publicly available design specifications, style guides, or UI documentation.

3. **Device Variance**: The mobile gameplay footage I found shows the game on various devices (Android tablets, iPhones) at different resolutions, making it impossible to accurately convert pixel observations to iOS points without knowing the exact device and scale factor.

4. **Dynamic UI Elements**: Many UI elements in Brotato scale and adapt to different screen sizes and aspect ratios, meaning measurements would vary significantly between devices.

## What I Can Provide: Qualitative UI Analysis

Based on my research of multiple mobile gameplay videos and user reviews, here's what I've observed about Brotato's mobile UI:

### Touch Controls & Interaction Patterns

**Control Scheme**:
- Virtual joystick (movable anywhere on screen by default, with option to fix position)
- Single-button interaction for selections and confirmations
- Touch-anywhere-to-move gameplay
- Press-and-hold for detailed character information

**User Feedback on Touch Targets**:
- Players report the UI is "perfect for mobile" and "works really well"
- Thumb-friendly interface, though some users note their thumb can block portions of the screen during gameplay
- Generally comfortable touch targets for tablet use
- Some iPad users reported UI scaling issues where elements were "way too big" and "spilled off the screen" on iPad Mini 5th generation

### HUD Elements Observed

**In-Game HUD**:
- Health bar displayed above character (feature added for mobile)
- Level-up progress bar (top-left area)
- Material/currency counter (top-left area)
- "Bag" indicator showing uncollected materials from previous wave
- Wave timer (top-center or top-right)
- Pause button (accessible location, likely top-right)

**Missing PC Features on Mobile**:
- No hover-to-see weapon damage from previous wave
- Cannot hover to see detailed weapon set bonuses without tapping

### Menu & Shop Screens

**Character Selection**:
- Grid layout for character cards
- Some users requested the character selection be moved up to avoid triggering system gestures on iOS
- Press-and-hold interaction to see character details

**Shop Between Waves**:
- Reroll button for shop items
- Lock feature for items you want to save for next round
- Item and weapon cards with stats
- Recycling system for unwanted weapons
- Multiple pages of items available

### Typography & Readability

**User Reports**:
- Text is "clearly visible" on mobile screens
- Stats and numbers are readable during gameplay
- No reported issues with font sizes being too small for mobile viewing
- Some users on tablets wished for larger UI scaling options

### Spacing & Layout

**General Observations**:
- UI described as "clean" and "not cluttered"
- Elements are well-spaced for touch interaction
- No reports of accidental taps due to cramped spacing
- Layout adapts to landscape orientation only (no portrait mode)

### Color & Visual Hierarchy

**Style**:
- Hand-drawn art style reminiscent of "flash games"
- Color-coded item rarity system (common, rare, legendary)
- Visual feedback for successful dodges and damage numbers

## Recommendations for Your Godot Game UI

Since I cannot provide exact Brotato measurements, here are **evidence-based mobile UI standards** you should follow for your Godot game:

### 1. Touch Target Sizes (Industry Standards)

| Priority Level | Recommended Size | Reference |
|---------------|------------------|-----------|
| Primary Action Buttons | 72px / ~48pt | Apple HIG: 44x44pt minimum |
| Medium Priority Buttons | 60px / ~40pt | Optimal range: 42-72px |
| Minimum Touch Target | 44x44pt (iOS) / 48x48dp (Android) | iOS HIG, Material Design |
| Icon-Only Buttons | 44x44pt minimum | Apple HIG requirement |
| Spacing Between Buttons | 12-48px depending on button size | UX research standard |

**Conversion Formula**:
- iOS @2x: 1 point = 2 pixels
- iOS @3x (iPhone Plus/Pro/Max): 1 point = 3 pixels
- Android: varies by device density

### 2. Typography Scale for Mobile

| Text Type | Minimum Size | Recommended | Notes |
|-----------|-------------|-------------|-------|
| Body Text | 17pt | 17-19pt | iOS HIG minimum for readability |
| Button Labels | 16-18pt | 17pt | Should be bold or semibold |
| Screen Titles | 28-34pt | 32pt | Large, bold |
| Small Labels/Meta | 13-15pt | 14pt | Minimum for legibility |
| Stat Numbers (Large) | 24-32pt | 28pt | High contrast |

### 3. Safe Area & Spacing

**Safe Area Clearance**:
- **Top (with notch/Dynamic Island)**: 44-59pt from top edge
- **Bottom (home indicator)**: 34pt from bottom edge
- **Sides**: 16pt minimum from edges
- **Between tappable elements**: 8-16pt minimum

**Screen Edge Padding**:
- Horizontal margins: 16-24pt
- Vertical padding: 16-20pt
- Section spacing: 24-32pt

### 4. Combat HUD Best Practices

Based on mobile game design principles and the research on Brotato's approach:

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ [HP: â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–‘â–‘] 44pt  [âš™ï¸] 44x44pt  â”‚ â† 60pt from top (safe area)
â”‚ from top-left                        â”‚
â”‚                                       â”‚
â”‚                                       â”‚
â”‚          [GAMEPLAY AREA]              â”‚
â”‚     (Thumb zones: bottom corners)    â”‚
â”‚                                       â”‚
â”‚                                       â”‚
â”‚ [â•â•â•â•XP Progress Barâ•â•â•â•â•â•â•â•â•â•â•â•]    â”‚ â† 40-50pt from bottom
â”‚         120pt from bottom edge        â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

**Critical HUD Guidelines**:
- Keep top HUD elements within 60-80pt from top edge
- Avoid placing critical UI in bottom corners (thumb occlusion zones)
- Make HP bars at least 120pt wide for readability
- Use 40-60pt height for bottom progress bars
- Ensure 44x44pt minimum for pause/settings buttons

### 5. Interaction Design Patterns

**Button Feedback** (industry standards):
- Press animation: 50-100ms scale to 0.95 (ease-out)
- Release animation: 150-200ms return to scale 1.0
- Success feedback: 200-300ms with color change + haptic
- Error feedback: Shake animation 300ms + red flash + haptic

**Screen Transitions**:
- Modal appear: 250-300ms slide up from bottom or scale from center
- Modal dismiss: 200-250ms reverse animation
- Screen navigation: 300-350ms slide or fade transition

### 6. Additional Resources for Your Implementation

Since Brotato's exact specs aren't available, I recommend studying these similar games with documented mobile UIs:

1. **Vampire Survivors Mobile** - Similar bullet heaven genre
2. **20 Minutes Till Dawn** - Same publisher as Brotato mobile
3. Reference **Apple's HIG** and **Material Design** directly for platform-specific guidelines

## What You Should Do Next

1. **Play Brotato Mobile Yourself**: Download the game ($4.99 premium or free with ads) and take your own screenshots

2. **Use Design Measurement Tools**: 
   - iOS: Use Xcode's View Debugger on a jailbroken device
   - Android: Enable Developer Options â†’ Show Layout Bounds
   - Use screen capture + ruler overlay apps to estimate measurements

3. **Build Your Own Measurement Framework**: Create a test Godot scene with buttons at different iOS point sizes (44pt, 52pt, 60pt, 72pt) and test on your target devices to find what feels right

4. **Follow Platform Guidelines First**: Apple HIG and Material Design are more reliable than reverse-engineering another game

## Open Questions / Areas Not Visible

- Exact font family used (appears to be a hand-drawn or pixel-style font)
- Precise animation timing values
- Haptic feedback patterns (not observable in video)
- Exact color hex codes (video compression affects accuracy)
- Device-specific scaling factors
- Portrait orientation measurements (game is landscape-only)

---

I apologize that I couldn't provide the detailed measurement tables you requested. Video analysis simply cannot yield the precise iOS point measurements needed for UI implementation. However, the industry-standard measurements I've provided above are actually **more reliable** than reverse-engineering another game, as they're based on platform guidelines and UX research that Brotato itself likely followed.

For your Godot mobile game, I strongly recommend implementing the iOS HIG and Material Design standards I've outlined, then playtesting extensively on real devices to refine your specific measurements.
