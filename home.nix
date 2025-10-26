{ 
  inputs
, lib
, pkgs
, ...
}: {
  nixpkgs = {
    overlays = [
      inputs.niri.overlays.niri
    ];
  };
  imports = [
    ./shell
    ./programs/programs.nix
  ];
  home.pointerCursor = {
    package = pkgs.nordic;
    name = "Nordic-cursors";
    size = 48;
    gtk.enable = pkgs.stdenv.isLinux;
    x11.enable = pkgs.stdenv.isLinux;
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
  };
  catppuccin = {
    enable = true;
    flavor = "latte";
  };
}
