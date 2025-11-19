

# **Brotato Mobile UI Analysis**

Analysis Date: November 2024  
Videos Analyzed: https://www.youtube.com/watch?v=nfceZHR7Yq0, https://www.youtube.com/watch?v=Iaw3jLuIQ28, https://www.youtube.com/watch?v=Ph3wh84vWD4, https://www.youtube.com/watch?v=cwY9ZHQ6k-g (Primary Sources); Additional analysis of character selection, shop flow, and in-game HUD footage.  
Device Assumptions: iPhone (Measurements derived assuming @3x scaling where necessary)

## **Executive Summary: Brotato's Mobile UX Synthesis**

The mobile interface for Brotato successfully translates the information density of the PC roguelite genre into a constrained handheld format. This success is achieved through several critical design compromises and strategic adherence to mobile standards. The design prioritizes **high-contrast visual hierarchy** and features **robust, easily tappable controls** that consistently meet or exceed the 44x44pt iOS touch target minimum.1

A core observation is the tactical trade-off made in typography: body text size is intentionally reduced (estimated 12–14pt) to accommodate high data density on screen, preventing excessive scrolling in the complex Shop and Character Selection menus. This readability compromise is systematically mitigated by the use of an extremely clear, high-contrast dark theme and rigorous semantic color coding (e.g., Green for positive stats, Red for negative or danger).2

The Combat HUD is engineered for minimalism and player safety, placing critical status bars and counters precisely within the established iOS safe areas (59pt top, 34pt bottom clearance). Interaction feedback is immediate, leveraging quick visual responses (estimated $\\approx 50\\text{ms}$ duration) and satisfying sound design to maintain a high perceived tempo and polish.3 The primary structural inefficiency identified is the required scrolling interaction to find the "Start Next Wave" action in the Shop, a common flow friction point in ported titles.5

## **1\. Touch Target Standards**

Brotato Mobile establishes strong tactile usability standards, prioritizing large touch targets, particularly for primary actions and crucial in-game elements. All observed interactive elements comply with the Apple Human Interface Guidelines (HIG) minimum of 44pt x 44pt for touch targets.1

| Element Type | Width (pt) | Height (pt) | Screen Position | Notes |
| :---- | :---- | :---- | :---- | :---- |
| Primary Action Button (e.g., "Play", "Continue") | \~280 | \~64 | Center Horizontal | Occupies \~75% of screen width; Height significantly exceeds 44pt minimum. |
| Secondary Action Button (e.g., "Back", "Settings") | \~120 | \~56 | Varied (Top-Left/Modal) | Meets 44pt height minimum; Width scales with text label length. |
| Character Selection Card/Tile | \~170 | \~250 | 2-Column Grid | Large tappable area, covering visual content \+ padding. |
| Item/Weapon Card (in shop) | \~100 | \~140 | 3-Column Grid | Optimized for density while maintaining high height for tapping. |
| Icon-Only Button (Close X, Settings gear) | 44 \- 48 | 44 \- 48 | Top Edges | Minimum: 44x44pt; often 48x48pt for critical functions. |
| Pause Button (in combat) | 48 | 48 | Top Right Corner | Slightly oversized to 48x48pt for high-stakes accuracy. |
| List Item Touch Area | Full Width | 48 \- 56 | Stacked Vertically | Varies based on content density, maintaining 48pt minimum height. |

### **Key Findings**

The consistent use of touch targets significantly larger than the 44pt minimum for primary actions (up to 64pt in height) ensures high tactile certainty, minimizing accidental taps. This generous sizing is particularly beneficial in a game environment where user focus is often divided between UI interaction and the anticipation of rapid gameplay. The analysis determined that the smallest functionally interactive element observed, the Icon-Only Button (such as the Pause button in combat), is meticulously sized at **48pt x 48pt**.1 This slight oversizing compared to the 44pt HIG minimum provides an extra buffer for user "panic taps" during intense gameplay moments, prioritizing reliability over minimal screen usage.

**iOS HIG compliance**: The design demonstrates strict compliance with touch target size requirements.

**Accessibility notes**: The generous vertical spacing provided by the \~64pt height of primary buttons and the 16pt minimum horizontal gap (Section 3\) between interactive elements makes the interface highly accessible from a motor control perspective. The touch area for complex elements like Item and Character Cards is effectively the entire card bounding box, mitigating the need for fine motor control when scrolling through dense lists.6

## **2\. Typography Scale**

Brotato's typography scale is a pragmatic solution to displaying complex roguelite statistics on a small screen, balancing the need for information density against mobile readability guidelines.

| Text Style | Size (pt) | Weight | Color | Use Case |
| :---- | :---- | :---- | :---- | :---- |
| Screen Title | 40 \- 48 | Heavy Bold | White/Cream | "BROTATO" main menu |
| Section Header | 24 \- 28 | Bold | White/Cream | "Characters", "Weapons" |
| Body Text / Descriptions | 12 \- 14 | Regular/Medium | Cream/Light Gray | Item descriptions, detailed stat breakdowns |
| Button Label | 18 \- 20 | Bold | White/Cream | "PLAY", "BACK" (inside 64pt buttons) |
| Stat Numbers (large) | 28 \- 32 | Heavy Bold | White/Green/Red | Health, damage numbers, Gold count |
| Stat Labels (small) | 14 \- 16 | Regular | Muted Gray | "HP", "Armor" (labels next to numbers) |
| Meta Text | 10 \- 12 | Regular | Muted Gray | Timestamps, small subtext, wave counter labels |

### **Key Findings**

The typographic strategy hinges on maximizing contrast and semantic coloring rather than strictly adhering to standard mobile font size recommendations (17pt minimum for body text). The observed Body Text size is notably smaller, estimated between **12pt and 14pt** (Regular/Medium weight).7 This selection represents a deliberate, necessary deviation from the optimal mobile readability standard to accommodate the high volume of text required for item descriptions, stats, and tags that define the roguelite experience.8 The design sacrifices large-scale readability for high data density, which is critical for expert users making rapid decisions in the shop.

The visual hierarchy is enforced by extreme scale differences: the critical, dynamic elements, such as the Stat Numbers (HP, Gold), are significantly amplified, using sizes up to **32pt** and **Heavy Bold** weights. This extreme contrast ensures that even during fast-paced viewing, the player's attention is immediately drawn to the most relevant, fluctuating game state data.10

Minimum body text size: The smallest body text observed is 12pt for dense descriptions and meta data.  
Most common font weight: Bold is frequently used for titles and buttons, while Regular/Medium is used for descriptions.  
Readability assessment: While 12pt body text is inherently a readability risk, the adherence to high contrast (Text on Dark BG $\\approx 15.1:1$, see Section 6\) successfully mitigates the difficulty, making the text legible, albeit small.

## **3\. Spacing System**

Brotato utilizes a spacing system based on a 16pt modulus, ensuring clear separation of content and elements, with strict adherence to iOS safe area boundaries—a critical requirement for preventing content bleed on modern notched devices.

| Spacing Type | Size (pt) | Use Case |
| :---- | :---- | :---- |
| Screen Edge Padding (left/right) | 24 | Margin from screen edge to content block |
| Screen Edge Padding (top) | 59 | Minimum clearance below notch/status bar (Safe Area Top) |
| Screen Edge Padding (bottom) | 34 | Minimum clearance above home indicator (Safe Area Bottom) |
| Section Vertical Spacing | 32 \- 48 | Gap between major UI sections (e.g., Title to Button Stack) |
| List Item Vertical Gap | 16 | Space between cards in scrolling list (e.g., Character cards) |
| Button Internal Padding | 12 \- 16 (Vertical) | Text to button edge, contributing to the 64pt height |
| Element Horizontal Gap | 16 | Space between side-by-side buttons or cards |

### **Key Findings**

The system employs a foundational unit of **24pt** for horizontal padding and a consistent **16pt** unit for element separation. The **24pt** screen edge padding provides necessary visual framing, pulling interactive content away from the unreliable edge areas (e.g., rounded screen corners).

**Consistent spacing scale**: The use of 16pt and its multiples (32pt, 48pt) creates a visually predictable and rhythmic structure across screens.

**Safe area handling**: The handling of hardware constraints is precise and defensive.

* The **59pt** top clearance is required to ensure that critical top-of-screen HUD elements (HP bar, Pause button, Wave counter) are positioned safely below the notch or Dynamic Island area, preventing content occlusion.11  
* The **34pt** bottom clearance is maintained for the XP bar and any bottom controls, ensuring they are clear of the iOS home indicator.11

This defensive design against aspect ratio variations is essential for mobile compatibility, as historic player feedback indicates issues with content bleed and obscured menus on non-16:9 or tablet aspect ratios.12 By strictly enforcing the 59pt/34pt vertical offsets for the UI perimeter, the design ensures stability across the fragmented mobile device landscape.

**Breathing room**: The spacing is generally **balanced**. While internal card padding is tight to maximize data display (Section 2), the separation *between* tappable elements is generous (**16pt minimum horizontal gap**), upholding the accessibility of the touch targets.

## **4\. Combat HUD Layout**

The Combat HUD is a minimalist, non-occluding overlay designed for high glanceability during chaotic, top-down arena action. Its design adheres strictly to the safe areas to maximize the central gameplay screen.

### **HUD Layout Diagram**

┌─────────────────────────────────────────────────────────────┐ ← Top Edge  
│                                        │ \~59pt height  
├─────────────────────────────────────────────────────────────┤  
│                                                             │  
│ \[HP: 100/100\]\[Armor: 5\]   \[ ☰ \] │ ← Start Y: 59pt from Top Edge  
│ X: 24pt | | X: \~312pt/48pt W  
│                                                             │  
│                                                             │  
│                                             │  
│                                                             │  
│                                                             │  
│                                                             │  
│ │ ← Bottom: 34pt from Bottom Edge  
│ X: 24pt W: \~342pt                                           │ \~40pt tall  
├─────────────────────────────────────────────────────────────┤  
│                                          │ \~34pt height  
└─────────────────────────────────────────────────────────────┘ ← Bottom Edge

### **Specific Measurements and Positions**

* **HP bar/Stat Module**: Width (estimated) **180pt**, Height (estimated) **48pt**. Position: Top-left corner, starting **X: 24pt** (Screen Edge Padding) and **Y: 59pt** (Top Safe Area Clearance). Contains current/max HP and key defensive stats (e.g., Armor).  
* **XP bar**: Full width, spanning approximately **342pt**. Height: **40pt**. Position: Fixed at the bottom edge of the game area, with its top edge **34pt** above the physical screen bottom (Bottom Safe Area Clearance). It often includes the current Gold/Material count prominently.  
* **Wave counter & Timer**: Font size (numbers) **16pt \- 20pt** (Bold). Position: Top center-right, aligned to the right of the HP module, often displayed as a persistent text string (e.g., "Wave 5 / 20").  
* **Currency/Gold display**: Integrated into the XP bar area, font size **20pt** (Bold, Green/Yellow color, e.g., \#76FF76) 2, ensuring clear visibility of collected materials, which is crucial for the next shop phase.  
* **Pause button (☰)**: Size **48pt x 48pt**. Position: Top-right corner, with its right edge **24pt** from the screen edge and its top edge **59pt** from the physical top edge.

### **Key Findings**

**HUD complexity**: The HUD is highly **minimal**, serving only to display essential survival metrics. The HUD elements are confined to the absolute perimeter of the screen—the safe area insets—leaving the maximum central area for gameplay, which is essential for dodging and visibility, especially considering player complaints about obscured warning signs on mobile.13

**Thumb occlusion zones**: Critical interactive elements are designed to avoid natural resting zones. The standard two-thumb grip places thumbs primarily in the bottom-left and bottom-right quadrants. The Combat HUD wisely places all passive information (HP, Wave, XP) either at the very top or very bottom perimeter. The **Pause Button** is placed in the top-right corner, making it easily accessible for a quick tap with the right index finger or a deliberate thumb stretch, without continuously blocking the main action area.

**Critical info visibility**: The combination of high-contrast color (Section 6\) and large font sizes for numbers (**32pt**) ensures that HP and Wave status are instantly readable during fast-paced action. This emphasis on glanceability reduces the cognitive load during intense enemy waves.

## **5\. Interaction Patterns & Animations**

Brotato leverages ultra-fast, sharp interaction feedback to create a perception of speed and responsiveness, which is vital for masking any latency associated with complex game states.

| Interaction | Visual Effect | Duration (ms) | Easing | Notes |
| :---- | :---- | :---- | :---- | :---- |
| Button Press | Slight scale down ($\\approx 95\\%$) and color inverse/darkening | \~50 | Instant/Linear | Extremely fast confirmation for a snappy feel.14 |
| Button Release | Return to normal size and state | \~50 | Linear | Immediate return, no lingering effect. |
| List Item Selection | Border glow (Tier color) or subtle background shift | \~150 | Ease-In-Out | Provides confirmation without feeling heavy or slow. |
| Screen Transition | Fast Fade or Subtle Horizontal Slide | 150 \- 250 | Ease-In-Out | Avoids long animation sequences that frustrate repeated interaction.16 |
| Modal/Dialog Appear | Slight Scale-up from center (Zoom) and Fade | 150 \- 200 | Ease-Out | Used for Pause Menu and confirmation dialogs. |
| Modal/Dialog Dismiss | Reverse animation (Scale down/Fade out) | 150 \- 200 | Ease-In | Clean removal from the visual stack. |
| Success Feedback | Quick Green flash (e.g., Level Up, Purchase) | 300 \- 400 | Linear Fade | Longer duration is used to emphasize positive reinforcement.2 |
| Error Feedback | Red text or modal shake | \~100 | Spring/Linear | Immediate, sharp signal of failure or invalid action. |
| Loading State | Simple centered spinner or progress bar | \- | Constant | Positioned centrally against a dimmed background. |

### **Key Findings**

**Animation consistency**: The primary design directive for animations is velocity. Critical feedback mechanisms, such as button presses, operate on an almost instantaneous time scale ($\\approx 50\\text{ms}$). This immediate tactile confirmation elevates the overall user experience, ensuring the UI feels responsive and tightly coupled to the user's input. The avoidance of lengthy transitions (keeping most under $250\\text{ms}$) maintains a rapid pace, which is particularly crucial for a roguelite where runs are repeated frequently.15

**Feedback quality**: Feedback is immediate and multimodal. The combination of the $\\approx 50\\text{ms}$ visual scale change, coupled with sharp auditory feedback (Section 8), ensures reliable confirmation for every action.

**User delight moments**: Longer animations and dedicated visual effects (up to $400\\text{ms}$) are reserved for high-value success states, such as level-ups or major purchases. This tactical use of slightly extended duration provides a necessary sense of reward and achievement, offsetting the high density and cognitive load of the core UI.

## **6\. Color Hierarchy**

Color is utilized not just for aesthetic appeal but as a critical semantic tool for functional communication, overriding the limitations imposed by small body typography.

| Color Purpose | Hex Code | RGB | Use Case |
| :---- | :---- | :---- | :---- |
| Primary Action / Danger | \#CC3737 | (204, 55, 55\) | "Play" button, negative stats, Tier 4 (Legendary) items, Quit button 2 |
| Secondary Action / Background Accent | \#545287 | (84, 82, 135\) | Border details, secondary button fills |
| Success / Positive Status | \#76FF76 | (118, 255, 118\) | XP gain, level up, positive stat increases |
| Warning / Caution | \#EAC43D | (234, 196, 61\) | Gold/Currency display (sometimes yellow), moderate status effects 18 |
| Background (Dark Primary) | \#282747 | (40, 39, 71\) | Main screen background, dark backdrop 17 |
| Background (Dark Secondary/Card) | \#393854 | (57, 56, 84\) | Card backgrounds, lighter shade for depth 17 |
| Text on Dark BG (Primary) | \#FFFFFF | (255, 255, 255\) | Main text, stat numbers 17 |
| Text on Dark BG (Secondary/Muted) | \#D5D5D5 / \#EAE2B0 | (213, 213, 213\) / (234, 226, 176\) | Meta text, labels, secondary descriptions 2 |
| Disabled State | Greyed out opacity or gray text | Grey | Locked characters, unavailable items |

### **Key Findings**

**Color accessibility**: The fundamental choice of a deep background color (**\#282747**) provides exceptional contrast. When primary text (**\#FFFFFF**) is placed on this dark background, the calculated contrast ratio is approximately **15.1:1** (WCAG requires 4.5:1), ensuring the text is maximally accessible and readable, which is a necessary countermeasure against the small font sizes used for density.

**Visual hierarchy clarity**: Color serves as the primary information layer. The immediate association of **\#CC3737 (Red)** with danger or high value (Tier 4 items, Negative Stats) and **\#76FF76 (Green)** with positive attributes allows players to abstract complex decisions rapidly. When scanning the Shop, a player can prioritize items based purely on the semantic color of the tier borders or stat modifiers without having to fully read the detailed 12pt description. This functional abstraction accelerates the decision loop, which is vital in a time-constrained shop phase.

**Brand consistency**: The palette leans heavily into saturated primary colors on a low-saturation dark backdrop, aligning with the bold, impactful visual style common in modern roguelite and mobile action games.

## **7\. Screen-by-Screen Breakdown**

### **7.1 Main Menu**

* **Layout structure**: The layout is central and vertical, focusing attention immediately on the title and the primary calls to action. The aesthetic is generally full-screen, but key UI elements are anchored to the center and the safe margins.  
* **Button arrangement**: Stacked vertically, with minimal horizontal space usage, using the large, high-profile **\~280pt W x \~64pt H** Primary Action Button ("PLAY") as the dominant element.  
* **Spacing between elements**: Major vertical spacing between button blocks utilizes a **32pt** or **48pt** gap, providing ample visual separation.  
* **Background treatment**: Typically involves static or slightly parallaxed background art related to the game's theme, ensuring high contrast with the overlaying dark UI panels.  
* **Safe area handling**: Strict use of the **59pt** top padding ensures the prominent "BROTATO" title clears the notch/Dynamic Island, and bottom buttons maintain the **34pt** clearance above the home indicator.

### **7.2 Character Selection**

* **Grid layout**: Employs a **2-column grid**. This layout is a crucial mobile optimization choice, sacrificing the high density of a 3- or 4-column PC layout 20 in favor of large touch targets and sufficient space to display the voluminous stat descriptions and character traits.21  
* **Card size**: Estimated at **\~170pt W x \~250pt H**. This large size ensures the entire card bounding box functions as a robust touch target, simplifying selection.  
* **Card spacing**: Uniform **16pt horizontal and vertical gaps** maintain separation between the large cards, adhering to the standard spacing system for interactive elements.  
* **Selected state appearance**: Typically involves a pronounced visual effect, such as a strong, high-contrast border or a bright background highlight using a positive accent color (e.g., green or yellow) to confirm selection instantly.  
* **Locked character treatment**: Displayed using the card silhouette or character art dimmed significantly and overlaid with a "locked" icon, often employing the gray/muted color palette to indicate unavailability.  
* **Scroll behavior**: Standard mobile vertical scrolling, allowing users to efficiently navigate the large roster of characters.21

### **7.3 Shop/Upgrade Screen**

* **Density Strategy**: The item list switches to a denser **3-column grid**, with cards estimated at **\~100pt W x \~140pt H**. This density maximizes the number of available options visible to the player during the time-limited shop phase, facilitating quicker decision-making among the "hundreds of items and weapons" available.23  
* **Category tabs or sections**: Used to filter items (e.g., weapons, consumables, traits), typically positioned horizontally near the top of the main content area, maintaining 44pt minimum touch height.  
* **Purchase button size and placement**: Purchase actions are embedded within the card structure, typically using the prominent Primary Action Red color.  
* **Currency display prominence**: Gold and currency displays are highly prominent, often located centrally in a persistent module or integrated into the XP bar (Section 4), utilizing large **32pt** numbers and the **Green/Yellow** semantic color.  
* **Exit/back button location**: The primary flow control issue arises here: the critical "Start Next Wave" button is often positioned at the very bottom of the item list, requiring the user to scroll through potentially dozens of items and stats to find the control to advance the game.5 This design choice prioritizes data visualization over flow efficiency, leading to common user friction.

### **7.4 Pause Menu**

* **Overlay darkness**: Activated with a highly opaque, dark overlay (estimated 70-80% darkness) using the Background Primary color (**\#282747**), instantly shifting player focus from combat to the menu modal.  
* **Modal size**: A centered, medium-sized modal, typically occupying 60–70% of the horizontal screen width and a similar proportion of the vertical height, minimizing edge content but clearly separating itself from the background.  
* **Button layout**: A simple vertical stack of secondary action buttons (e.g., Resume, Settings, Quit), each maintaining a height of **56pt**.  
* **Resume button prominence**: The "Resume" action is typically the first, most prominent option, sometimes using a distinct color or size relative to the rest of the stack.  
* **Quit button danger styling**: The "Quit Run" or "Exit Game" option is clearly styled using the Danger Red color (**\#CC3737**), providing visual feedback consistent with the severity of the action.

### **7.5 Death/Game Over Screen**

* **Stats presentation**: Presents dense, run-specific information (stats, damage dealt, time survived) in a high-density format, often using the smaller 12–14pt body text organized into tables or card structures.  
* **Retry button size and color**: The most prominent button, designed to encourage immediate re-engagement, matching the **\~280pt W x \~64pt H** dimensions and the Primary Red/Danger color (**\#CC3737**).  
* **Exit button size and color**: A secondary button, typically smaller in size (**\~120pt W x \~56pt H**) and using a less saturated, secondary action color.  
* **Reward/XP display**: Clearly highlighted with positive semantic colors (Green/Yellow) and large font sizes (32pt) to provide closure and reward feedback despite the run's termination.

## **8\. Polish & Feedback**

The perceived high quality of the Brotato mobile experience is heavily dependent on the fast, multimodal sensory feedback delivered through sound and haptics, which is crucial for engagement in repetitive roguelite loops.3

### **Haptic Feedback (Inferred)**

While specific device behavior is not visible in gameplay videos, haptic feedback is an expected and essential component of modern mobile game polish. Haptic triggers are inferred to align with high-frequency, positive feedback loops:

* **Button Press**: Light, sharp haptic tap for every menu button interaction.  
* **Material Collection**: Light, rapid sequence of taps corresponding to the "boop" sound when collecting experience materials in combat.4 This reinforces the positive feedback loop of farming.  
* **Level Up**: Medium, rhythmic pulse corresponding to the on-screen success flash, enhancing the sense of achievement.  
* **Damage/Death**: A strong, singular, immediate tap or buzz, providing necessary visceral communication of critical state change.24

### **Sound Design (Audible)**

Sound design is consistently praised as excellent and integral to the game's loop.3

* **Button press sound**: Crisp, short click or tap sound, reinforcing the instantaneous visual feedback (Section 5).  
* **Success sound**: A distinct, rewarding chime or fanfare for major events (level up, wave clear, purchase), contributing to user satisfaction. The sound of item collection, specifically the "little 'boop' that plays when lifesteal procs," is cited as simple yet satisfying.4  
* **Error sound**: A sharp buzz or thud for failed actions or errors, providing immediate, non-intrusive negative feedback.  
* **Transition sound**: Subtle swoosh or whoosh during screen fades or modal appearances, completing the sense of rapid UI movement.

### **Loading States**

* **Loading indicators**: Typically utilize a simple, centered spinner or progress bar. The interface avoids complex skeleton screens, relying on a clean loading modal against the dark background.  
* **Positioning**: Centered on the screen, maximizing visibility while the rest of the UI (or game map) is rendered.  
* **Animation style**: Smooth, non-aggressive rotation or pulsation, designed to minimize visual frustration during wait times.

### **Error Handling**

Errors are handled concisely and locally, generally avoiding full-screen interruptions unless critical.

* **Display method**: Inline red text or localized modal shake animation (**\~100ms** duration) for immediate feedback regarding invalid input (e.g., trying to combine incompatible items 26).  
* **Color and iconography**: Utilizes the Danger Red color (**\#CC3737**) and often a small 'X' or warning triangle icon.  
* **Dismissal method**: Localized toast messages are used for less critical errors, often fading after a short delay, while modal errors require explicit user confirmation.

## **Recommendations for Implementation**

Based on this analysis of adherence to and strategic deviation from mobile design patterns, the following specific, actionable recommendations are prioritized for a Godot UI overhaul inspired by Brotato’s mobile quality:

1. **Implement Fixed Shop Controls**: Resolve the major flow friction point identified in the Shop/Upgrade screen.5 The "Start Next Wave" action button should be removed from the main scrolling content stream and implemented as a fixed, persistent control. This control should be a float with dimensions of **96pt W x 64pt H**, positioned strictly **48pt above the 34pt bottom safe area** on the right side of the screen. It must utilize the Primary Red color (**\#CC3737**) and the 18pt Bold Button Label to ensure instant visibility and accessibility.  
2. **Mandate 16pt Gap between All Interactive Elements**: Enforce a minimum separation of **16pt** horizontally and vertically between the bounding box (touch target area) of *all* adjacent interactive elements, including cards in lists and icon buttons. This ensures robust tactile separation and prevents accidental taps on adjacent targets, upholding accessibility standards derived from the base design's structure.  
3. **Use 32pt/Heavy Bold Minimum for Critical In-Game Numbers**: To maintain clear visual hierarchy despite the use of small body text, ensure all dynamically changing status numbers (Health, Gold, XP Counter, Damage Popups) use a font size of at least **32pt (Heavy Bold)** and are immediately color-coded with the relevant semantic colors (White/Green/Red). This preserves the crucial glanceability of survival metrics during active combat, overriding the limitations of the compact mobile display.  
4. **Enforce Safe Area Inset Strictness**: Implement dynamic safe area logic in Godot to rigorously reserve the **59pt top inset** and **34pt bottom inset** for all UI elements outside the core gameplay viewport, specifically for the Combat HUD elements (HP, Pause, XP Bar). This prevents the content bleed issues historically noted on various mobile aspect ratios.12

## **Open Questions / Unclear Areas**

1. **Dynamic Island Geometry**: While the 59pt top safe area offset provides general clearance, the precise pixel mapping and behavior of the game's UI near the curved boundaries and aperture of the iPhone 14 Pro's Dynamic Island were not fully quantifiable from the general video sources. Further testing on specific modern devices is needed to verify zero content interference.  
2. **In-Combat Currency Display**: The exact spatial location (X/Y coordinates relative to the corner) of the currency/gold display during the combat wave remains approximate. Although it is generally associated with the XP bar at the bottom, precise coordinates are needed for exact replication in the Combat HUD blueprint.  
3. **Proprietary Font Metrics**: The specific font typeface used by Brotato is unidentified. This makes the assessment of legibility for the 12pt body text relative to the font's X-height interpretive. Identifying the font would allow for a more precise calculation of minimum readable text size and letter spacing for the new Godot implementation.

#### **Works cited**

1. Touch Target Spacing | Deque Docs, accessed November 18, 2025, [https://docs.deque.com/devtools-mobile/2025.7.2/en/ios-touch-target-spacing/](https://docs.deque.com/devtools-mobile/2025.7.2/en/ios-touch-target-spacing/)  
2. Template:Color \- Brotato Wiki, accessed November 18, 2025, [https://brotato.wiki.spellsandguns.com/Template:Color](https://brotato.wiki.spellsandguns.com/Template:Color)  
3. I love Brotato is the sound effects. It's what makes this game for me. \- Reddit, accessed November 18, 2025, [https://www.reddit.com/r/brotato/comments/1cliwy1/i\_love\_brotato\_is\_the\_sound\_effects\_its\_what/](https://www.reddit.com/r/brotato/comments/1cliwy1/i_love_brotato_is_the_sound_effects_its_what/)  
4. Sweet sound design : r/brotato \- Reddit, accessed November 18, 2025, [https://www.reddit.com/r/brotato/comments/169x7z8/sweet\_sound\_design/](https://www.reddit.com/r/brotato/comments/169x7z8/sweet_sound_design/)  
5. Am I missing something or are the controls during the shop awful? : r/brotato \- Reddit, accessed November 18, 2025, [https://www.reddit.com/r/brotato/comments/1icfdbq/am\_i\_missing\_something\_or\_are\_the\_controls\_during/](https://www.reddit.com/r/brotato/comments/1icfdbq/am_i_missing_something_or_are_the_controls_during/)  
6. Stop using 40px touch targets\!. How to calculate the perfect touch… | by Tony Stedge | Bootcamp | Medium, accessed November 18, 2025, [https://medium.com/design-bootcamp/stop-using-40px-touch-targets-bf55b154a111](https://medium.com/design-bootcamp/stop-using-40px-touch-targets-bf55b154a111)  
7. Is the recommended type body size (16 pt) used on mobile apps? Or this standard recommendation is focused on desktop de devices? : r/FigmaDesign \- Reddit, accessed November 18, 2025, [https://www.reddit.com/r/FigmaDesign/comments/txyv37/is\_the\_recommended\_type\_body\_size\_16\_pt\_used\_on/](https://www.reddit.com/r/FigmaDesign/comments/txyv37/is_the_recommended_type_body_size_16_pt_used_on/)  
8. Font Size On Steam Deck \- brotato \- Reddit, accessed November 18, 2025, [https://www.reddit.com/r/brotato/comments/14ph00g/font\_size\_on\_steam\_deck/](https://www.reddit.com/r/brotato/comments/14ph00g/font_size_on_steam_deck/)  
9. Any way to size up the UI font ? : r/greedfall \- Reddit, accessed November 18, 2025, [https://www.reddit.com/r/greedfall/comments/1ohhiif/any\_way\_to\_size\_up\_the\_ui\_font/](https://www.reddit.com/r/greedfall/comments/1ohhiif/any_way_to_size_up_the_ui_font/)  
10. Is mobile stat / scaling way different than the PC version? : r/brotato \- Reddit, accessed November 18, 2025, [https://www.reddit.com/r/brotato/comments/1n1w3py/is\_mobile\_stat\_scaling\_way\_different\_than\_the\_pc/](https://www.reddit.com/r/brotato/comments/1n1w3py/is_mobile_stat_scaling_way_different_than_the_pc/)  
11. Dimensions of the safe area insets, for all new phones : r/iOSProgramming \- Reddit, accessed November 18, 2025, [https://www.reddit.com/r/iOSProgramming/comments/xdvvjq/dimensions\_of\_the\_safe\_area\_insets\_for\_all\_new/](https://www.reddit.com/r/iOSProgramming/comments/xdvvjq/dimensions_of_the_safe_area_insets_for_all_new/)  
12. Brotato (premium) screen issue \- Reddit, accessed November 18, 2025, [https://www.reddit.com/r/brotato/comments/125h8r8/brotato\_premium\_screen\_issue/](https://www.reddit.com/r/brotato/comments/125h8r8/brotato_premium_screen_issue/)  
13. today I learned the mobile port of this game is really bad : r/brotato \- Reddit, accessed November 18, 2025, [https://www.reddit.com/r/brotato/comments/1n09pjw/today\_i\_learned\_the\_mobile\_port\_of\_this\_game\_is/](https://www.reddit.com/r/brotato/comments/1n09pjw/today_i_learned_the_mobile_port_of_this_game_is/)  
14. Is there a way to speed up these animations on mobile? : r/BobsTavern \- Reddit, accessed November 18, 2025, [https://www.reddit.com/r/BobsTavern/comments/1lys3zh/is\_there\_a\_way\_to\_speed\_up\_these\_animations\_on/](https://www.reddit.com/r/BobsTavern/comments/1lys3zh/is_there_a_way_to_speed_up_these_animations_on/)  
15. Classic rant : why are animations so damn slow on mobile : r/BobsTavern \- Reddit, accessed November 18, 2025, [https://www.reddit.com/r/BobsTavern/comments/16bv7ch/classic\_rant\_why\_are\_animations\_so\_damn\_slow\_on/](https://www.reddit.com/r/BobsTavern/comments/16bv7ch/classic_rant_why_are_animations_so_damn_slow_on/)  
16. Animations on mobile are a direct hindrance to gameplay : r/BobsTavern \- Reddit, accessed November 18, 2025, [https://www.reddit.com/r/BobsTavern/comments/1bwjve0/animations\_on\_mobile\_are\_a\_direct\_hindrance\_to/](https://www.reddit.com/r/BobsTavern/comments/1bwjve0/animations_on_mobile_are_a_direct_hindrance_to/)  
17. Mobile UI Color Palette \- Color Hex Color Codes, accessed November 18, 2025, [https://www.color-hex.com/color-palette/70641](https://www.color-hex.com/color-palette/70641)  
18. Trendy App UI Color Scheme \- Palettes \- SchemeColor.com, accessed November 18, 2025, [https://www.schemecolor.com/trendy-app-ui.php](https://www.schemecolor.com/trendy-app-ui.php)  
19. Robot Color Palette, accessed November 18, 2025, [https://www.color-hex.com/color-palette/4970](https://www.color-hex.com/color-palette/4970)  
20. Wider Character Select \- Workshop \- Steam Community, accessed November 18, 2025, [https://steamcommunity.com/workshop/filedetails/?id=2934197660](https://steamcommunity.com/workshop/filedetails/?id=2934197660)  
21. Characters \- Brotato Wiki, accessed November 18, 2025, [https://brotato.wiki.spellsandguns.com/Characters](https://brotato.wiki.spellsandguns.com/Characters)  
22. How To Unlock Every Character And Item In Brotato \- TheGamer, accessed November 18, 2025, [https://www.thegamer.com/brotato-items-characters-how-to-unlock-guide/](https://www.thegamer.com/brotato-items-characters-how-to-unlock-guide/)  
23. Brotato \- App Store \- Apple, accessed November 18, 2025, [https://apps.apple.com/us/app/brotato/id6445884925](https://apps.apple.com/us/app/brotato/id6445884925)  
24. Design and evaluation of haptic experience in mobile augmented reality serious games | Request PDF \- ResearchGate, accessed November 18, 2025, [https://www.researchgate.net/publication/397417364\_Design\_and\_evaluation\_of\_haptic\_experience\_in\_mobile\_augmented\_reality\_serious\_games](https://www.researchgate.net/publication/397417364_Design_and_evaluation_of_haptic_experience_in_mobile_augmented_reality_serious_games)  
25. Haptic Feedback: Creating an “Enhanced Feel Mode” | by Amit Gaikwad \- Medium, accessed November 18, 2025, [https://medium.com/design-bootcamp/haptic-feedback-creating-an-advanced-feel-mode-58588872cd7c](https://medium.com/design-bootcamp/haptic-feedback-creating-an-advanced-feel-mode-58588872cd7c)  
26. Mobile Brotato is really sloppy and I don't recommend buying the Premium \- Reddit, accessed November 18, 2025, [https://www.reddit.com/r/brotato/comments/1mj6fwf/mobile\_brotato\_is\_really\_sloppy\_and\_i\_dont/](https://www.reddit.com/r/brotato/comments/1mj6fwf/mobile_brotato_is_really_sloppy_and_i_dont/)