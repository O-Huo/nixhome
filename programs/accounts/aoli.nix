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
