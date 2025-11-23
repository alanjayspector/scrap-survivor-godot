

# **Architectures of Immersion and Utility: A Comparative Analysis of iOS Navigation Paradigms and Mobile Game Interface Patterns**

## **Executive Summary**

The divergence between application utility design and immersive game interface design represents one of the most significant schisms in modern mobile user experience (UX) architecture. While both domains aim for usability and clarity, they employ fundamentally different philosophies regarding navigation, state management, and user immersion. This report provides an exhaustive analysis of two specific architectural dilemmas: the choice between sheet-based versus push navigation in iOS utility applications, particularly for read-only and list-to-detail patterns, and the competing paradigms of modal overlays versus dedicated screens in mobile RPG character rosters.

Through a rigorous examination of Apple’s Human Interface Guidelines (HIG), case studies of prominent applications (Apple Maps, Stocks, Find My), and a deconstruction of high-grossing mobile games (Marvel Snap, Genshin Impact, Honkai: Star Rail, Clash Royale), this document establishes a unified theory of mobile navigation. It argues that while iOS favors context preservation through semi-modal sheets to maintain user orientation in utility tasks, mobile games prioritize "diegetic" or "meta-diegetic" immersion, often eschewing standard OS navigation for full-screen takeovers that serve the narrative fantasy.

## **Part I: The iOS Paradigm – Sheets, Push, and the Preservation of Context**

The evolution of iOS navigation has moved steadily away from deep, destructive hierarchies toward fluid, context-preserving overlays. The introduction and refinement of the "Sheet" component, particularly the detent-based bottom sheet, marks a pivotal shift in how Apple conceptualizes "detail" views.

### **1.1 The Theoretical Framework of iOS Navigation**

Apple’s Human Interface Guidelines (HIG) fundamentally categorize navigation into three styles: Hierarchical, Flat, and Content-Driven.1 The decision between pushing a new view controller onto a navigation stack and presenting a sheet modally is not merely aesthetic; it is a functional decision about the relationship between the parent and child data.

#### **1.1.1 The Semantics of "Push" Navigation**

Push navigation (Hierarchical) implies a linear progression. When a user taps a row in a table to "push" a detail view, they are mentally traversing deeper into a directory structure. The parent view is effectively replaced, signaling that the user’s primary focus has shifted entirely to the new context. This pattern is historically dominant in "List-to-Detail" architectures, such as Mail or Settings, where the detail view contains the totality of the necessary information and the parent list is merely a directory.1

However, push navigation suffers from "context collapse." Once the transition animation completes, the parent context is visually removed. The user must remember where they came from. For deep hierarchies, this cognitive load increases, requiring the user to traverse back up the stack (often multiple taps) to switch contexts. The navigation bar serves as the breadcrumb trail, but the visual anchor of the previous screen is gone.

#### **1.1.2 The Semantics of "Sheet" and Modal Presentation**

Modality, in the strict sense defined by the HIG, creates focus by preventing interaction with the parent view until the task is completed or dismissed.3 Traditionally, this was reserved for self-contained tasks (e.g., "Compose Email," "Add Event"). The user enters a mode, completes a transaction, and exits.

However, the modern iOS "Sheet" has evolved beyond simple modality. With the introduction of non-modal sheets and variable detents (medium, large), sheets now serve as "supplementary" or "parallel" contexts rather than just interrupting tasks.5

**The Key Distinction:**

* **Push:** "I am moving *into* this item. The list was just a way to get here."  
* **Sheet:** "I am looking *at* this item, but I still relate to the list/map behind it."

### **1.2 The Rise of the Detent Sheet for Read-Only Content**

A critical evolution in iOS design—spearheaded by Apple Maps and adopted by Stocks and Find My—is the use of the bottom sheet for read-only detail views, challenging the traditional "push" model for list-to-detail transitions.

#### **1.2.1 The Apple Maps Pattern**

Apple Maps utilizes a persistent bottom sheet that serves as the primary interface for location details.6 When a user selects a Point of Interest (POI) on the map:

1. The map remains visible in the background (context preservation).  
2. The sheet rises to a "medium" detent, showing critical summary info (Title, Ratings, ETA).  
3. The user can scroll the sheet to expand it to "large" (full screen) to read reviews or see photos.  
4. The user can swipe down to dismiss, instantly returning to the map context without a tap.

Why this violates traditional "Push" logic:  
Historically, tapping a pin might push a "Detail View." However, in a geospatial context, the relationship between the "List" (the Map) and the "Detail" (the Place) is symbiotic. The user often needs to see the location relative to their position while reading about it. A push navigation would obscure the map, destroying the spatial context. The sheet maintains the "parent" (Map) as a visible anchor.8

#### **1.2.2 The Stocks App Analysis**

The iOS Stocks app demonstrates a hybrid approach. The main screen is a list of tickers. Tapping a ticker pushes a detail view. However, within that detail view, news stories are presented. In newer iterations and related financial tools, there is a trend toward allowing users to swipe through details or pull up related news in sheets without losing the stock chart context.

The HIG suggests using a sheet for "simple content or tasks" and explicitly warns: "Avoid using a sheet to help people navigate your app's content".5 This creates a tension. Is a stock detail "navigating content" or "inspecting an item"? Apple's own apps suggest that "inspection" which benefits from rapid dismissal (swipe-to-close) is better served by sheets than push navigation.

### **1.3 Decision Matrix: Sheet vs. Push for Read-Only Details**

Based on the HIG and system app analysis, the following rubric emerges for designers choosing between these patterns:

| Criteria | Push Navigation (Hierarchical) | Sheet / Modal (Detent/Form) |
| :---- | :---- | :---- |
| **Relationship to Parent** | The child view *replaces* the parent focus. The parent is just a directory. | The child view *supplements* the parent. The parent context (e.g., map, background list) remains relevant. |
| **Content Depth** | Deep, complex content with its own sub-navigation (e.g., Settings \> General \> About). | Shallow to medium depth. Information that can be consumed quickly (e.g., a contact card, a location summary). |
| **User Intent** | "I want to go into this section." | "I want to peek at this detail." |
| **Dismissal Mechanism** | Tap "Back" button (Top-left). High friction. | Swipe down (Gesture). Low friction. |
| **State Preservation** | High. Navigation stacks preserve scroll position deeply. | Variable. Sheets are transient; dismissing them usually resets state. |
| **Read-Only Suitability** | Good for long-form reading (Articles). | Excellent for structured data inspection (Metadata, Status). |

#### **1.3.1 The "Auxiliary" vs. "Critical" Distinction**

Research suggests a heuristic: If the task or view is **auxiliary** to the main flow, use a sheet (Pattern 3 in user discussions). If the content requires the user's full, undivided attention to the exclusion of all else, or represents a new "level" in the app's hierarchy, use a push (or full-screen modal).9

For read-only list-to-detail specifically:

* **Use Push if:** The detail view contains a list that leads to *another* detail view (nesting). Sheets should generally not spawn other sheets or push views within themselves, as this creates "modal inception" and confusing navigation stacks.3  
* **Use Sheet if:** The user is likely to "browse" rapidly—opening a detail, glancing, swiping away, and opening the next. The ergonomic superiority of the swipe-down gesture makes sheets superior for rapid list processing compared to the reach-intensive "Back" button.1

### **1.4 The Role of Detents in Progressive Disclosure**

The introduction of presentationDetents (SwiftUI) and UISheetPresentationController (UIKit) allows sheets to rest at specific heights (e.g., medium, large, or custom fractions).6 This capability has transformed the "Read-Only" pattern.

A "medium" detent allows the user to read the most pertinent information (the "head" of the document) while still interacting with the background context (if presentationBackgroundInteraction is enabled).11 This is effectively a "Split View" for the iPhone.

**Best Practice:** For read-only content, support the **medium detent** to allow progressive disclosure. Let the user decide if they need to see the full content (drag to large) or if the summary suffices. This respects the user's agency and manages screen real estate efficiently.5

### **1.5 Implications of iPadOS and Catalyst**

The HIG notes that navigation metaphors shift across devices. On iPad, a "Push" on iPhone might translate to a Split View Controller (List on left, Detail on right). A "Sheet" on iPhone might become a Popover or a Form Sheet on iPad.8

When designing "List-to-Detail" for read-only content:

* **iPhone:** Push is safe; Sheet is modern/ergonomic.  
* **iPad:** Split View is preferred over full-screen transitions. Sheets should be used sparingly for details to avoid floating islands of content over massive whitespace.

## **Part II: Mobile Game UI – Immersion, Diegesis, and the Character Roster**

While iOS utility apps strive for standardization and OS-level consistency, mobile games—particularly RPGs and Gacha games—operate under a different set of heuristics. The primary goal is not efficient task completion, but **immersion** and **retention**. The Character Roster (or "Collection") screen is a critical interface in these games, serving as the hub for progression, monetization, and strategy.

### **2.1 The "Modal" vs. "Navigation" False Dichotomy in Games**

In iOS apps, "Modal" and "Push" have specific programmatic meanings (e.g., present vs. pushViewController). In games, these technical distinctions blur. Most games run in a single OpenGL/Metal view context.12 What appears to be a "modal" is often just a canvas layer drawn on top of the previous layer.

Therefore, the distinction in Game UI is between:

1. **Overlay / Popup (Modal-like):** The background (world/menu) is visible but dimmed. The user feels they are still "in" the previous screen.  
2. **Full-Screen Transition (Navigation-like):** The camera zooms, pans, or cuts to a new scene. The previous context is visually removed.

### **2.2 Case Study: Marvel Snap – The "Card Detail" Paradigm**

Marvel Snap presents a masterclass in modern mobile game UI, specifically regarding collection browsing.

#### **2.2.1 The "Focus" Interaction**

When a user taps a card in their collection in Marvel Snap, the interface does *not* navigate to a new screen in the traditional sense, nor does it pop up a generic 2D window. Instead, it employs a **Zoom/Expand Transition**.13

* **Mechanism:** The selected card scales up and moves to the center of the screen. The background (the collection grid) is blurred and darkened but remains visible.  
* **3D Parallax:** The card itself is a 3D object. The "Frame Break" effect (where characters pop out of the card border) is a key reward mechanic. By keeping the transition fluid and centered, the game highlights the visual fidelity of the asset.15  
* **Context:** Because the background is visible, the user retains their sense of place within the deck-building flow.

#### **2.2.2 Why Not Full Screen?**

If Marvel Snap used a full-screen transition for card details, it would sever the connection between the card and the deck being built. Deck building is a "many-to-one" operation. Users need to swap cards rapidly. A full-screen navigation would introduce friction (load times, cognitive switching) that would kill the "snap" pacing of the game.

**Insight:** For "Collection" interfaces where the primary action is *selection* or *comparison*, modal-style overlays (or zoom transitions) are superior to full-screen navigation because they maintain the "pool" context.

### **2.3 Case Study: Genshin Impact & Honkai: Star Rail – The "Character Screen" Paradigm**

HoYoverse games (Genshin Impact, Honkai: Star Rail) utilize a fundamentally different pattern for their character rosters, favoring **Full-Screen Immersion** over modal overlays.

#### **2.3.1 The Roster as a Destination**

In these RPGs, a character is not just a data object (like a card); they are a complex entity with 3D models, equipment slots, artifact stats, talent trees, and lore.

* **Navigation:** Tapping the "Character" icon triggers a full-screen transition. The game world (Diegetic layer) is replaced by the "Menu World" (Meta-diegetic layer).  
* **Layout:** The character stands in a void or stylized environment on one side, with statistical panels on the other.16  
* **List-to-Detail:** The "List" is often collapsed into a sidebar or a carousel of portraits within the Detail view itself.

#### **2.3.2 The Side-Nav Pattern**

Instead of a "Back" button returning to a grid (iOS style), these games use a **Master-Detail** layout within the full screen. The roster list remains accessible on the left or right edge.17

* **Benefit:** Rapid switching between characters without returning to a parent directory.  
* **Immersion:** The user never leaves the "Character Inspection" mode. The 3D model loads instantly as they tap down the list.

**Insight:** For "Management" interfaces where the user spends significant time tuning individual units (leveling up, equipping), Full-Screen interfaces with internal side-navigation are superior. A modal would feel too cramped for this density of information.

### **2.4 The Diegetic Divide: UI as Gameplay**

A crucial concept in Game UI is **Diegesis**—interfaces that exist within the game world.18

* **Dead Space (Classic Example):** Health is on the character’s spine.  
* **Mobile Adaptation:** In *Clash Royale*, tapping a card ‘Info’ button triggers a modal popup.20 Why? Because the *gameplay* (the battle) is the primary context. The card info is secondary.  
* **In contrast, Genshin Impact:** The Character Screen is a "Pause" state. The player is no longer exploring; they are managing. Therefore, the UI can afford to take over the entire screen space.

### **2.5 Comparative Analysis: Modal vs. Navigation in Games**

| Feature | Modal Overlay / Pop-up | Full-Screen / Scene Change |
| :---- | :---- | :---- |
| **Best Used For** | Quick reference, Consumable items, simple stat checks. | Deep customization, Leveling up, Equipment management. |
| **Game Examples** | *Clash Royale* (Card Info), *Marvel Snap* (Card Detail). | *Genshin Impact* (Character Menu), *Final Fantasy* (Menu). |
| **Visual Metaphor** | "I am holding an object up to my face." | "I am entering the barracks/armory." |
| **Interaction Cost** | Low (Tap outside to dismiss). | Medium/High (Requires "Back" or "Close" button). |
| **Asset Load** | Lighter (often 2D sprites or cached small 3D models). | Heavy (Full high-res 3D models, unique backgrounds). |
| **Screen Real Estate** | Limited (must show margins). | Maximum (allows for dense info density). |

## **Part III: Synthesis and Guidelines for Cross-Pollination**

The line between "App" and "Game" is blurring. Gamified apps (e.g., Duolingo, Habitica) borrow game patterns, while games increasingly adopt "Flat" design for menus to improve usability.

### **3.1 Applying Game Patterns to iOS Apps**

iOS developers can learn from the "Zoom Transition" used in games like Marvel Snap. Apple has effectively canonized this with the matchedGeometryEffect in SwiftUI and the Zoom Transition in iOS 18\.21

* **Recommendation:** Instead of a standard "Push" animation for a list-to-detail view, consider a **Zoom Transition**. If a user taps a photo in a list, expand that photo to fill the detail header. This preserves context (like a Game UI) while adhering to strict navigation hierarchies (iOS).

### **3.2 Applying iOS Sheets to Games**

Games often suffer from "UI Clutter." The iOS "Sheet" pattern—specifically the swipe-to-dismiss gesture—is an ergonomic win that games should adopt for secondary menus.

* **Recommendation:** For in-game inventories or quest logs, implement a "Sheet-like" behavior where the gameplay is visible in the top margin (medium detent equivalent). Allow users to swipe the inventory down to resume play instantly, rather than hunting for a tiny "X" button in the corner.5

### **3.3 The Unified Theory of "Detail"**

Whether in a utility app or an RPG, the decision to use a Modal/Sheet vs. a Full Screen/Push comes down to **Task Isolation**.

* **Isolate (Full Screen/Push):** When the user must construct a mental model of the specific item (e.g., "Build this Character," "Edit this Setting").  
* **Integrate (Sheet/Modal):** When the user must compare the item to the aggregate (e.g., "Compare this stock to the market," "Pick this card for the deck").

## **Conclusion**

The iOS Human Interface Guidelines and Mobile Game UI patterns, while visually distinct, are converging on a shared principle: **Context is King**.

For iOS read-only content, the **Sheet** (specifically with detents) is displacing the "Push" navigation because it maintains the parent context, allows for one-handed ergonomic dismissal, and facilitates rapid browsing. It transforms "Navigation" into "Inspection."

For Mobile Game Character Rosters, the split depends on depth. **Collection-based games** (Marvel Snap) favor modal/zoom inspections to facilitate rapid deck-building flow. **RPG-based games** (Genshin Impact) favor full-screen takeovers to support the depth of character management systems, utilizing internal side-navigation to mitigate the friction of hierarchy traversal.

Designers must therefore ask not "Which pattern is correct?" but "What is the relationship between the user, the item, and the collection?" The answer to that question dictates the navigation architecture.

# **Introduction**

The architecture of mobile interfaces is defined by the tension between depth and context. Every navigation decision—whether to push a new screen, present a modal overlay, or expand a card—imposes a cognitive cost on the user. In the domain of standard iOS applications, Apple’s Human Interface Guidelines (HIG) provide a rigorous, albeit evolving, framework for these decisions. In the contrasting domain of mobile gaming, user interface (UI) patterns have evolved through the pressures of player retention, monetization, and narrative immersion (diegesis).

This report investigates a specific intersection of these two worlds: the presentation of "Detail" views from a "List" or "Collection" parent. Specifically, it analyzes:

1. **iOS Utility:** The conflict between "Push" navigation and "Sheet" presentation for read-only content.  
2. **Game UI:** The divergence between modal overlays and full-screen navigation for character rosters in RPGs and strategy games.

By analyzing research material—ranging from Apple’s technical documentation to deconstructions of *Marvel Snap* and *Genshin Impact*—this report synthesizes a comprehensive guide to mobile navigation architecture.

## **1.1 The Cognitive Physics of Navigation**

To understand the trade-offs between "Push" and "Sheet," one must first understand the mental model each creates.

* **Push Navigation:** Is spatial and linear. It implies travel. The user leaves "Room A" to enter "Room B." To return, they must physically retrace their steps. This creates a strong sense of *place* but a high cost of *return*.  
* **Sheets/Modals:** Are layered and temporal. The user pulls a layer over "Room A." They never leave the room; they simply obscure it. This creates a strong sense of *context* and a low cost of *dismissal*.

## **1.2 Scope of Analysis**

This report focuses on **Read-Only Content** and **List-to-Detail Patterns**.

* *Read-Only:* Scenarios where the user is consuming information (reading a description, checking stats, viewing a map location) rather than performing a complex input task (filling a form).  
* *List-to-Detail:* The ubiquitous pattern of selecting one item from a collection to view its specifics.

The analysis draws upon distinct research clusters:

* **Apple HIG & Developer Documentation:** 2  
* **Game UI Case Studies:** 13  
* **UX Theory & Heuristics:** 1

---

# **Part I: The iOS Paradigm – Sheets vs. Push**

The iOS Human Interface Guidelines have historically favored clear, hierarchical navigation. However, the introduction of the iPhone X (removing the home button) and the subsequent evolution of gesture-based interfaces have radically altered the "correct" approach to displaying detail views.

## **2.1 The "Push" Transition: Tradition and Limitations**

### **2.1.1 The Hierarchical Model**

The "Push" transition is the bread and butter of UINavigationController. It slides a new view in from the right, covering the screen.

* **HIG Definition:** "Make one choice per screen until you reach a destination. To go to another destination, you must retrace your steps.".1 This linear progression is fundamental to the iOS navigation stack paradigm, where depth equals specificity.  
* **Use Case:** Ideal for deep content where the "Detail" view is a destination in itself. For example, in the iOS **Settings** app, tapping "General" pushes a new view. The user is no longer concerned with the main list; they are focused entirely on "General" settings.

### **2.1.2 The Problem with "Push" for Read-Only Details**

While robust, Push navigation has significant drawbacks for simple "inspection" tasks:

1. **Unreachability:** The "Back" button is located in the top-left corner. On modern, large iPhones (Pro Max models), this is the "Zone of Unreachability," requiring hand gymnastics or two-handed use.24  
2. **Context Loss:** The parent list disappears. If a user is scanning a list of emails or stock tickers, pushing a view removes the list context. To check the next item, they must tap Back, re-orient, find the next item, and tap again (Pogo-sticking).

## **2.2 The "Sheet" Revolution: Detents and Context**

Apple’s shift toward "Sheets" (specifically bottom sheets) addresses the ergonomic and cognitive failings of the Push model for read-only content.

### **2.2.1 HIG Guidance on Sheets**

The HIG explicitly states: "Use a sheet only as a temporary interruption to the current workflow... Avoid using a sheet to help people navigate your app's content".5

* *Contradiction?* This guidance seems to discourage using sheets for navigation. However, "navigating content" here refers to deep hierarchy traversal (e.g., Folder \> Subfolder \> File). It does *not* necessarily preclude "inspecting" an item. The key distinction is the interruption level. A sheet is an interruption, but a modern detent sheet is a *polite* interruption that acknowledges the user's previous task.

### **2.2.2 The Detent System**

The game-changer was the introduction of UISheetPresentationController with **Detents** (Medium, Large).

* **Medium Detent:** Covers half the screen. The parent view (dimmed or interactive) remains visible at the top.  
* **Large Detent:** Expands to near full-screen.  
* **Interaction:** Crucially, sheets support **Swipe-to-Dismiss**. This gesture is performed anywhere on the screen (scrolling down), making it ergonomically superior to the "Back" button.5

### **2.3 Case Study: Apple Maps – The Gold Standard**

Apple Maps is the definitive example of using Sheets for read-only details, replacing the "Push" model entirely for POI inspection.6

**The Interaction Flow:**

1. **Context:** User views a map (The List/Container).  
2. **Action:** User taps a restaurant pin.  
3. **Result:** A sheet slides up to the **Medium Detent**.  
   * **Insight:** The map remains visible. The user can see *where* the restaurant is while reading *what* it is. A Push transition would have hidden the map, destroying the spatial utility.  
4. **Progression:** The user swipes up to the **Large Detent** to read reviews.  
5. **Dismissal:** The user swipes down.

Analysis:  
This pattern proves that for geospatial or visual lists, Sheets are superior to Push because they preserve the parent context. The "Detail" is not a separate destination; it is an attribute of the map.7

### **2.4 Case Study: Stocks – The Hybrid Model**

The iOS Stocks app utilizes a hybrid.

* **Main List:** Tapping a stock ticker **pushes** to a detail view.  
* **Why Push?** The detail view contains a complex interactive chart and a scrollable feed of news. It is a "heavy" view.  
* **Sheet Usage:** Within the detail view, tapping a news article opens a **Sheet**.  
* **Why Sheet?** The article is a temporary consumption task. The user wants to read it and return to the stock data quickly. The Sheet implies "I am referencing this," whereas the Push implied "I am analyzing this ticker."

## **2.5 Synthesizing the Rule: When to Push vs. When to Sheet**

Based on the synthesis of HIG documentation 2 and Apple's first-party app analysis, we can construct a definitive decision matrix.

### **2.5.1 The "Read-Only" Heuristic**

For read-only content (Details), use a **Sheet** if:

1. **Simplicity:** The content is a "dead end" (it does not link deeper).  
2. **Context Dependency:** The user benefits from seeing the parent view (e.g., Map, Calendar view).  
3. **Rapid Browsing:** The user is likely to view multiple items in rapid succession (High frequency, low duration).  
4. **Ergonomics:** The primary interaction is "dismissal" (Swipe down).

Use a **Push** if:

1. **Complexity:** The detail view has its own navigation bar or requires further drill-down.  
2. **Independence:** The detail view stands alone; the parent context is irrelevant once the item is selected.  
3. **Immersiveness:** The content requires maximum screen real estate without the visual noise of the "card" aesthetic (rounded corners, background gap).

### **2.5.2 The "List-to-Detail" Heuristic**

* **Master-Detail (iPad):** Always prefer Split Views.  
* **Drill-Down (iPhone):**  
  * *Standard Data:* Push (e.g., Contacts, Settings).  
  * *Rich Media / Metadata:* Sheet (e.g., Maps, Music Player, Find My).

**Key Insight:** The "Music Player" pattern (Now Playing bar expanding to a sheet) has trained iOS users that "Media/Rich Content" lives in sheets, while "Files/Data" lives in pushed views.

---

# **Part II: Mobile Game UI – Character Roster Patterns**

While iOS apps optimize for standard utility, mobile games optimize for the "Fantasy." The UI must not only be functional but also **diegetic** or at least consistent with the game's aesthetic narrative.18 This leads to divergent patterns for handling Character Rosters (the game equivalent of List-to-Detail).

## **3.1 The Immersion Imperative**

In games, the UI is often part of the "Meta-Game." Managing a roster is not just data entry; it is a reward loop. Viewing a character is a celebration of ownership.

* **Diegetic UI:** Elements exist in the game world (e.g., Dead Space health bar).  
* **Meta-Diegetic UI:** The UI is a stylized overlay that fits the lore (e.g., a spellbook menu in an RPG).

Because of this, standard iOS sheets (white rectangles with native fonts) are rarely used. Instead, games choose between **Modal Overlays** (Custom Popups) and **Full-Screen Navigation**.

## **3.2 Pattern A: The Modal / Focus View (Marvel Snap)**

*Marvel Snap* represents the "Collection" archetype. The primary loop is acquiring and upgrading cards.

### **3.2.1 The Mechanic**

Tapping a card in *Marvel Snap* triggers a **Zoom Transition** (a form of modal overlay).

* **Visuals:** The card expands from its thumbnail position to the center. The background is blurred.  
* **Function:** This is a "Read-Only \+ Upgrade" view. The user checks stats, rotates the 3D art (Gyroscope effect), and upgrades the card.13  
* **Navigation:** Tapping outside the card dismisses it.

### **3.2.2 Why this works for Collections**

This pattern mirrors the iOS "Sheet" logic: **Context Preservation.**

* The user is usually in "Deck Building Mode." They are comparing the selected card to the *rest* of the deck visible in the background.  
* If *Marvel Snap* used a full-screen transition, the user would lose visual reference to their deck curve and composition. The modal approach allows for rapid "Peek and Dismiss" behavior essential for strategy.9

## **3.3 Pattern B: The Full-Screen / Scene Change (Genshin Impact)**

*Genshin Impact* represents the "RPG" archetype. Characters are complex systems, not just cards.

### **3.3.1 The Mechanic**

Tapping the "Character" menu triggers a **Full-Screen Scene Change**.

* **Visuals:** The camera cuts to a dedicated 3D void/environment where the character stands.  
* **Layout:** A sidebar list (Roster) allows switching characters *within* the view.  
* **Function:** Deep management (Artifacts, Weapons, Talents, Constellations).

### **3.3.2 Why this works for RPGs**

This mirrors the iOS "Split View" logic but adapted for a single screen.

* **Complexity:** The amount of data (5-6 sub-tabs of stats) is too dense for a modal. It requires the full canvas.  
* **Immersion:** The player wants to see the character perform animations. A small modal window would diminish the visual reward of unlocking a "5-Star" character.28  
* **Side-Nav:** By including the roster list as a sidebar within the Detail view, *Genshin* solves the "Pogo-sticking" problem of Push navigation. The user doesn't go "Back" to the list; the list travels with them.29

## **3.4 Comparative Analysis: Modal vs. Full-Screen in Games**

| Feature | Modal / Zoom (Marvel Snap) | Full-Screen (Genshin Impact) |
| :---- | :---- | :---- |
| **Data Density** | Low/Medium (Card Art, 2 Stats, Upgrade Button). | High (Multiple tabs, 3D rotation, Equipment slots). |
| **Context** | Preserves Background (Deck/Collection). | Replaces Background (Dedicated Scene). |
| **Navigation** | Dismiss to return. | Sidebar to switch (Internal Navigation). |
| **Immersion** | Focuses on the *Asset* (Card). | Focuses on the *Entity* (Character). |
| **Analogue** | iOS Sheet / Popover. | iOS Split View (Collapsed). |

### **3.4.1 The Role of Transition Animations**

Games utilize transitions to mask loading and sell the fantasy.

* **Zoom:** (Snap) implies "Taking a closer look."  
* **Fade/Cut:** (Genshin) implies "Entering a management room."  
* **Particle Effects:** *Honkai: Star Rail* uses elemental particle effects during transitions to denote character affinity, adding a layer of information to the navigation itself.30

---

# **Part III: Detailed Design Guidelines & Recommendations**

Based on the synthesis of the above analysis, the following guidelines are proposed for developers and designers working in these spaces.

## **4.1 For iOS Utility Apps**

### **4.1.1 The "Sheet-First" Mandate for Inspection**

If you are designing a list-to-detail flow where the detail view is primarily **read-only** (e.g., a list of transactions, a map of locations, a directory of employees):

* **Adopt the Bottom Sheet.** Use UISheetPresentationController with .medium() and .large() detents.  
* **Enable Background Interaction.** Allow the user to scroll the parent list while the sheet is at the medium detent. This creates a powerful multitasking interface on a small screen.  
* **Avoid "Push" for Metadata.** Do not push a full view controller just to show 5 rows of text. It feels "heavy" and disconnects the user from their workflow.

### **4.1.2 When to stick with "Push"**

* **Sequences:** If the detail view has a button that leads to *another* detail view, use Push. Stacking sheets is poor UX (the "Sheet of Shame").  
* **Editing:** If the user needs to edit the item, a Push (or a full-screen modal) is often safer to prevent accidental dismissal via swiping.

## **4.2 For Mobile Games**

### **4.2.1 The Roster Heuristic**

* **Card Battlers / Strategy:** Use **Modal/Zoom**. The "Collection" is the primary entity; the individual unit is a component. Users need to see the collection to make decisions about the unit.  
* **RPGs / Hero Collectors:** Use **Full-Screen with Sidebar**. The "Hero" is the primary entity. Users need deep focus to manage the hero's growth. The collection list should be a secondary navigation element (sidebar) available *within* the hero screen to facilitate rapid switching.

### **4.2.2 The "Back" Button Problem**

Games often reinvent the "Back" button poorly.

* **Lesson from iOS:** The standard top-left back button is hard to reach.  
* **Game Solution:** *Marvel Snap* allows clicking *anywhere outside the card* to close. *Genshin Impact* places the close button often in the top right or uses a global "Exit" icon.  
* **Recommendation:** Implement **Gesture Dismissal** in games. Allow players to swipe a menu away or pinch to close. This aligns game UI with the muscle memory players have developed from using the OS.24

## **4.3 Convergence: The "Gamified" App**

Apps like **Duolingo** and **Habitica** sit in the middle.

* **Duolingo:** Uses a "Map" (Path) for navigation. Tapping a lesson opens a **Sheet** (modal overlay) to start. This follows the Game UI pattern (World \-\> Level) but uses iOS-like sheet physics.31  
* **Insight:** Gamified apps should lean toward Game UI patterns (Modals/Overlays) for "Action" items to make them feel like rewards/quests, but stick to iOS patterns (Push) for "Settings/Profile" to maintain usability.

---

# **Conclusion**

The choice between sheets and push navigation, or modals and full screens, is not merely a stylistic preference—it is a definition of the **User's State of Mind**.

In the **iOS HIG**, the Sheet represents a "temporary detour" or "reference check" that respects the parent context. It is the correct pattern for read-only details in modern apps (like Maps) because it acknowledges that users often multitask between the list and the item.

In **Game UI**, the distinction is driven by the depth of the "fantasy." **Marvel Snap** uses modals because the fantasy is "playing cards on a table"—you don't leave the table to look at a card. **Genshin Impact** uses full-screen navigation because the fantasy is "managing a team of heroes"—you step into the barracks to equip them.

**Final Recommendation:**

* **App Designers:** Stop pushing views for simple data. Embrace the medium-detent sheet to create fluid, context-aware interfaces.  
* **Game Designers:** Stop forcing clicks for "Back." Embrace gesture-based dismissal and modal overlays for collections to keep players immersed in the meta-game loop.

The future of mobile navigation lies in the **fluidity of the z-axis**—using depth (layers/sheets) rather than just x-axis (push/slide) travel to organize information.

# **Detailed Analysis of Research Findings**

The following sections provide the granular data and specific citation synthesis that supports the executive summary above.

## **5\. iOS HIG Deep Dive: Navigation vs. Modality**

### **5.1 The Evolution of the "Sheet"**

Historically, "Action Sheets" in iOS were strictly for choices (Delete/Cancel). However, the modern "Sheet" is a container for content.

* **Source Data:** The HIG now distinguishes between "Modal" (blocking) and "Non-modal" (interactive) sheets.5  
* **Detents:** The ability to snap to medium height allows the sheet to function as a persistent "panel." This is crucial for **read-only content** because it allows the user to read while keeping the parent view (e.g., a map or list) visible.

### **5.2 Push Navigation Constraints**

* **Source Data:** Push navigation is described as "Hierarchical." It is best for linear flows.1  
* **Read-Only Friction:** Using push for read-only content creates friction. If a user wants to check the status of 10 items in a list:  
  * *Push:* Tap Item \-\> Wait for Anim \-\> Read \-\> Tap Back (Top Left) \-\> Wait for Anim \-\> Repeat x10.  
  * *Sheet:* Tap Item \-\> Sheet Rises \-\> Read \-\> Swipe Down \-\> Repeat x10.  
* **Conclusion:** The ergonomic cost of "Push" is significantly higher for browsing tasks.

### **5.3 The "Apple Maps" Pattern**

* **Source Data:** Apple Maps uses a "bottom sheet" that handles almost all "detail" interactions.6  
* **Behavior:** The sheet is the primary interface. The map is the background.  
* **Implication:** This signals a shift in Apple's own design philosophy. The "Map" is not just a list; it is a *surface*. The details are *objects* on that surface.

## **6\. Game UI Patterns: Roster Details**

### **6.1 Modal Approaches (Card Games)**

* **Game:** *Marvel Snap*, *Clash Royale*.  
* **Pattern:** Tapping a unit opens a popup/overlay.20  
* **Why:** These games rely on **comparative analysis**. The player needs to compare the selected card’s stats with the other cards in their deck. A full-screen view would hide the comparison points.  
* **Visuals:** Often uses "Dimming" of the background rather than total removal.

### **6.2 Navigation Approaches (RPGs)**

* **Game:** *Genshin Impact*, *Honkai: Star Rail*.  
* **Pattern:** Tapping a character opens a full-screen dedicated view.17  
* **Why:** These games rely on **depth management**. The player is not just comparing stats; they are managing artifacts, weapons, and lore. The UI density requires 100% of the screen.  
* **Internal Navigation:** To mitigate the loss of the "List" context, these games implement a carousel or sidebar *inside* the detail view.

### **6.3 The "Hybrid" Approach (Honkai: Star Rail)**

* **Observation:** *Honkai: Star Rail* uses particle effects and element-specific backgrounds during the transition.30  
* **Insight:** This masks the loading time of the high-fidelity 3D model. In a modal, a loading spinner would be unacceptable. In a full-screen transition, the "Whoosh" animation hides the asset load.

## **7\. Cross-Domain Insights**

### **7.1 The "Thumb Zone"**

* **App UI:** iOS is moving controls to the bottom (Sheets) to accommodate the "Thumb Zone".24  
* **Game UI:** Games have long placed menus at the bottom (anchors) or sides.  
* **Conflict:** The standard iOS "Back" button (Top Left) is hostile to the Thumb Zone. Games often move the "Exit" button to the Top Right or allow tapping empty space. iOS apps are adopting "Swipe to Dismiss" (Sheets) to solve this same ergonomic problem.

### **7.2 Read-Only vs. Edit**

* **Rule:** If the user can *edit* the data, Modals (Sheets) can be risky because a stray swipe might discard changes (though iOS 13+ introduced safeguards).  
* **Rule:** For *read-only* data, Sheets/Modals are safer and faster. Games follow this: "Card Info" is a modal (Read-Only). "Deck Edit" is a screen/state.

## **8\. Summary of Tables**

### **Table 1: Navigation Pattern Suitability (iOS)**

| Pattern | Read-Only List | Editable Detail | Map/Spatial | Deep Hierarchy |
| :---- | :---- | :---- | :---- | :---- |
| **Push** | Low | High | Poor | High |
| **Sheet (Modal)** | High | Medium | Excellent | Poor |
| **Full Screen** | Medium | High | Poor | Medium |

### **Table 2: Game Roster UI Patterns**

| Genre | UI Pattern | Primary Context | Transition Style |
| :---- | :---- | :---- | :---- |
| **CCG (Marvel Snap)** | Modal Overlay | Deck Building | Zoom / Expand |
| **Strategy (Clash Royale)** | Pop-up Window | Battle Prep | Pop-in |
| **RPG (Genshin Impact)** | Full Screen | Character Growth | Scene Cut / Fade |
| **Gacha (Honkai Star Rail)** | Full Screen | Team Setup | Particle Swipe |

# **Recommendations for the User**

Based on the research, if you are designing an iOS app with read-only details:

1. **Do not use Push.** Use a **Bottom Sheet** with a medium detent.  
2. **Mimic Apple Maps.** Allow the user to interact with the list/map behind the sheet.

If you are designing a Mobile Game Character Roster:

1. **Determine Depth:** If the character has \>3 tabs of data, use **Full Screen**. If \<3 stats, use **Modal**.  
2. **Navigation:** If Full Screen, include the roster list *inside* the screen (Sidebar) to prevent "Back Button Fatigue."  
3. **Transition:** Use **Zoom** animations (like *Marvel Snap*) to make the transition feel continuous rather than jarring.

#### **Works cited**

1. Navigation \- Interaction \- iOS Human Interface Guidelines \- CodersHigh, accessed November 22, 2025, [https://codershigh.github.io/guidelines/ios/human-interface-guidelines/interaction/navigation/index.html](https://codershigh.github.io/guidelines/ios/human-interface-guidelines/interaction/navigation/index.html)  
2. Lists and tables | Apple Developer Documentation, accessed November 22, 2025, [https://developer.apple.com/design/human-interface-guidelines/lists-and-tables](https://developer.apple.com/design/human-interface-guidelines/lists-and-tables)  
3. Modality \- Interaction \- iOS Human Interface Guidelines \- CodersHigh, accessed November 22, 2025, [https://codershigh.github.io/guidelines/ios/human-interface-guidelines/interaction/modality/index.html](https://codershigh.github.io/guidelines/ios/human-interface-guidelines/interaction/modality/index.html)  
4. Modality | Apple Developer Documentation, accessed November 22, 2025, [https://developer.apple.com/design/human-interface-guidelines/modality](https://developer.apple.com/design/human-interface-guidelines/modality)  
5. Sheets | Apple Developer Documentation, accessed November 22, 2025, [https://developer.apple.com/design/human-interface-guidelines/sheets](https://developer.apple.com/design/human-interface-guidelines/sheets)  
6. Exploring Interactive Bottom Sheets in SwiftUI \- Create with Swift, accessed November 22, 2025, [https://www.createwithswift.com/exploring-interactive-bottom-sheets-in-swiftui/](https://www.createwithswift.com/exploring-interactive-bottom-sheets-in-swiftui/)  
7. Google Maps vs Apple Maps: Subtle UX Choices That Shape How We Navigate \- UX Planet, accessed November 22, 2025, [https://uxplanet.org/google-maps-vs-apple-maps-subtle-ux-choices-that-shape-how-we-navigate-a58a1c60ad10](https://uxplanet.org/google-maps-vs-apple-maps-subtle-ux-choices-that-shape-how-we-navigate-a58a1c60ad10)  
8. Maps | Apple Developer Documentation, accessed November 22, 2025, [https://developer.apple.com/design/human-interface-guidelines/maps](https://developer.apple.com/design/human-interface-guidelines/maps)  
9. iOS Sheet or Modal? Can You Help Me Identify Use Cases? \- UX Stack Exchange, accessed November 22, 2025, [https://ux.stackexchange.com/questions/151614/ios-sheet-or-modal-can-you-help-me-identify-use-cases](https://ux.stackexchange.com/questions/151614/ios-sheet-or-modal-can-you-help-me-identify-use-cases)  
10. Mastering PresentationDetent in SwiftUI: A Comprehensive Guide | by Wesley Matlock, accessed November 22, 2025, [https://medium.com/@wesleymatlock/mastering-presentationdetent-in-swiftui-a-comprehensive-guide-ce75eab8c508](https://medium.com/@wesleymatlock/mastering-presentationdetent-in-swiftui-a-comprehensive-guide-ce75eab8c508)  
11. iOS 16.4, SwiftUI bottom sheet is sometimes ignoring presentationDetents \- Stack Overflow, accessed November 22, 2025, [https://stackoverflow.com/questions/77033853/ios-16-4-swiftui-bottom-sheet-is-sometimes-ignoring-presentationdetents](https://stackoverflow.com/questions/77033853/ios-16-4-swiftui-bottom-sheet-is-sometimes-ignoring-presentationdetents)  
12. How To Design An Open-Source iPhone Game \- Smashing Magazine, accessed November 22, 2025, [https://www.smashingmagazine.com/2013/02/designing-an-open-source-iphone-game/](https://www.smashingmagazine.com/2013/02/designing-an-open-source-iphone-game/)  
13. Marvel Snap Concepts \- UI/UX Designer \- Michael Calcada, accessed November 22, 2025, [https://www.michaelcalcada.com/snap.html](https://www.michaelcalcada.com/snap.html)  
14. Card Rarity & Progression Explained in MARVEL Snap \- YouTube, accessed November 22, 2025, [https://www.youtube.com/shorts/uqF5sgu4Ieg](https://www.youtube.com/shorts/uqF5sgu4Ieg)  
15. Does this mean every card/variant has a zoomed out version? : r/MarvelSnap \- Reddit, accessed November 22, 2025, [https://www.reddit.com/r/MarvelSnap/comments/10aue64/does\_this\_mean\_every\_cardvariant\_has\_a\_zoomed\_out/](https://www.reddit.com/r/MarvelSnap/comments/10aue64/does_this_mean_every_cardvariant_has_a_zoomed_out/)  
16. Changes in UI : r/houkai3rd \- Reddit, accessed November 22, 2025, [https://www.reddit.com/r/houkai3rd/comments/18ct5wt/changes\_in\_ui/](https://www.reddit.com/r/houkai3rd/comments/18ct5wt/changes_in_ui/)  
17. How Honkai: Star Rail Fixes Genshin Impact's UI Problem | by Neraca Cinta Dzilhaq, accessed November 22, 2025, [https://medium.com/@acarenatnic/how-honkai-star-rail-fixes-genshin-impacts-ui-problem-6b386d6154f1](https://medium.com/@acarenatnic/how-honkai-star-rail-fixes-genshin-impacts-ui-problem-6b386d6154f1)  
18. Game UI design | Thought \- Corporation Pop, accessed November 22, 2025, [https://corporationpop.co.uk/thoughts/game-ui-design](https://corporationpop.co.uk/thoughts/game-ui-design)  
19. Designing Efficient User Interfaces For Games | by Nicolas Kraj | Medium, accessed November 22, 2025, [https://medium.com/@nicolaskraj/designing-efficient-user-interfaces-for-games-be20b516f1c2](https://medium.com/@nicolaskraj/designing-efficient-user-interfaces-for-games-be20b516f1c2)  
20. UX in Clash Royale \- Part 1 \- ArtStation, accessed November 22, 2025, [https://www.artstation.com/blogs/dasp/90l/ux-in-clash-royale-part-1](https://www.artstation.com/blogs/dasp/90l/ux-in-clash-royale-part-1)  
21. Enhance your UI animations and transitions | Documentation \- WWDC Notes, accessed November 22, 2025, [https://wwdcnotes.com/documentation/wwdcnotes/wwdc24-10145-enhance-your-ui-animations-and-transitions/](https://wwdcnotes.com/documentation/wwdcnotes/wwdc24-10145-enhance-your-ui-animations-and-transitions/)  
22. Zoom transitions \- Douglas Hill, accessed November 22, 2025, [https://douglashill.co/zoom-transitions/](https://douglashill.co/zoom-transitions/)  
23. Modal vs Full Screen UI & UX \- Which One is Right for Your Design? \- Nakgnakinam, accessed November 22, 2025, [https://nakgnakinam.medium.com/modal-vs-full-screen-ui-ux-which-one-is-right-for-your-design-7e2b4501489a](https://nakgnakinam.medium.com/modal-vs-full-screen-ui-ux-which-one-is-right-for-your-design-7e2b4501489a)  
24. Designing for iOS | Apple Developer Documentation, accessed November 22, 2025, [https://developer.apple.com/design/human-interface-guidelines/designing-for-ios](https://developer.apple.com/design/human-interface-guidelines/designing-for-ios)  
25. Nielsen and Molich's 10 User Interface Design Heuristics: A Duolingo Study Case \- Medium, accessed November 22, 2025, [https://medium.com/@anamariaerascu/nielsen-and-molichs-10-user-interface-design-heuristics-a-duolingo-study-case-27828d4848c9](https://medium.com/@anamariaerascu/nielsen-and-molichs-10-user-interface-design-heuristics-a-duolingo-study-case-27828d4848c9)  
26. Creating Usability with Motion: The UX in Motion Manifesto | by Issara Willenskomer, accessed November 22, 2025, [https://medium.com/ux-in-motion/creating-usability-with-motion-the-ux-in-motion-manifesto-a87a4584ddc](https://medium.com/ux-in-motion/creating-usability-with-motion-the-ux-in-motion-manifesto-a87a4584ddc)  
27. Marvel's Snap— UI/UX Case Study \- by Ashmik Ragesh \- Medium, accessed November 22, 2025, [https://medium.com/design-bootcamp/marvels-snap-ui-ux-case-study-9f727d8f3875](https://medium.com/design-bootcamp/marvels-snap-ui-ux-case-study-9f727d8f3875)  
28. Genshin Impact Fans Don't Understand Character Design \- YouTube, accessed November 22, 2025, [https://www.youtube.com/watch?v=whDs4\_0HtAY](https://www.youtube.com/watch?v=whDs4_0HtAY)  
29. Zoie Esguerra \- Genshin Impact: Spiral Abyss Redesign, accessed November 22, 2025, [https://zoieesguerra-gi.crd.co/](https://zoieesguerra-gi.crd.co/)  
30. All Honkai Star Rail Skill Transition Animation \[Honkai Star Rail\] \- YouTube, accessed November 22, 2025, [https://www.youtube.com/watch?v=owwIz8dTGaU](https://www.youtube.com/watch?v=owwIz8dTGaU)  
31. Duolingo UX Analysis. I've a gazillion apps installed on my… | by Gaurav Makkar, accessed November 22, 2025, [https://uxplanet.org/duolingo-ux-analysis-9631ff3f4eb1](https://uxplanet.org/duolingo-ux-analysis-9631ff3f4eb1)