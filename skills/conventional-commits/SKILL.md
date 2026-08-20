---
name: conventional-commits
description: Use whenever writing a git commit message on any project on this machine, in either Claude Code or Codex. Format commits as Conventional Commits unless the project's own git log already follows a different convention — match the repo you're in over this default.
metadata:
  short-description: Write commit messages as Conventional Commits
---

# Conventional Commits

Default commit message format on this machine, for both Claude Code and
Codex. Check `git log --oneline -20` first — if a project already has its
own established convention, follow that instead of this one.

## Subject line

`<type>(<scope>): <imperative summary>` — `<scope>` is optional.

Types: `feat`, `fix`, `refactor`, `perf`, `docs`, `test`, `chore`, `build`, `ci`, `style`, `revert`

- Imperative mood: "add", "fix", "remove" — not "added", "adds", "adding"
- ≤50 chars when possible, hard cap 72
- No trailing period
- Breaking change: append `!` before the colon, e.g. `feat(api)!: ...`

## Body

Only when the subject alone doesn't explain the *why*:

- Skip entirely when the subject is self-explanatory
- Wrap at 72 chars, bullets with `-`
- Always include a body for: breaking changes, security fixes, data
  migrations, reverts — future debuggers need the context
- Footer for breaking changes: `BREAKING CHANGE: <what breaks, migration path>`
- Reference issues at the end: `Closes #42`, `Refs #17`

## Examples

```
feat(api): add GET /users/:id/profile

Mobile client needs profile data without the full user payload
to reduce bandwidth on cold-launch screens.

Closes #128
```

```
feat(api)!: rename /v1/orders to /v1/checkout

BREAKING CHANGE: clients on /v1/orders must migrate to /v1/checkout
before 2026-06-01. Old route returns 410 after that date.
```
