# RedBank Design System Foundation (Phase 6.1)

This document establishes the premium, Apple-quality healthcare aesthetic for RedBank. It defines the core design tokens, typography, spacing, shadows, animations, and the comprehensive component catalog.

---

## 1. Complete Surface Hierarchy & Color Palette

We utilize a soft, medical-grade color palette with a defined surface elevation hierarchy.

### Surface Hierarchy
1. **Background:** Deepest layer. Gradient scaffolding (`#F2F2F7` light, `#000000` dark).
2. **Surface 1:** Base solid elements (`#FFFFFF` light, `#1C1C1E` dark).
3. **Surface 2:** Slightly elevated/contrasted solid elements (`#F9F9F9` light, `#2C2C2E` dark).
4. **Elevated:** Highly elevated solid cards and dialogs (`#FFFFFF` light, `#3A3A3C` dark).
5. **Glass:** Floating semi-transparent layers over background (`75% opacity` white/gray with 24px blur).

### Core Semantics
- **Primary:** `Soft Red` (`#E03E3E` light, `#FF5C5C` dark).
- **Secondary:** `Medical Blue` (`#007AFF` light, `#0A84FF` dark).
- **Success:** `Calm Green` (`#34C759` light, `#30D158` dark).
- **Warning:** `Soft Orange` (`#FF9500` light, `#FF9F0A` dark).
- **Error:** `Deep Crimson` (`#FF3B30` light, `#FF453A` dark).
- **Information:** `Soft Cyan` (`#32ADE6` light, `#64D2FF` dark).

---

## 2. Standardized Icon System

Icons must communicate clearly and without visual clutter.
- **Sizes:** Defined in `AppConstants`.
  - `sm` (16dp): Inline text icons, tiny chips.
  - `md` (24dp): Standard buttons, list tiles, nav bars.
  - `lg` (32dp): Header actions, large floating buttons.
  - `xl` (48dp): Empty states, hero illustrations.
- **Usage:** Outlined variants should be the default for unselected/inactive states. Filled variants are reserved exclusively for selected navigation states or primary actions.

---

## 3. Typography Scale (Inter / SF Pro Display)

| Role | Weight | Size | Usage |
| :--- | :--- | :--- | :--- |
| **Display** | Bold (700) | 40, 36, 32 | Hero sections, major stats |
| **Headline** | SemiBold (600) | 32, 28, 24 | Screen titles, onboarding headers |
| **Title** | SemiBold (600) | 24, 20, 18 | Primary card titles |
| **Body** | Regular (400) | 16, 14, 12 | Primary reading text |
| **Label** | Medium (500) | 14, 12, 11 | Overlines, status indicators, metadata |

---

## 4. Spacing & Radius Scale (8dp Grid)

- `xs`(4), `sm`(8), `md`(16), `lg`(24), `xl`(32), `xxl`(48)
- **Radii:** `Sm`(8), `Md`(16), `Lg`(24), `Xl`(36), `Pill`(999)

---

## 5. Shadow System

- **Small:** `Y: 2, Blur: 8, Opacity: 4%` (Inputs)
- **Medium:** `Y: 4, Blur: 16, Opacity: 6%` (SurfaceCards)
- **Large:** `Y: 8, Blur: 24, Opacity: 8%` (Dialogs)
- **Floating:** `Y: 16, Blur: 32, Opacity: 12%` (Floating action cards)
- **Glass Shadow:** `Y: 4, Blur: 24, Spread: -4, Opacity: 8%` (GlassCards)

---

## 6. Animation System & Interaction States

All reusable components implement state-driven animations:
- **Default:** Standard presentation.
- **Hover:** Slight scale up (`1.02`), subtle background shift.
- **Pressed:** Scale down (`0.96` for buttons, `0.98` for cards) using a spring curve.
- **Disabled:** `50%` opacity or desaturated gray colors.
- **Loading:** Circular spinner replacement inside the component bounds.
- **Error:** Red tint or shake animation (where applicable).

**Durations & Curves:**
- `Fast` (150ms): Hover/Press states (`EaseOutCubic`).
- `Normal` (250ms): Card entrances (`EaseOutCubic`).
- `Slow` (400ms): Page transitions (`EaseInOut`).

---

## 7. Component Catalog Documentation

All widgets reside in `lib/core/widgets/`.

- **`GlassCard`**: A container applying a 24px backdrop blur and semi-transparent fill.
  - *Usage:* Floating over maps, sticky bottom bars.
- **`SurfaceCard`**: A solid elevated container mapped to Surface 1 or Elevated hierarchy based on the `elevated` boolean flag.
- **`PrimaryButton`**: The main call-to-action button. Automatically handles Hover, Pressed, Loading, Error, and Disabled states.
- **`SecondaryButton`**: Tonal/Outlined button for secondary actions. Follows identical interaction states as Primary.
- **`MedicalIconButton`**: A touch-optimized (48x48) icon button. Supports both solid and glass backgrounds.
- **`MedicalTextField`**: Form input with refined borders, label typography, and subtle focus states.
- **`OtpInput`**: Auto-focusing OTP pin boxes for verification screens.
- **`SearchBarWidget`**: Pill-shaped search bar with integrated filter trailing icon.
- **`StatusChip`**: Tiny pill indicators for success/warning/error/info states.
- **`SectionHeader`**: Reusable pattern for Titling sections (Title + Subtitle + Trailing action).
- **`LoadingIndicator`**: Standardized sizing for the `CircularProgressIndicator`.
- **`SkeletonLoader`**: Elegant `1500ms` fading shimmer to replace loading states.
- **`BottomSheet` (`showMedicalBottomSheet`)**: A specialized modal builder producing a glass-styled, draggable bottom sheet.
- **`Dialog` (`showMedicalDialog`)**: A scale/fade animated, glass-backed popup dialog.
- **`SnackBar` (`showMedicalSnackBar`)**: A floating, elegantly animated alert system.
- **`FloatingActionCard`**: Wraps `GlassCard` to serve as a floating bottom action panel (e.g., Map controls).
- **`EmptyStateWidget` / `ErrorStateWidget`**: Beautiful, centralized placeholders for empty lists or failed loads.
- **`RedBankScaffold`**: The master app shell handling the gradient background and notch safe-areas.

---

## 8. Accessibility Guidelines

- **Touch Targets:** All interactive elements (`IconButton`, `PrimaryButton`) enforced at a minimum of `48x48dp`.
- **High Contrast:** Text colors algorithmically verified against backgrounds (WCAG AA).
- **Reduced Motion:** Provide flags to fall back to instant transitions if requested by the OS.
