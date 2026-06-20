{ pkgs, ... }: {
  # Used for backwards compatibility. Read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  # GUI apps are installed at the system level so nix-darwin creates proper
  # /Applications/Nix Apps aliases that Spotlight and Launchpad can index.
  environment.systemPackages =
    (import ../../programs/gui-apps.nix pkgs)
    ++ (with pkgs; [
      jetbrains.idea
      jetbrains.rust-rover
      visualvm
    ]);

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Tailscale VPN: installs the package and runs the tailscaled daemon.
  services.tailscale.enable = true;

  # The platform the configuration will be used on.
  system.primaryUser = "aoli";

  # Map Caps Lock to Left Control.
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  # Use F1, F2, etc. as standard function keys (no need to hold Fn).
  system.defaults.NSGlobalDomain."com.apple.keyboard.fnState" = true;

  # Automatically hide and show the Dock.
  system.defaults.dock.autohide = true;

  # Tap to click on the trackpad (no need to physically press).
  system.defaults.trackpad.Clicking = true;
  system.defaults.NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;

  # Three-finger drag.
  system.defaults.trackpad.TrackpadThreeFingerDrag = true;
}
