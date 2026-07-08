pkgs:
pkgs.thunderbird.override {
  extraPolicies = {
    ExtensionSettings = {
      "gconversation@xulforum.org" = {
        installation_mode = "normal_installed";
        install_url = "https://addons.thunderbird.net/thunderbird/downloads/latest/gmail-conversation-view/latest.xpi";
      };
    };
    Preferences = {
      "mailnews.default_sort_type" = {
        Value = 18; # by date
        Status = "user";
      };
      "mailnews.default_sort_order" = {
        Value = 2; # descending
        Status = "user";
      };
    };
  };
}
