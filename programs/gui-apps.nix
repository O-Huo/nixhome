# GUI apps shared by the Linux home-manager profile and the nix-darwin system.
# On macOS these are installed via nix-darwin (environment.systemPackages) so
# they get proper /Applications/Nix Apps aliases that Spotlight/Launchpad index;
# on Linux they stay in the home-manager profile.
pkgs: with pkgs; [
  # Thunderbird with the Conversations add-on installed declaratively via the
  # enterprise ExtensionSettings policy (the same mechanism the Firefox wrapper
  # uses). "normal_installed" pins the add-on so users can't remove it.
  (thunderbird.override {
    extraPolicies = {
      ExtensionSettings = {
        "gconversation@xulforum.org" = {
          installation_mode = "normal_installed";
          install_url = "https://addons.thunderbird.net/thunderbird/downloads/latest/gmail-conversation-view/latest.xpi";
        };
      };
    };
  })
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
