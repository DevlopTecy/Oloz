# Oloz — Design System

## 1. Overview
**Oloz** shows how long you spend in each app and how many reels you scroll. It runs on mobile and desktop (PC).

**Feel:** calm, clean, high-end, professional. Figma-quality polish. Soft on the eyes.
**Principles:**
- Less text. One number per card, one label.
- Less detail. Show the answer first; details live one tap away.
- Icons only where they replace words (app icons, nav, a few actions).
- Every key action is within 1–2 taps/clicks.
- Generous whitespace. Nothing crowded.

## 2. Platforms
- **Mobile (primary):** single column, bottom tab bar, thumb-friendly.
- **Desktop:** left sidebar (icons + labels), content in a centered grid, max width 1200px.
- Same components, same colors, same spacing scale on both.

## 3. Color

### Light theme
| Role | Hex | Use |
|---|---|---|
| Background | `#F6F5F2` | App background (warm off-white, not pure white) |
| Surface | `#FFFFFF` | Cards, sheets |
| Surface Muted | `#EEEDE9` | Chips, inactive tracks, input fields |
| Border | `#E4E2DC` | 1px hairlines |
| Text Primary | `#23262B` | Headings, big numbers |
| Text Secondary | `#6E727A` | Labels, captions |
| Primary | `#6B83D6` | Main actions, active tab, screen-time charts |
| Primary Soft | `#E3E8F8` | Primary tinted backgrounds |
| Accent (Reels) | `#F0A98E` | Reel counter, reel charts |
| Accent Soft | `#FBE9E1` | Reel tinted backgrounds |
| Success | `#7FB69A` | Under goal |
| Warning | `#E6C27A` | Near limit |
| Danger | `#D98A8A` | Over limit |

### Dark theme
| Role | Hex |
|---|---|
| Background | `#14161A` |
| Surface | `#1C1F25` |
| Surface Muted | `#262A32` |
| Border | `#2E323B` |
| Text Primary | `#ECEDEF` |
| Text Secondary | `#9AA0AA` |
| Primary | `#8FA3E8` |
| Accent (Reels) | `#F2B49B` |

**Rules:** no pure black or pure white backgrounds. No neon. Max 2 colors per screen besides neutrals (Primary + Accent). Contrast of text on surface at least 4.5:1.

## 4. Typography
- **Font:** Inter (fallback: SF Pro, system-ui).
- Big numbers use tabular figures.

| Style | Size / Weight | Use |
|---|---|---|
| Display | 40 / 600 | Today's total time, reel count |
| Title | 22 / 600 | Screen titles |
| Section | 16 / 600 | Card headings |
| Body | 14 / 400 | Main text |
| Caption | 12 / 500 | Labels, units, axis |

Line height 1.4. Sentence case everywhere. No all-caps except tiny captions if needed.

## 5. Spacing, Shape, Elevation
- **Spacing scale:** 4, 8, 12, 16, 24, 32, 48. Screen padding 20 (mobile), 32 (desktop).
- **Radius:** cards 20, buttons 14, chips 999 (pill), app icons 12.
- **Elevation:** almost flat. Cards use border + very soft shadow (`0 4px 20px rgba(35,38,43,0.05)`). No heavy shadows, no gradients except a subtle Primary-to-Primary-Soft fade on chart areas.

## 6. Iconography
- Style: outline, 1.75px stroke, rounded caps, 24px grid (Lucide / Phosphor Light style).
- Use only for: navigation, app identity, settings, add/filter.
- Never decorate headings with icons.
- Real app logos shown as small rounded squares (28–40px) in lists.

## 7. Navigation
- **Mobile bottom tabs (4):** Home, Reels, Apps, Settings. Icon + tiny label; active tab uses Primary with a soft pill behind it.
- **Desktop sidebar:** same 4 items, collapsible to icons only.
- No hamburger menus. No nested menus.

## 8. Core Components
- **Stat Card:** big number (Display), one caption, optional tiny trend chip (e.g. "−12%"). Nothing else.
- **Ring / Progress:** thin 8px ring or bar, Primary on Surface Muted. Turns Warning/Danger near/over limit.
- **Bar Chart (week):** 7 rounded bars, today highlighted in Primary, others Primary Soft. No gridlines, only day letters below.
- **App Row:** app icon, app name, time on right, thin progress bar under. Tap opens App Detail.
- **Reel Counter Card:** large count, per-platform mini bars (Instagram, YouTube, TikTok, Facebook) using Accent shades.
- **Segmented Control:** Day / Week / Month. Pill style, Surface Muted track.
- **Primary Button:** Primary fill, white text, 48px height, radius 14.
- **Secondary Button:** Surface Muted fill, Text Primary.
- **Toggle / Switch:** pill, Primary when on.
- **Bottom Sheet (mobile) / Side Panel (desktop):** for details and limit setting.
- **Empty State:** one soft illustration-free icon, one line of text, one button.

## 9. Screens

### Home
- Greeting-free. Top: segmented control (Day / Week / Month).
- Two stat cards side by side: **Screen time** and **Reels scrolled**.
- Week bar chart.
- Top 3 apps (App Rows) with "See all" link.

### Reels
- Large reel count for the selected period.
- Platform breakdown (Instagram, YouTube, TikTok, Facebook, others) as simple bars.
- Daily trend line, minimal.
- Optional daily reel goal with a ring.

### Apps
- Search field + sorted list of App Rows (most used first).
- Tap an app: App Detail (time today, 7-day bars, set limit button).

### Settings
- Short grouped list: Goals & limits, Notifications, Theme (Light / Dark / Auto), Permissions, Devices (sync mobile + PC).
- Each row: label + value or toggle. No long descriptions.

### Onboarding (3 steps max)
1. Welcome, one line.
2. Permissions (usage access).
3. Set a daily goal (optional, skippable).

## 10. Motion
- 200–250ms ease-out. Fade + gentle 8px slide.
- Numbers count up once on load. Bars grow from zero.
- No bouncy or flashy animation. Respect reduced-motion.

## 11. Tone of Copy
- Short, neutral, calm. Max 4–5 words per label.
- Examples: "Screen time", "Reels", "Over limit", "On track".
- No guilt, no shaming messages.

## 12. Do / Don't
**Do:** use whitespace, align to an 8px grid, keep one focus per screen, keep cards consistent.
**Don't:** add more than 4 tabs, use more than 2 accent colors, show long paragraphs, stack more than 3 cards before a scroll break, use heavy borders or loud gradients.
