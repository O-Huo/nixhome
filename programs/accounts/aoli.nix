{
  lib,
  pkgs,
  isHeadless ? false,
  ...
}:
{
  # Explicitly enable Atuin for aoli
  programs.atuin.enable = lib.mkDefault true;
  home = {
    username = "aoli";
    homeDirectory = if (pkgs.stdenv.isDarwin) then "/Users/aoli" else "/home/aoli";
  };
  # GUI apps; on macOS these are installed via nix-darwin instead so they show
  # up in Spotlight/Launchpad, so only add them to the profile on Linux.
  home.packages = lib.optionals (!pkgs.stdenv.isDarwin && !isHeadless) (with pkgs; [
    jetbrains.idea
    jetbrains.rust-rover
    visualvm
  ]);

  programs.git = {
    enable = true;
    settings.user = {
      name = "aoli-al";
      email = "aoli.al@hotmail.com";
    };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "aoli-al";
        email = "aoli.al@hotmail.com";
      };
    };
  };
}
