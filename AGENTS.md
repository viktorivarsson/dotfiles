# Agent Guidelines for Dotfiles Repository

## Build/Lint/Test Commands

### Lua (Neovim config)
- **Format**: `stylua .config/nvim/` (2-space indent, 120 column width)
- **Check**: No linting configured - focus on manual review

### TypeScript/Deno (scripts)
- **Run**: `deno run scripts/npr/npr.ts`
- **Install**: `deno install --global ./scripts/npr/npr.ts`
- **Format**: `deno fmt scripts/`
- **Lint**: `deno lint scripts/`

### Shell Scripts
- **Check**: `shellcheck bin/ scripts/` (if available)

## Code Style Guidelines

### Lua
- 2-space indentation, 120 character line limit
- Use `local` for variable declarations
- Follow LazyVim patterns for Neovim configuration
- Modular structure with separate files for different concerns

### TypeScript/Deno
- Use Deno standard library imports with full URLs
- Async/await preferred over promises
- Type annotations required for function parameters and returns
- Error handling with try/catch blocks

### General
- Modular configuration over monolithic files
- Comments should explain "why" not "what"
- Use absolute paths in scripts when possible
- Follow existing naming conventions (kebab-case for files, camelCase for variables)

## Repository Structure
- `.config/`: Application configurations (nvim, ghostty, brewfile)
- `bin/`: Executable scripts in PATH
- `scripts/`: Development utilities and tools
- Root: Shell configuration (.zshrc, .tmux.conf, .vimrc)