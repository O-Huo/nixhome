{
  lib,
  isLinux ? false,
  isHeadless ? false,
  ...
}:
{
  programs = {
    bat.enable = true;

    eza.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    home-manager.enable = true;

    fish = {
      enable = true;
      interactiveShellInit = ''
        set -g fish_greeting
      '';
    };
  };

  # Keep the profile declarative while allowing Rime to save its user dictionary.
  xdg.configFile."fcitx5/profile" = lib.mkIf (isLinux && !isHeadless) {
    force = true;
    text = ''
      [Groups/0]
      Name=Default
      Default Layout=us
      DefaultIM=rime

      [Groups/0/Items/0]
      Name=keyboard-us
      Layout=

      [Groups/0/Items/1]
      Name=rime
      Layout=

      [GroupOrder]
      0=Default
    '';
  };

  home.file = {
    ".byobu/.tmux.conf" = {
      source = ../dotfiles/tmux.conf;
      force = true;
    };
    ".config/jjui/config.toml" = {
      source = ../dotfiles/jjui.toml;
      force = true;
    };
    ".local/share/fcitx5/rime/default.custom.yaml" = {
      source = ../dotfiles/rime.yaml;
      force = true;
    };
  };
}
