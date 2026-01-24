{
  inputs,
  lib,
  pkgs,
  isLinux ? false,
  ...
}:
{
  nixpkgs = {
    overlays = lib.optional isLinux inputs.niri.overlays.niri;
  };
  imports = [
    ./shell
    ./programs/programs.nix
  ];
  home.pointerCursor = lib.mkIf isLinux {
    package = pkgs.nordic;
    name = "Nordic-cursors";
    size = 36;
    gtk.enable = true;
    x11.enable = true;
  };
  home = {
    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you
    # do want to update the value, then make sure to first check the Home
    # Manager release notes.
    stateVersion = "24.11"; # Please read the comment before changing.
    sessionVariables = {
    };
  };
  catppuccin = {
    enable = true;
    flavor = "latte";
  };
}
