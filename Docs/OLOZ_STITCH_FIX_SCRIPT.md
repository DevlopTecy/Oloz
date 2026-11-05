# Oloz — Stitch Fix Script (v2)

Run these in order inside your Stitch project. Each block is a copy-paste prompt.

**Order:** 1) Design system patch → 2) Global fix → 3) Per-screen fixes → 4) New screens.
Tip: after step 1, regenerate or "apply design system" on every screen, then do step 2 on all screens at once, then step 3 one screen at a time.

---

## 0. Why the colors drifted (root cause)
Your exported design tokens define `primary: #3e57a7` (dark navy) and `secondary: #88503a` (brown). Stitch used those instead of the brand colors in the text, so buttons, bars and tabs look heavier than designed and brown appears on Instagram bars and percentages. Step 1 fixes the tokens.

---

## 1. Design system patch (paste into the design system / DESIGN.md)

```
Update the Oloz design system tokens. Do not change anything else.

colors:
  primary: '#5870C2'            # filled buttons, active tab text, links (white text on it passes 4.5:1)
  on-primary: '#FFFFFF'
  primary-chart: '#6B83D6'      # bars, rings, progress fills, today highlight
  primary-container: '#E3E8F8'
  on-primary-container: '#2F4390'
  secondary: '#F0A98E'          # reel fills only (rings, bars, dots)
  on-secondary: '#4A2616'
  secondary-container: '#FBE9E1'
  on-secondary-container: '#79452F'  # text on peach chips only
  tertiary: '#7FB69A'
  error: '#D98A8A'

Rules to add:
- Only two chromatic colors per screen: indigo (time) and peach (reels). No brown fills, no brown bars.
- Brown is allowed only as small text on a peach-soft chip.
- Instagram, TikTok, YouTube and Facebook bars all use peach in decreasing tints.
- Section labels and card headings use sentence case. No uppercase labels anywhere.
- Large numbers use tabular figures; units (h, m, reels) at 55% of the number size, secondary text color.
- Every screen has one focus metric. No insight banners, no helper sentences under charts.
```

---

## 2. Global fix prompt (apply to every screen)

```
Apply these fixes to all screens, keeping layout and content structure:

1. Colors: use primary #5870C2 for filled buttons and active tab, #6B83D6 for bars/rings/progress, peach #F0A98E for reels. Remove all brown fills and bars.
2. Sentence case everywhere. Remove all uppercase labels (e.g. "PREFERENCES", "ACTIVE USAGE", "TOTAL SCREEN TIME", "MONITORED APPLICATION", "DAILY CADENCE", "MINDFUL OVERVIEW").
3. Less text: delete every insight or tip banner, every card subtitle sentence, and every helper line under a chart. Keep only: number, short label, optional delta chip.
4. Simplify wording: "Weekly rhythm" → "This week", "Weekly flow" → "This week", "Platform split" → "By platform", "Top applications" → "Top apps", "Mindful pulse" → remove, "Scroll nudge frequency" → "Reminders", "Feed stream analytics / Live telemetry" → remove, "Friction step" → "Break reminder".
5. Mobile header: remove the stretched screenshot thumbnail. Home shows a small Oloz logo mark (indigo ring with peach dot) left and a 32px neutral avatar right. Other screens show a single left-aligned 22px title only. No duplicate "Oloz" + title.
6. Mobile bottom nav: Home icon must be a simple outline house (currently a document-edit icon). Keep Reels, Apps, Settings. Active tab = soft pill + indigo icon and label.
7. Add 16px of space between the header and the first card on every screen (cards currently touch the header).
8. App icons: one consistent treatment — 36px rounded square (radius 12), soft tinted background, simple brand glyph (Instagram camera, TikTok note, YouTube play, X mark, Chrome circle, WhatsApp bubble, Reddit alien). Same on mobile and desktop.
9. Use this single dataset on all screens (no other numbers):
   - Date: Friday, Nov 6
   - Screen time today: 5h 07m (−14% vs yesterday), daily limit 6h 00m
   - Reels today: 286 (−8%), daily reel goal 350, 64 remaining
   - Apps: Instagram 1h 48m, TikTok 1h 12m, YouTube 45m, X 28m, Chrome 22m, WhatsApp 18m, Reddit 14m
   - Reels by platform: Instagram 142, TikTok 84, YouTube Shorts 48, Facebook 12
   - Instagram: 23 opens, limit 1h 30m
   - Devices: "This phone" (live), "Windows PC" (synced 2m ago)
10. Charts show the last 7 days ending today (today is the last bar, bold letter). No future-day bars. Every bar has a visible height, no empty bars.
11. Profile: replace the named person and stock photo ("Julian Vance", "Elena Rostova") with an initials avatar and the label "Your account".
12. Button spacing: at least 12px between stacked buttons.
```

---

## 3. Per-screen fix prompts

### Home (mobile)
```
Fix the Home screen. Keep: segmented control (Day / Week / Month), two stat cards, weekly chart, top apps.
- Stat cards: show "5h 07m" and "286" with delta chips. Label below: "Screen time" and "Reels". Remove the colored dots at top left.
- Weekly chart: title "This week". Remove the "Average 3h 40m per active day" line. Today is the last bar in #6B83D6, others #E3E8F8. Remove future days.
- Top apps: 3 rows. Subtitle on each row is only the reel count in peach text for social apps, otherwise nothing. Fix reel counts to match the dataset (Instagram 142, TikTok 84).
- Delete the bottom card "You paused 14 intentional minutes...".
```

### Reels (mobile)
```
Fix the Reels screen.
- Remove the "Mindful Pulse" chip, "Updated just now" and "Day 14 streak" row.
- Ring: peach #F0A98E on #EEEDE9 track, 8px stroke, round caps, fills 82% clockwise from the top. Center: "286" with "Reels today" below. Remove the "Goal: 350 max" chip and the "64 reels remaining under threshold" bar; replace with one small line under the ring: "64 left" in secondary text.
- "By platform": 4 rows with sentence-case names, count on the right, thin peach bar in decreasing tints. Remove the "% of total" subtext and the "4 channels active" label. Use the same icon style for every row (Facebook should not use a blue globe).
- "Last 7 days": 7 bars, every day has a bar (Tue and Wed are missing now), use peach for all bars: today is the last bar in solid peach #F0A98E, the others peach-soft #FBE9E1. Remove the floating "286" label, the legend row, and the "−14% vs last wk" chip.
- Delete the "Wind-down Reel Lock" card.
```

### Apps (mobile)
```
Fix the Apps screen.
- Title "Apps". Remove the "TOTAL USAGE TODAY" card's hourglass icon, the multi-color brown/peach/indigo bar, and "7 tracked apps". Replace with a simple summary row: "5h 07m" large, a single indigo progress bar toward the 6h limit, and "6h limit" in secondary text on the right.
- Search field + filter chips (All, Social, Browsing, Utility). Selected chip uses #E3E8F8 with indigo text.
- App rows: icon, name, time on the right, thin indigo progress bar under. Remove the category subtitle and the "35% of daily" text. Keep the list to the 7 apps in the dataset.
- Remove the "Focus session" card at the bottom.
- Add 12px more space between rows so the list breathes.
```

### App detail (Instagram)
```
Fix the Instagram detail screen.
- Back arrow left, "Instagram" with the icon as a title block. Remove the "Monitored" chip.
- Remove uppercase labels ("ACTIVE USAGE", "WEEKLY RHYTHM", "REELS", "TODAY").
- Card 1: "1h 48m" large, label "Today", progress bar showing 1h 48m of the 1h 30m limit in danger-soft color (slightly over), delta chip "−18%".
- Card 2: 7-day bar chart, no title subtitle, today last and bold.
- Two small cards: "142 reels" (peach icon) and "23 opens". Number large, label small. Remove the "REELS" and "TODAY" corner tags.
- Delete the insight text "Usage peaks between 8:00 PM...".
- Primary button "Set limit" in #5870C2, 48px, with no icon.
```

### Set limit (bottom sheet)
```
Rebuild the Set limit screen as a true bottom sheet.
- Background: the Instagram detail screen dimmed with a 40% charcoal overlay. Hide the bottom nav.
- Sheet: white, 28px top radius, grabber handle at the top, title "Daily limit" with "Instagram" chip, nothing cut off at the top edge.
- Big stepper: minus button, "1h 30m", plus button. Remove the "gentle pause alert" caption.
- Presets row: 45m, 1h, 1h 30m, 2h as pills; selected = #E3E8F8 with indigo text.
- One toggle row "Remind me" (remove "Soft vibration when reached").
- Primary button "Save" full width. Remove the empty space below the sheet.
```

### Settings (mobile)
```
Fix the Settings screen.
- Title "Settings". Replace the profile card ("Julian Vance", "Mindful Plan Active") with a slim row: initials avatar, "Your account", "Synced" chip.
- Remove uppercase group labels. Use plain sentence-case group titles: "Preferences", "Devices".
- Rows (label left, value or toggle right): Goals and limits (value "6h · 350 reels"), Notifications (toggle), Theme (segmented Light / Dark / Auto on the same row, not on a second line), Permissions (check icon only), Reminders (value "Every 15m").
- Devices group: "This phone" (Live) and "Windows PC" (Synced 2m ago). Use phone and monitor icons.
- Remove the footer text "Oloz Build 2.4.0...".
- Replace the meditating-figure icon next to Reminders with a bell.
```

### Onboarding 1: Welcome
```
Keep this screen almost as is. Changes: use primary #5870C2 on the button; remove the arrow icon in the button; keep "Skip" top right; logo mark slightly larger (120px) with the same soft glow; tagline stays "Know your scroll." and the sub line becomes "Screen time and reels, simply." Page dots at the bottom stay.
```

### Onboarding 2: Permission
```
Simplify the permission screen.
- Keep the shield icon, title "Allow usage access", and a one-line sub text: "Stays on your device."
- Remove the "On-device only" top chip and the two feature cards. Replace them with a single compact row of two icon+label pairs below the sub text: lock "Private" and swipe "Counts reels".
- Button "Allow" in #5870C2 without the check icon. "Not now" text button below.
```

### Onboarding 3: Goal
```
Fix the goal screen.
- Title "Daily goal", remove the sub text.
- Two cards: "Screen time" 6h 00m with stepper, and "Reels" 350 with stepper. Remove uppercase labels, the "Balanced" and "Mindful" chips, and the "Recommended limit" and "Roughly ~35 mins" captions.
- Progress bars: indigo for time, peach for reels.
- Remove the grey info box with the odd "<" icon.
- "Done" button #5870C2, "Skip" text button.
```

### Over-limit alert
```
Rebuild as a focused full-screen alert.
- Remove the top app bar and the bottom nav. Keep only a close (X) at the top right.
- Center: soft danger-tinted ring with an hourglass icon, title "Limit reached", one line below "Instagram · 1h 30m" in sentence case.
- Delete the paragraph, the reels/pickups pill, the breathing hint, and the "No judgment • Reset scheduled at midnight" line.
- Buttons at the bottom with 12px gap: "Take a break" (primary #5870C2, moon icon) and "5 more min" (secondary muted). 
```

### Desktop Home
```
Fix the desktop Home screen at 1440 wide.
- Sidebar: full viewport height, sticky, white, with a right hairline border. It currently stops partway down. Bottom of sidebar: "Live syncing" status and the initials avatar "Your account".
- Replace the top label "DAILY CADENCE" and "MINDFUL OVERVIEW" with a single title "Today" and date "Fri, Nov 6" in secondary text.
- Stat cards: "5h 07m" and "286". Remove descriptions ("38 minutes below your daily calm threshold", "Average attention duration..."). Labels are "Screen time" and "Reels". Remove the faint gradient icon watermark.
- Weekly chart: title "This week", day letters in order ending with today (F) at the right, add hover tooltips showing the value. Remove "Comparative daily digital presence" and the legend.
- Top apps card: 5 rows, remove category subtitles, remove "5 of 18 tracked apps shown", keep a "See all" link.
- By platform card: 4 rows, peach tints, remove the footer banner "Reel scrolling reduced by 22m today" and the empty gap at the bottom of the card.
```

### Desktop Apps
```
Fix the desktop Apps screen.
- The 7-day chart in the right panel is empty. Render 7 visible bars (today last, indigo; others #E3E8F8) with day letters.
- Remove uppercase table headers. Header row: "App" and "Time" in sentence case, secondary color.
- In the list, remove the secondary text under the time ("68% scroll quota", "Daily pace", "Controlled"). Keep the device tag (Phone / PC) as a small pill.
- Filter: "All", "Phone", "PC". Replace iPhone/MacBook wording with Phone/PC; replace Safari with Chrome.
- Right panel: icon + "Instagram", "1h 48m" large, two mini cards (Reels 142, Opens 23), chart, "Break reminder" row, "Set limit" button #5870C2.
- Remove the bottom "Mindful Balance Assessment" card and keep "Export" as a small text button in the header.
```

### Desktop Reels
```
Fix the desktop Reels screen.
- Remove the "FEED STREAM ANALYTICS • Live Telemetry" eyebrow. Title: "Reels".
- Big card: "286" large with "reels today", delta chip. The card has a large empty area — put a small peach sparkline of the last 24 hours inside it, and remove the "IG TK YT" abbreviation chips and "5-day soft streak" chip.
- Goal card: peach ring showing 82%, center "64 left". Remove "Pacing Rate / 81.7% threshold used" box.
- By platform: 4 rows with counts, remove "Time spent on infinite short-form feeds" and the footer "Session length average".
- Last 30 days chart: bars in #FBE9E1, today in peach. Fix the "Today: 286" tooltip that is clipped at the card edge (right-align it inside the card). Remove "Rolling Cadence" and the legend.
- Delete the bottom "Downtime Boundary Active" card.
```

---

## 4. New screens to add

### A. Live reel counter (the core feature)
```
Design a small floating counter pill shown over a short-video app on mobile. A phone screen with a blurred, abstract vertical video behind it. Top right: a 44px-tall pill, white 90% with blur, 1px hairline, containing a peach dot, the number "37" in tabular bold, and "reels". Tapping expands it to show "37 reels · 12m" and a small pause icon. Show both collapsed and expanded states side by side. Calm, minimal, no logos.
```

### B. Home (dark theme)
```
Dark theme version of the mobile Home screen. Background #14161A, cards #1C1F25 with #2E323B hairline, text #ECEDEF and #9AA0AA, indigo bars #8FA3E8, peach #F2B49B. Same layout and data as the light Home screen.
```

### C. Desktop Settings
```
Desktop Settings screen at 1440 wide with the same sidebar (Settings active). Centered column 640px wide. Groups: "Preferences" (Goals and limits, Notifications, Theme segmented Light/Dark/Auto), "Devices" (This phone live, Windows PC synced), "Startup" (Launch with Windows toggle, Show in tray toggle). No descriptions, one label and one control per row.
```

### D. Empty state (first day)
```
Mobile Home empty state for a new user with no data yet. Same header and tabs. Centered soft indigo ring icon, one line "Nothing tracked yet", one button "Allow usage access". No cards, no charts.
```

---

## 5. Final polish prompt (run last on all screens)
```
Final pass: check 8px grid alignment, equal card padding of 20px, consistent 20px radius on cards, tabular numerals on all numbers, 4.5:1 contrast for all text, and that no screen has more than two chromatic colors. Keep everything else unchanged.
```
