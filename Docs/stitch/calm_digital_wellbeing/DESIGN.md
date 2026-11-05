---
name: Calm Digital Wellbeing
colors:
  surface: '#FFFFFF'
  surface-dim: '#d8dae0'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3fa'
  surface-container: '#eceef4'
  surface-container-high: '#e6e8ef'
  surface-container-highest: '#e1e2e9'
  on-surface: '#191c21'
  on-surface-variant: '#444651'
  inverse-surface: '#2e3136'
  inverse-on-surface: '#eff0f7'
  outline: '#757682'
  outline-variant: '#c5c5d3'
  surface-tint: '#415aaa'
  primary: '#3e57a7'
  on-primary: '#ffffff'
  primary-container: '#5870c2'
  on-primary-container: '#fffbff'
  inverse-primary: '#b6c4ff'
  secondary: '#88503a'
  on-secondary: '#ffffff'
  secondary-container: '#feb59a'
  on-secondary-container: '#79452f'
  tertiary: '#745b00'
  on-tertiary: '#ffffff'
  tertiary-container: '#cda72f'
  on-tertiary-container: '#4f3d00'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dce1ff'
  primary-fixed-dim: '#b6c4ff'
  on-primary-fixed: '#00164e'
  on-primary-fixed-variant: '#274190'
  secondary-fixed: '#ffdbce'
  secondary-fixed-dim: '#feb59a'
  on-secondary-fixed: '#350f02'
  on-secondary-fixed-variant: '#6b3925'
  tertiary-fixed: '#ffe08c'
  tertiary-fixed-dim: '#eac249'
  on-tertiary-fixed: '#241a00'
  on-tertiary-fixed-variant: '#584400'
  background: '#f8f9ff'
  on-background: '#191c21'
  surface-variant: '#e1e2e9'
  bg-app: '#F6F5F2'
  surface-muted: '#EEEDE9'
  border-subtle: '#E4E2DC'
  text-primary: '#23262B'
  text-secondary: '#6E727A'
  primary-soft: '#E3E8F8'
  accent-soft: '#FBE9E1'
  success: '#7FB69A'
  warning: '#E6C27A'
  danger: '#D98A8A'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 40px
    fontWeight: '600'
    lineHeight: 48px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Inter
    fontSize: 36px
    fontWeight: '600'
    lineHeight: 44px
    letterSpacing: -0.02em
  title-lg:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  title-md:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  section-title:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 22px
  body-default:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-medium:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
  caption-default:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
  caption-tabular:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.02em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-desktop: 1.5rem
  margin: 1.25rem
  margin-desktop: 2rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-lg: 1rem
  space-xl: 1.5rem
  space-2xl: 2rem
  space-3xl: 3rem
---

## Brand & Style

This design system delivers a calm, high-end, and intentional digital atmosphere created for mindful screen time and reel-scroll monitoring across mobile and desktop. Rejecting guilt-driven tactics and high-stress analytics, the aesthetic draws inspiration from minimalist Swiss typography, warm tactile editorial layouts, and refined product craft akin to high-fidelity Figma tooling.

### Personality & Emotional Response
- **Serene & Non-Judgmental:** The UI refrains from shame or sensory panic. Metrics report usage neutrally and gracefully without alarming alerts.
- **Precision Craft:** Hairline dividers, tabular figures, and balanced padding instill a sense of calm control and executive polish.
- **Clarity Over Clutter:** The interface presents the answer first, withholding secondary details until prompted. One focal metric per surface, uncluttered whitespace, and zero visual noise.

### Style Directives
- **Visual Movement:** Contemporary Soft Minimalism. Warm, organic light surfaces mixed with subtle atmospheric elevation.
- **Contrast Philosophy:** Deep charcoal ink grounded on warm stone canvas; neither harsh 100% black nor blinding 100% white.
- **Restraint:** At most two chromatic accents per screen context (Primary Indigo for general screen time, Accent Peach specifically dedicated to reel engagement).

## Colors

The palette establishes a restorative, tactile balance rooted in warm natural pigments rather than clinical tech grays.

### Application Hierarchy
- **Canvas (`#F6F5F2`):** A warm off-white foundation that eliminates eye fatigue and visually lifts pure white surface elements.
- **Surface (`#FFFFFF`):** High-priority modules, metric cards, sheets, and popovers. Never use as an overall page canvas.
- **Surface Muted (`#EEEDE9`):** Input containers, segmented pill tracks, chip fills, and inactive chart baselines.
- **Borders (`#E4E2DC`):** 1px structural outlines separating surfaces and grouping modules without visual weight.
- **Typography (`#23262B` & `#6E727A`):** Deep carbon for primary reading and display stats; muted graphite for secondary axis labels, metadata, and timestamps.
- **Chromatics:**
  - `primary_color_hex` (`#6B83D6`): Cool slate indigo used exclusively for core navigation states, primary triggers, and overall screen time visualizations.
  - `secondary_color_hex` (`#F0A98E`): Warm terracotta peach strictly reserved for short-form video metrics (reels, shorts, TikToks).
  - Semantic status indicators (`#7FB69A`, `#E6C27A`, `#D98A8A`) provide muted status awareness for limits and goals without creating visual anxiety.

## Typography

The typographic system is built on **Inter**, engineered for optimal legibility and numeric rhythm across varying screen densities.

### Rules & Formatting
- **Tabular Numerals:** All metric cards, daily counters, and chart axes must implement `font-variant-numeric: tabular-nums` (or `tnum`) to eliminate layout jitter during live counter increments.
- **Casing:** Enforce standard sentence case across all headlines, action triggers, buttons, and navigation markers. All-caps is strictly prohibited except for micro chart markers (e.g., single-letter weekday indicators `M`, `T`, `W`).
- **Pacing & Restraint:** Never decorate headings with leading icons or auxiliary badges. Rely on structural spacing and font-weight differentiation to establish reading hierarchy.

## Layout & Spacing

Layouts prioritize spacious, uncluttered organization with generous margins that frame focal data points cleanly.

### Layout Mechanics
- **Mobile (Primary):** Single-column layout bounded by a persistent thumb-zone bottom navigation bar. Margins are fixed at 20px (`1.25rem`), maximizing vertical rhythm and preventing edge crowding.
- **Desktop:** Centered responsive grid restricted to a max container width of 1200px. Includes a fixed left navigational sidebar (collapsible from 240px to 72px) with 32px (`2rem`) outer layout margins.
- **Rhythm Scale:** 4px baseline unit. Component gap compositions favor 8px, 12px, 16px, 24px, 32px, and 48px increments.
- **Card Spacing Rule:** Stack a maximum of three core informational cards before introducing breathing space or an intentional section divider.

## Elevation & Depth

Visual depth is achieved through quiet material distinction rather than dramatic dropshadows or heavy layering.

### Surface Treatment & Shadow Structure
- **Border Integration:** Elevated cards and modal sheets pair a clean 1px hairline border (`#E4E2DC`) with an ultra-soft atmospheric shadow to establish gentle separation from the warm `#F6F5F2` backdrop.
- **Soft Ambient Shadow:**
  - `box-shadow: 0 4px 20px rgba(35, 38, 43, 0.05);`
  - Zero tinted color bleed; shadow uses the neutral primary charcoal tone at ultra-low opacity to retain an organic, grounded presence.
- **Nested Controls:** Segmented button tracks, secondary chips, and input fields sit recessed within `#EEEDE9` without borders or inner bevels, appearing smoothly carved into the parent surface.

## Shapes

The geometry balances modern precision with friendly, organic softness through rounded corners.

### Component Radii Specifics
- **Primary Cards & Modals:** Standardized at `20px` radius for smooth containment.
- **Interactive Buttons & Form Fields:** Standardized at `14px` radius to maintain a distinct, tactile hierarchy against enclosing cards.
- **Application Icons:** Consistent `12px` rounded square silhouettes within app breakdown lists.
- **Chips, Badges & Toggles:** Fully curved pill treatment (`9999px`).

## Components

### Stat Card
- **Structure:** `#FFFFFF` background, 20px corner radius, 1px `#E4E2DC` hairline border, soft ambient shadow. Internal padding: 20px.
- **Content:** Single tabular `Display` number, single 12px `Text Secondary` label below. Optional top-right pill chip displaying delta trend (e.g., `−12%`). No secondary descriptions or illustrative decorations.

### Buttons
- **Primary Button:** 48px height, 14px border radius. Solid `#6B83D6` fill, `#FFFFFF` text (weight 600). No gradient; hover state darkens smoothly by 4%.
- **Secondary Button:** 48px height, 14px radius. `#EEEDE9` muted fill, `#23262B` text. Active touch scales down by 0.98.

### Chips & Segmented Controls
- **Segmented Control:** Recessed `#EEEDE9` pill track, 4px internal padding. Active segment renders as a pure `#FFFFFF` pill with a faint 2px drop shadow and bold label.
- **Filter Chips:** 32px height, full pill radius. Unselected: `#EEEDE9` surface with secondary text. Selected: `#E3E8F8` surface with `#6B83D6` text.

### Form Inputs & Switches
- **Input Fields:** Recessed `#EEEDE9` background, 14px radius, 16px horizontal padding, 48px height. Active focus transitions border to 1px `#6B83D6` without heavy outer glows.
- **Toggles:** Pill chassis (50px × 28px). Inactive: `#EEEDE9`. Active: `#6B83D6`. Pure white circular thumb smoothly slides 22px.

### Visualizations & App Rows
- **App Breakdown Row:** Left-aligned 36px app icon (12px radius), title and category stacked vertically, right-aligned usage time in tabular text. Subtly accompanied by a 4px horizontal progress bar in `#6B83D6` spanning the bottom edge.
- **Reel Counter Card:** Dedicated terracotta palette (`#F0A98E`). Features large bold tabular reel tallies supported by mini platform bars (Instagram, YouTube, TikTok) shaded with decreasing tints of `#F0A98E`.
- **Bar Charts:** 7 rounded vertical pills representing days of the week. Previous days render in `#E3E8F8`; current day is highlighted in vibrant `#6B83D6`. No horizontal gridlines or tick marks. Single-letter weekday indicators below.

### Navigation
- **Mobile Bottom Navigation:** Fixed 64px dock, `#FFFFFF` backdrop with hairline top divider. 4 tabs max: Home, Reels, Apps, Settings. Outline icons (1.75px stroke, 24px box). Active state applies `#6B83D6` tint over a soft pill backing.
- **Desktop Sidebar:** 240px wide `#FFFFFF` column, 1px right border. Clean stacked links with 12px padding and 12px gap.