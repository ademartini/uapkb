---
name: big-buttons
description: Add large, accessible CTA buttons to the UAPKB UI using Tailwind and Next.js patterns. Use when the user asks for big buttons, large CTAs, prominent action buttons, or touch-friendly controls on pages and components.
---

# Big Buttons

Add prominent, touch-friendly buttons that match this repo's stack (Next.js App Router, Tailwind CSS v4, TypeScript strict).

## When to use

- User asks for "big buttons", large CTAs, or prominent actions
- A page needs a clear primary action (submit, continue, get started)
- Touch targets must meet accessibility minimums (44×44px)

## Component location

| File                        | Purpose                            |
| --------------------------- | ---------------------------------- |
| `lib/big-button.tsx`        | Reusable `BigButton` component     |
| `tests/big-button.test.tsx` | Component tests (not under `app/`) |

Import via `@/lib/big-button`. Do not add `*.test.tsx` under `app/`.

## BigButton spec

**Sizing (non-negotiable):**

- Minimum touch target: `min-h-11 min-w-11` (44px)
- Default padding: `px-8 py-4`
- Text: `text-lg font-semibold`
- Full-width option: `w-full` when stacked in forms or mobile layouts

**Visual defaults:**

- Primary: solid foreground on background — `bg-foreground text-background`
- Secondary: outline — `border-2 border-foreground text-foreground bg-transparent`
- Shape: `rounded-xl`
- Hover: `hover:opacity-90`
- Active: `active:scale-[0.98]`
- Focus: `focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-foreground`

**Behavior:**

- Render `<button>` for actions; use Next.js `<Link>` styled with the same classes for navigation
- Support `disabled` with `disabled:opacity-50 disabled:pointer-events-none`
- Pass through standard `button` props (`type`, `onClick`, `aria-*`)

## Implementation workflow

```
1. Create lib/big-button.tsx
2. Add tests/big-button.test.tsx
3. Use on the target page or component
4. Run pnpm check
```

### Step 1: Create the component

```tsx
import type { ButtonHTMLAttributes } from "react";

type BigButtonVariant = "primary" | "secondary";

type BigButtonProps = ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: BigButtonVariant;
  fullWidth?: boolean;
};

const variantClasses: Record<BigButtonVariant, string> = {
  primary: "bg-foreground text-background hover:opacity-90",
  secondary: "border-2 border-foreground bg-transparent text-foreground hover:bg-foreground/5",
};

export function BigButton({
  variant = "primary",
  fullWidth = false,
  className = "",
  children,
  ...props
}: BigButtonProps) {
  return (
    <button
      type="button"
      className={[
        "inline-flex min-h-11 min-w-11 items-center justify-center rounded-xl px-8 py-4 text-lg font-semibold transition",
        "focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-foreground",
        "active:scale-[0.98] disabled:pointer-events-none disabled:opacity-50",
        variantClasses[variant],
        fullWidth ? "w-full" : "",
        className,
      ]
        .filter(Boolean)
        .join(" ")}
      {...props}
    >
      {children}
    </button>
  );
}
```

For navigation links, export a `bigButtonClassName` helper or duplicate the class string on `<Link className={...}>` — keep classes in one place.

### Step 2: Add tests

Minimum coverage in `tests/big-button.test.tsx`:

- Renders children and is discoverable by role (`button`)
- Applies `disabled` state
- Renders both `primary` and `secondary` variants without crashing

Follow existing patterns in `tests/page.test.tsx` (`@testing-library/react`, Vitest).

### Step 3: Place on the page

Example usage in a page or section:

```tsx
import { BigButton } from "@/lib/big-button";

<BigButton type="submit">Get started</BigButton>
<BigButton variant="secondary">Learn more</BigButton>
```

For stacked mobile CTAs, wrap in a flex column with `gap-4` and use `fullWidth`.

### Step 4: Verify

```bash
pnpm check
```

## Layout guidance

- Group related big buttons with `flex flex-col gap-4 sm:flex-row sm:gap-6`
- Place the primary CTA first in DOM order (visual order can differ with flex)
- One primary button per viewport section; additional actions use `secondary`
- Do not shrink buttons below `min-h-11` to fit cramped layouts — adjust layout instead

## Do not

- Add a component library (shadcn, MUI) just for buttons
- Use `<div onClick>` instead of `<button>` or `<Link>`
- Put tests under `app/`
- Skip focus styles or `disabled` handling
- Use inline styles when Tailwind classes suffice

## Additional resources

For broader UI quality (typography, composition), see the `ce-frontend-design` skill after implementing the button.
