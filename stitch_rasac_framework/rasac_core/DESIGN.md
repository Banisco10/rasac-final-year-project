---
name: RASAC Core
colors:
  surface: '#031427'
  surface-dim: '#031427'
  surface-bright: '#2a3a4f'
  surface-container-lowest: '#000f21'
  surface-container-low: '#0b1c30'
  surface-container: '#102034'
  surface-container-high: '#1b2b3f'
  surface-container-highest: '#26364a'
  on-surface: '#d3e4fe'
  on-surface-variant: '#c5c6cd'
  inverse-surface: '#d3e4fe'
  inverse-on-surface: '#213145'
  outline: '#8f9097'
  outline-variant: '#44474c'
  surface-tint: '#bbc7df'
  primary: '#bbc7df'
  on-primary: '#253144'
  primary-container: '#0f1b2d'
  on-primary-container: '#78849a'
  inverse-primary: '#535f74'
  secondary: '#45f0cf'
  on-secondary: '#00382e'
  secondary-container: '#00d3b3'
  on-secondary-container: '#005547'
  tertiary: '#ffb95f'
  on-tertiary: '#472a00'
  tertiary-container: '#291700'
  on-tertiary-container: '#b87500'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#d7e3fc'
  primary-fixed-dim: '#bbc7df'
  on-primary-fixed: '#101c2e'
  on-primary-fixed-variant: '#3c475b'
  secondary-fixed: '#55fcda'
  secondary-fixed-dim: '#27dfbe'
  on-secondary-fixed: '#00201a'
  on-secondary-fixed-variant: '#005143'
  tertiary-fixed: '#ffddb8'
  tertiary-fixed-dim: '#ffb95f'
  on-tertiary-fixed: '#2a1700'
  on-tertiary-fixed-variant: '#653e00'
  background: '#031427'
  on-background: '#d3e4fe'
  surface-variant: '#26364a'
typography:
  headline-lg:
    fontFamily: DM Sans
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 38px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: DM Sans
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: DM Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: DM Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: DM Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: DM Sans
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  code-md:
    fontFamily: JetBrains Mono
    fontSize: 13px
    fontWeight: '450'
    lineHeight: 20px
  label-caps:
    fontFamily: JetBrains Mono
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  unit: 4px
  container-max: 1440px
  gutter: 16px
  margin-mobile: 16px
  margin-desktop: 32px
  density-compact: 8px
  density-comfortable: 16px
---

## Brand & Style

The design system is engineered for the high-stakes environment of higher education cybersecurity. It prioritizes **technical authority, precision, and rapid cognition**. The aesthetic sits at the intersection of **Minimalism** and **Geist-inspired Industrialism**, utilizing a dark-mode-first approach to reduce eye strain during long periods of security monitoring.

The system evokes a sense of "governed power"—where complex authorization logic (Role, Relationship, Context, SoD) is rendered through clean, data-dense interfaces. Visual noise is aggressively eliminated in favor of high-contrast structural lines, monospaced data points, and a strict hierarchy that guides the administrator's eye to anomalies and access violations.

## Colors

The palette is anchored by **Deep Navy (#0F1B2D)**, providing a sophisticated, stable foundation for the interface. **Electric Teal (#00D4B4)** serves as the high-energy accent, used exclusively for primary actions and "active" security states.

- **Status Logic:** Use Crimson for denial or critical vulnerabilities, Amber for warnings or Segregation of Duty (SoD) conflicts, and Emerald for successful authorizations.
- **Surface Strategy:** Layers are defined by increasing luminosity. The base background is the darkest (#020617), with cards and modals sitting on #0F172A. 
- **Borders:** Use a consistent #1E293B for structural divisions to maintain a crisp, grid-like feel without excessive contrast.

## Typography

This design system utilizes a dual-type approach to balance readability with technical density.

- **DM Sans:** Primary typeface for all UI controls, navigation, and headers. It provides a modern, clean grotesque feel that remains legible even at small sizes.
- **JetBrains Mono:** The "Data Voice." Used for all IDs, IP addresses, logs, code snippets, and metadata labels. The monospaced nature ensures that alphanumeric strings (like User IDs or Policy Hashes) are perfectly aligned for quick visual scanning.
- **Scaling:** On mobile, reduce `headline-lg` to 24px. Keep body text at 14px/13px to maintain the data-dense philosophy across devices.

## Layout & Spacing

The system follows a **strict 4px grid** to ensure mathematical precision in a high-density environment. 

- **Density:** Favor "Compact" spacing (8px padding) for data tables and dashboard widgets to maximize information per screen. Use "Comfortable" (16px) for settings pages and documentation.
- **Grid:** A 12-column fluid grid for desktop. For data-heavy views, use a "sidebar-fixed / content-fluid" model where the navigation sidebar is 240px and the main staging area expands to fill the viewport.
- **Responsive:** Breakpoints at 768px (Tablet) and 1024px (Desktop). On mobile, tables should transition to a "record card" format or horizontal scroll with pinned ID columns.

## Elevation & Depth

This design system avoids heavy shadows, instead using **Tonal Layers and High-Contrast Outlines** to define hierarchy.

- **Level 0 (Base):** #020617.
- **Level 1 (Card/Section):** #0F172A with a 1px solid border (#1E293B).
- **Level 2 (Popovers/Modals):** #1E293B background with a subtle 0 8px 32px rgba(0,0,0,0.5) shadow and a 1px border at #334155.
- **Visual Depth:** Apply a 2% "Electric Teal" linear gradient to the top border of active or highlighted containers to signal focus.

## Shapes

The shape language is **Soft (0.25rem)** to maintain a technical, "engineered" appearance. 

- **Primary Radius:** 4px (Soft) for buttons, inputs, and small components.
- **Large Radius:** 8px (rounded-lg) for main content cards and dashboard widgets.
- **Extreme Radius:** 12px (rounded-xl) reserved strictly for global modals.
- **Status Indicators:** Use 0px (Sharp) or 100px (Pill) for status badges to differentiate them from interactive buttons.

## Components

- **Buttons:** 
  - *Primary:* Electric Teal background, black text, 4px radius. 
  - *Secondary:* Ghost style with #1E293B border and white text.
- **Data Tables:** High-density, 32px row height. Use `code-md` for ID columns. Header cells use `label-caps` with a subtle bottom border.
- **Status Badges:** Use the "Tri-Layer" style. 
  - *Role:* Solid tint.
  - *Relationship:* Outlined.
  - *Context:* Dotted border.
  - *SoD Conflict:* Amber background with a high-contrast flash.
- **Input Fields:** Dark background (#020617), 1px border (#1E293B). On focus, border changes to Electric Teal with a 2px outer glow.
- **Cards:** No shadow. 1px border. Title area should be separated by a thin horizontal rule.
- **Specialized:** "Access Logic Visualizer"—a tree-style component using JetBrains Mono and thin teal connecting lines to show the path of an authorization request.