{
  pkgs,
  config,
  starship-jj,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./nixvim/nixvim.nix
    ./vscode/vscode.nix
    ./gh
    ./browserpass
    ./atuin
    ./starship
    ./zellij
    ./alacritty
    ./yazi
    ./zed
    ./thunderbird
  ];

  home.packages = [
    starship-jj
    pkgs.gnupg
    pkgs.yubikey-manager
    pkgs.awscli2
    pkgs.nix-output-monitor
    pkgs.qemu
    pkgs.zed-editor
    pkgs.ripgrep
    pkgs.cachix
    pkgs.btop
    pkgs.codex
    pkgs.pciutils
    pkgs.alacritty
    # pkgs.claude-code
    pkgs.nix-index
    pkgs.nixd
    pkgs.killall
    pkgs.dive
    pkgs.podman-tui
    pkgs.yazi
    pkgs.jujutsu
    pkgs.jjui
    pkgs.starship
    pkgs.git-remote-hg
    pkgs.unzip
    pkgs.fish
    pkgs.browserpass
    pkgs.pass
    pkgs.nil
    pkgs.cloc
    pkgs.fastfetch
    pkgs.vscode
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
    pkgs.texliveFull
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
  ++ pkgs.lib.optionals (pkgs.stdenv.isLinux) (import ./gui-apps.nix pkgs)
  ++ pkgs.lib.optionals (pkgs.stdenv.isLinux) [
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
  ]
  ++ pkgs.lib.optionals (pkgs.stdenv.isDarwin) [
  ];
}
