{ pkgs, inputs }:
let
  upstream = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.chatgpt;
  unwrapped = upstream.unwrapped.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      ${pkgs.python3}/bin/python ${./patch-executor-copy.py} "$out/lib/chatgpt/resources/app.asar"
    '';
  });
in
if pkgs.stdenv.hostPlatform.isLinux then
  (upstream.override { chatgpt-unwrapped = unwrapped; }).overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      # Repair copies left by older versions before the app tries to replace them.
      wrapProgram "$out/bin/chatgpt" --run '
        plugin_root="''${XDG_CONFIG_HOME:-$HOME/.config}/Codex/executor-plugins"
        if [ -d "$plugin_root" ] && [ ! -L "$plugin_root" ]; then
          ${pkgs.coreutils}/bin/chmod -R u+w "$plugin_root"
        fi
      '
    '';
  })
else
  upstream
