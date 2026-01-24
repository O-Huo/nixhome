{ lib, pkgs, ... }:
{
  # Explicitly enable Atuin for aoli
  programs.atuin.enable = lib.mkDefault true;
  home = {
    username = "aoli";
    homeDirectory = if (pkgs.stdenv.isDarwin) then "/Users/aoli" else "/home/aoli";
  };
  home.packages = with pkgs; [
    (if pkgs.stdenv.isDarwin then jetbrains.idea else jetbrains.idea-oss)
  ];

  programs.git = {
    enable = true;
    userName = "aoli-al";
    userEmail = "aoli.al@hotmail.com";
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
