# GUI apps shared by the Linux home-manager profile and the nix-darwin system.
# On macOS these are installed via nix-darwin (environment.systemPackages) so
# they get proper /Applications/Nix Apps aliases that Spotlight/Launchpad index;
# on Linux they stay in the home-manager profile.
pkgs: with pkgs; [
  google-chrome
  firefox
  qtpass
  vesktop
  obsidian
  slack
  signal-desktop
  telegram-desktop
  zoom-us
]
