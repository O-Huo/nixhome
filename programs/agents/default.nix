# Global instructions for AI coding agents (Claude Code and Codex),
# maintained from a single AGENTS.md source.
{
  programs.codex = {
    enable = true;
    context = ./AGENTS.md;
    settings.tui.keymap.chat.edit_queued_message = [
      "alt-q"
      "shift-left"
    ];
  };

  home.file = {
    ".claude/CLAUDE.md".source = ./AGENTS.md;
  };
}
