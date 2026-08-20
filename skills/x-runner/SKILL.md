---
name: x-runner
description: Use when running install/dev/build/test/lint/typecheck commands in ANY JavaScript/TypeScript project on this machine, instead of detecting npm/yarn/pnpm/bun manually. Triggers on "run the dev server", "install deps", "run tests", "build the project", "run the linter", or any package-manager command in a JS/TS repo.
metadata:
  short-description: Universal JS/TS package-manager runner
---

# x-runner

This machine has a universal command runner, `x` (repo: `~/code/private/dotfiles/scripts/x`,
installed as `bin/x`, on `$PATH`). It auto-detects the package manager from
the lockfile (bun/pnpm/yarn/npm) and maps short aliases to the right command.

Prefer `x <alias>` over manually running `npm run`, `yarn`, `pnpm`, or `bun`
directly — it works the same way across every project regardless of which
package manager that project uses.

## Aliases

| Alias | Meaning |
|-------|---------|
| `x i` | install deps |
| `x d` | dev server (`dev` → `start`) |
| `x b` | build |
| `x t` | test |
| `x l` | lint |
| `x c` | typecheck (`check` → `ts:check` → `type-check`) |
| `x add <pkg>` | add a package |
| `x rm <pkg>` | remove a package |
| `x <script>` | run any other `package.json` script directly |
| `x` (no args) | list all available aliases/scripts for this project |

If a project has a `.xrc.json`, its aliases override the defaults — run
`x` with no args first if unsure what's available.

Fall back to the package manager directly only if `x` isn't installed or the
project isn't a Node/JS project.
