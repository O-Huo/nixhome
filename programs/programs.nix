{ pkgs, config, ... }: {
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./nixvim/nixvim.nix
    ./vscode/vscode.nix
    ./gh
    ./browserpass
    ./atuin
    ./starship
    ./tmux
  ];

  home.packages =
    [
      pkgs.btop
      pkgs.codex
      pkgs.claude-code
      pkgs.nix-index
      pkgs.killall
      pkgs.dive
      pkgs.podman-tui
      pkgs.yazi
      pkgs.jujutsu
      pkgs.jjui
      pkgs.starship
      pkgs.git-remote-hg
      pkgs.unzip
      pkgs.firefox
      pkgs.qtpass
      pkgs.fish
      pkgs.browserpass
      pkgs.pass
      pkgs.nil
      pkgs.cloc
      pkgs.fastfetch
      pkgs.vscode
      pkgs.discord
      pkgs.gh
      pkgs.git
      pkgs.git-lfs
      pkgs.obsidian
      pkgs.byobu
      pkgs.htop
      pkgs.nerd-fonts.fira-code
      pkgs.fira-code
      pkgs.fira-code-symbols
      pkgs.slack
      pkgs.zoom-us
      (pkgs.python3.withPackages (ps:
        with ps; [
          numpy
          matplotlib
          scipy
          seaborn
          ipython
        ]))
      pkgs.texliveFull
      pkgs.wget
      pkgs.telegram-desktop
      pkgs.atuin
      (pkgs.symlinkJoin {
        name = config.home.username;
        paths = [
          (pkgs.writers.writePython3Bin "shell"
            {
              libraries = [
                pkgs.python3Packages.gitpython
              ];
            }
            ./bin/shell.py)
        ];
      })
    ]
    ++ pkgs.lib.optionals (pkgs.stdenv.isLinux) [
      pkgs.gnupg
      pkgs.seahorse
      pkgs.gnome-keyring
    ]
    ++ pkgs.lib.optionals (pkgs.stdenv.isDarwin) [
      pkgs.alt-tab-macos
    ];
}
