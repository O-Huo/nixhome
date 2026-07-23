# Global preferences

## Version control
- I use jujutsu (jj), not git, for version control. Use `jj` commands
  (e.g. `jj st`, `jj commit`, `jj new`) instead of git equivalents.
  The repo may be colocated, but treat jj as the source of truth.
- For parallel work on multiple changes, use `jj workspace` (e.g.
  `jj workspace add`) instead of git worktrees or cloning the repo again.
- Do not commit or create PRs unless explicitly instructed to do so

## Dependencies
- I use Nix for dependency management. Don't suggest installing tools
  via brew/apt/pip globally — add them to the flake/shell.nix instead.
- Use `nix-shell` to enter the dependency environment and run commands
  (e.g. `nix-shell --run "cmd"`). Assume all build/test/dev commands
  run inside a nix-shell (or via direnv).
