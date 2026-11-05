---
name: Mindful Digital Balance
colors:
  surface: '#f8f9fd'
  surface-dim: '#d9dade'
  surface-bright: '#f8f9fd'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3f7'
  surface-container: '#edeef2'
  surface-container-high: '#e7e8ec'
  surface-container-highest: '#e1e2e6'
  on-surface: '#191c1f'
  on-surface-variant: '#444651'
  inverse-surface: '#2e3134'
  inverse-on-surface: '#eff1f5'
  outline: '#757682'
  outline-variant: '#c5c5d3'
  surface-tint: '#4159aa'
  primary: '#3e57a7'
  on-primary: '#ffffff'
  primary-container: '#5870c2'
  on-primary-container: '#fefbff'
  inverse-primary: '#b6c4ff'
  secondary: '#88503a'
  on-secondary: '#ffffff'
  secondary-container: '#feb59a'
  on-secondary-container: '#79452f'
  tertiary: '#30664e'
  on-tertiary: '#ffffff'
  tertiary-container: '#4a7f66'
  on-tertiary-container: '#f5fff7'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dce1ff'
  primary-fixed-dim: '#b6c4ff'
  on-primary-fixed: '#00164f'
  on-primary-fixed-variant: '#274191'
  secondary-fixed: '#ffdbce'
  secondary-fixed-dim: '#feb59a'
  on-secondary-fixed: '#350f02'
  on-secondary-fixed-variant: '#6b3925'
  tertiary-fixed: '#b6efd1'
  tertiary-fixed-dim: '#9bd3b5'
  on-tertiary-fixed: '#002114'
  on-tertiary-fixed-variant: '#18503a'
  background: '#f8f9fd'
  on-background: '#191c1f'
  surface-variant: '#e1e2e6'
typography:
  headline-xl:
    fontFamily: Manrope
    fontSize: 48px
    fontWeight: '600'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-xl-mobile:
    fontFamily: Manrope
    fontSize: 36px
    fontWeight: '600'
    lineHeight: 44px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Manrope
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.015em
  headline-md:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Manrope
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Manrope
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 26px
  body-md:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
  label-md:
    fontFamily: Manrope
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
  label-sm:
    fontFamily: Manrope
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
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
  margin: 1rem
  margin-desktop: 2rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system is tailored for an intentional, calm, and focused screen-time and media habit tracker. The aesthetic balances soft clarity with restrained visual discipline, evoking calm focus and accountability without triggering anxiety or punitive feelings.

The interface adheres to a warm, modern minimalist style built on clean surfaces, generous breathing room, and strict color hierarchy:
- High restraint: Every screen highlights precisely one primary focus metric. Insight banners, auxiliary commentary, and helper sentences below charts are deliberately omitted to preserve cognitive space.
- Sentence case discipline: Section labels, navigation titles, metric labels, and card headings strictly use sentence case. Uppercase labels are banned across the system.

## Colors

The palette operates under a two-chromatic-color maximum rule per screen: Indigo (`#5870C2`) strictly represents time, and Peach (`#F0A98E`) exclusively represents short-form reels and media consumption. 

### Role Allocations & Restrictions
- **Primary Indigo (`#5870C2`)**: Used for filled buttons, active tab indicators, and interactive links. Text over this color is pure white (`#FFFFFF`), satisfying WCAG AA 4.5:1 contrast standards.
- **Primary Chart Indigo (`#6B83D6`)**: Used exclusively for temporal data—chart bars, progress rings, linear meter fills, and "today" indicators.
- **Primary Container (`#E3E8F8`)**: Backing tone for active chips and subtle indigo groupings, with text in dark indigo (`#2F4390`).
- **Secondary Peach (`#F0A98E`)**: Reserved strictly for reels metrics (rings, bars, chart dots). No brown fills or brown bars are permitted anywhere.
- **Secondary Container (`#FBE9E1`)**: Peach-soft container tone used for reel status indicators.
- **Warm Brown Text (`#79452F` / `#4A2616`)**: Brown is strictly restricted to small label text within peach-soft chips (`#FBE9E1`). It is prohibited on backgrounds, large text, or chart graphics.
- **Multi-App Representation**: Multi-platform break-outs (Instagram, TikTok, YouTube, Facebook) must all use peach (`#F0A98E`) in decreasing stepped tints (100%, 75%, 50%, 30%), never distinct hue ramps.
- **Tertiary Accent (`#7FB69A`)**: Soft green reserved strictly for completion milestones or healthy streaks.
- **Feedback / Alert (`#D98A8A`)**: Soft muted rose for alerts and limits exceeded.

## Typography

The typography leverages **Manrope** for an open, precise, and approachable typographic hierarchy.

### Numerical Data & Display Rules
- **Tabular figures**: All large metrics, durations, tallies, and chart axis labels must use `font-variant-numeric: tabular-nums` to ensure numerical alignment.
- **Unit scale rule**: Metric units (`h`, `m`, `reels`) must always be rendered inline at exactly **55% of the primary numeric font size**, styled using the muted secondary text tone rather than the primary metric weight.
- **Strict sentence case**: All headlines, section titles, card labels, and metadata chips must be written in sentence case. Never use all-caps or uppercase track-outs.

## Layout & Spacing

Layouts use an adaptive fluid grid structured to prioritize immediate comprehension:
- **Mobile (< 768px)**: 4-column layout with `1rem` margins and `1rem` gutters.
- **Tablet (768px - 1024px)**: 8-column layout with `1.5rem` margins and `1rem` gutters.
- **Desktop (> 1024px)**: 12-column layout centered at a maximum content width of 1120px, with `2rem` margins and `1.5rem` gutters.

Component padding relies consistently on `space-md` (`1rem`) and `space-lg` (`1.5rem`) for cards and summary blocks to prevent visual clutter and maintain breathing room around core data.

## Elevation & Depth

Visual depth avoids layered dropshadows or heavy skeuomorphism, relying instead on clean tonal layers and subtle micro-outlines:
- **Surfaces**: Primary canvas sits on an ultra-light tint (`#F8F9FD`), with content cards elevated through pure white (`#FFFFFF`) backgrounds.
- **Outlines**: Floating cards and interactive containers utilize low-contrast border strokes (`1px solid #ECEFF8`) instead of ambient drop shadows.
- **Focused Elevation**: Modals and dropdowns use a single soft ambient shadow: `0 8px 24px -4px rgba(47, 67, 144, 0.08)`.

## Shapes

The design system uses a balanced rounded geometry (level 2) to convey warmth and modern softness:
- Primary content containers, cards, and modal sheets: `1rem` (`rounded-lg`).
- Buttons, chips, search bars, and interactive toggles: `0.5rem` (`rounded-md`) up to full-pill forms where appropriate for quick visual scanning.
- Progress bars and chart meter fills: Terminate with smooth radial pill endcaps.

## Components

### Buttons
- **Primary button**: Background `#5870C2`, text `#FFFFFF`, 8px corner radius. States use slight lightness adjustments; never switch hue.
- **Secondary button**: Background `#E3E8F8`, text `#2F4390`.
- **Text button**: Transparent background, text `#5870C2`, underline on hover only.

### Chips & Badges
- **Peach chips (reels status)**: Background `#FBE9E1`. Text must be small warm brown (`#79452F`). No dark or multi-colored strokes.
- **Indigo chips (time status)**: Background `#E3E8F8`. Text is `#2F4390`.
- **Formatting**: Text inside chips must always be sentence case.

### Charts & Visualization Elements
- **Focus metric**: Every screen must spotlight a single focus metric. Omit insight banners, summaries, and helper commentary underneath charts.
- **Time visualization**: Chart bars and circular timeline indicators render exclusively in `#6B83D6`.
- **Reels visualization**: Meter fills, timeline dots, and reel counts render strictly in `#F0A98E`.
- **Platform comparison bars**: Multi-app metrics (Instagram, TikTok, YouTube, Facebook) are displayed strictly using descending peach tints:
  - App 1: `#F0A98E` (100%)
  - App 2: `rgba(240, 169, 142, 0.75)`
  - App 3: `rgba(240, 169, 142, 0.50)`
  - App 4: `rgba(240, 169, 142, 0.30)`

### Form Controls
- **Inputs**: Solid white backgrounds bordered with `1px solid #ECEFF8`, active focus border colored with `#5870C2`.
- **Checkboxes & Toggles**: Active toggle tracks fill with `#5870C2`. Neutral inactive tracks use `#E3E8F8`.