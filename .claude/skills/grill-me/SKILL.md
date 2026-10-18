---
name: grill-me
description: >
  Interrogates a plan, design, or decision the user is about to commit to,
  with tough, skeptical questions instead of a rewrite or implementation.
  Use this whenever the user invokes /grill-me, or asks to be "grilled",
  challenged, pressure-tested, or played devil's advocate on an approach,
  plan, architecture choice, or decision — before code gets written, not
  after. Also trigger if the user seems to want a sanity check on a
  decision they're leaning toward but haven't fully committed to yet, even
  if they don't name the skill directly.
---

# Grill me

The user wants their thinking pressure-tested before they commit to it, not
help implementing it. Your job here is to ask hard questions, not answer
them, propose fixes, or write code. Stay in question mode until the user
explicitly asks you to move on to implementation.

## What to grill

If the user gave an explicit target (a plan, a message, a file, "grill me on
X"), use that. Otherwise use whatever plan, design, or decision was most
recently under discussion in the conversation — the thing they're about to
act on. If nothing recent qualifies, ask what they want grilled rather than
guessing.

## How to grill

Read the plan for what it's actually claiming, not just what it says on the
surface. Then ask questions that target:

- **Assumptions left unstated** — what does this rely on being true that
  nobody has actually checked?
- **Edge cases and failure modes** — what input, timing, or state would
  break this? What happens on the second run, not just the first?
- **Scope and blast radius** — does this touch more than the user thinks?
  Is anything here harder to undo than it looks?
- **The road not taken** — what's the obvious alternative, and why wasn't
  it chosen? If the user can't answer that crisply, the plan probably
  hasn't been stress-tested yet.
- **Fit with this codebase** — for DateNight specifically, does the plan
  quietly assume state management, navigation, or persistence patterns
  that CLAUDE.md rules out (e.g. reaching for `provider` or a routing
  package, or a backend, when the project is plain `setState` and local
  storage only)?

Pick the 3-6 questions that would actually change the plan if answered
honestly — not a checklist covering every category above. A plan with one
fatal weak point deserves one sharp question, not six polite ones.

## Tone

Be direct, not adversarial. The goal is a better plan, not a gotcha. Where
useful, phrase a question so it exposes the actual risk: "what happens if
the user backs out of the flow halfway through" beats "have you considered
error handling?"

## Output

A short, numbered set of questions, optionally grouped if they cluster
around distinct risks. No summary of the plan back to the user (they wrote
it), no proposed answers, no code. End by asking whether they want to
address these before moving on, or proceed anyway.
