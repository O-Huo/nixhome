# Global instructions for AI coding agents (Claude Code and Codex),
# maintained from a single AGENTS.md source.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  configDir =
    if config.home.preferXdgDirectories then
      "${lib.removePrefix config.home.homeDirectory config.xdg.configHome}/codex"
    else
      ".codex";
  configFile = "${configDir}/config.toml";
  python = pkgs.python3.withPackages (ps: [ ps.tomlkit ]);
in
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
    # Codex persists folder trust and interactive settings in this file.
    # Keep the generated source, but merge it into a regular file at activation.
    "${configFile}".enable = false;
    ".claude/CLAUDE.md".source = ./AGENTS.md;
  };

  # Run before linkGeneration so an existing managed symlink can be read before
  # Home Manager removes it. Managed keys win; other settings survive switches.
  home.activation.codexWritableConfig =
    lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ]
      ''
        run ${python}/bin/python ${./merge-codex-config.py} \
          ${lib.escapeShellArg (toString config.home.file.${configFile}.source)} \
          ${lib.escapeShellArg "${config.home.homeDirectory}/${configFile}"}
      '';
}
