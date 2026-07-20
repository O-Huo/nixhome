{
  pkgs,
  config,
  lib,
  starship-jj,
  isHeadless ? false,
  ...
}:
{
  imports = [
    ./nixvim/nixvim.nix
    ./gh
    ./atuin
    ./starship
    ./zellij
    ./yazi
  ]
  ++ lib.optionals (!isHeadless) [
    ./vscode/vscode.nix
    ./browserpass
    ./alacritty
    ./zed
    ./thunderbird
  ];

  home.packages = [
    starship-jj
    pkgs.gnupg
    pkgs.yubikey-manager
    pkgs.awscli2
    pkgs.nix-output-monitor
    pkgs.ripgrep
    pkgs.cachix
    pkgs.btop
    pkgs.codex
    pkgs.pciutils
    # pkgs.claude-code
    pkgs.nix-index
    pkgs.nixd
    pkgs.killall
    pkgs.dive
    pkgs.lazydocker
    pkgs.yazi
    pkgs.jujutsu
    pkgs.jjui
    pkgs.starship
    pkgs.git-remote-hg
    pkgs.unzip
    pkgs.fish
    pkgs.pass
    pkgs.nil
    pkgs.cloc
    pkgs.fastfetch
    pkgs.gh
    pkgs.git
    pkgs.git-lfs
    pkgs.htop
    pkgs.nerd-fonts.fira-code
    pkgs.fira-code
    pkgs.fira-code-symbols
    pkgs.nh
    (pkgs.python3.withPackages (
      ps: with ps; [
        numpy
        matplotlib
        scipy
        seaborn
        ipython
      ]
    ))
    pkgs.wget
    pkgs.atuin
    (pkgs.symlinkJoin {
      name = config.home.username;
      paths = [
        (pkgs.writers.writePython3Bin "shell" {
          libraries = [
            pkgs.python3Packages.gitpython
          ];
        } ./bin/shell.py)
      ];
    })
  ]
  ++ pkgs.lib.optionals (!isHeadless) [
    pkgs.qemu
    pkgs.zed-editor
    pkgs.alacritty
    pkgs.browserpass
    pkgs.vscode
    pkgs.texliveFull
  ]
  ++ pkgs.lib.optionals (pkgs.stdenv.isLinux && !isHeadless) (import ./gui-apps.nix pkgs)
  ++ pkgs.lib.optionals (pkgs.stdenv.isLinux && !isHeadless) [
    pkgs.winboat
    pkgs.gnupg
    pkgs.seahorse
    pkgs.gnome-keyring
    pkgs.xdg-desktop-portal-gnome
    pkgs.nautilus
    pkgs.r2modman
    pkgs.dragon-drop
    pkgs.rr
    pkgs.kdePackages.okular
    pkgs.usbutils
  ]
  ++ pkgs.lib.optionals (pkgs.stdenv.isDarwin) [
  ];
}
