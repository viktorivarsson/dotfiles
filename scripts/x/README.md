# x - Universal Package Runner

A universal command runner for Node.js projects that works with any package manager (bun, pnpm, yarn, npm).

## Installation

The `x` command is installed automatically via `setup-dotfiles.sh`.

To install manually:

```bash
deno install --allow-read --allow-run --allow-env --global ./scripts/x/x.ts
```

## Features

- **Package manager detection**: Automatically detects bun, pnpm, yarn, or npm from lockfiles
- **Consistent aliases**: Use the same commands across all your projects
- **Fallback chains**: Try multiple script names in sequence
- **Project overrides**: Customize aliases per project
- **Pass-through**: Run any package manager command or script directly

## Default Aliases

| Alias | Commands | Description |
|-------|----------|-------------|
| `i` | `install` | Install dependencies |
| `d` | `dev` → `start` | Run development server |
| `b` | `build` | Build project |
| `t` | `test` | Run tests |
| `l` | `lint` | Run linter |
| `c` | `check` → `ts:check` → `type-check` | Run type checking |
| `ui` | `update --interactive` | Interactive dependency update |
| `add` | `add` | Add package |
| `rm` | `remove` | Remove package |

## Usage

```bash
# List all aliases and package scripts
x

# Run an alias
x d              # Runs 'dev' or 'start'
x t              # Runs 'test'

# Run a script directly
x my-custom-script

# Pass arguments
x d --watch

# Run package manager commands
x add lodash
x rm lodash
x version
```

## Project Overrides

Create a `.xrc.json` in your project root to override or extend aliases:

```json
{
  "aliases": {
    "dev": [
      {"cmd": "dev:custom"}
    ]
  }
}
```

Project aliases are prioritized over global aliases.

## Configuration

Global config is located at `~/.config/x/config.json`. You can customize aliases by editing this file.

## How It Works

1. **Alias resolution**: If the command is an alias, try each fallback in order
2. **Script-first**: If a script exists in `package.json`, run it with `<pm> run <script>`
3. **Executable fallback**: If no script exists, run `<pm> <cmd>` directly
4. **Pass-through**: Unknown commands are passed to the package manager

## Examples

### Bun project with `dev` script
```bash
$ x d
Running: bun run dev
```

### Bun project with no `dev` script but `start` script
```bash
$ x d
Running: bun run start
```

### Bun project with no scripts (uses built-in)
```bash
$ x t
Running: bun test
```

### Add a package
```bash
$ x add lodash
Running: bun add lodash
```

## Similar Tools

If you like `x`, you might also enjoy:
- `npr` - Interactive script runner (`scripts/npr/npr.ts`)
- `npx` - Package executables (built into npm)
