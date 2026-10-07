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
      "mailnews.mark_message_read.auto" = {
        Value = true;
        Status = "user";
      };
      "mailnews.mark_message_read.delay" = {
        Value = false; # mark as read immediately when displayed
        Status = "user";
      };
      "mailnews.start_page.enabled" = {
        Value = false;
        Status = "user";
      };
      "mail.pane_config.dynamic" = {
        Value = 1; # wide layout: message below both folder and message lists
        Status = "user";
      };
      "mail.threadpane.listview" = {
        Value = 0; # cards keep the message list readable in narrow windows
        Status = "user";
      };
      "mail.threadpane.cardsview.rowcount" = {
        Value = 2;
        Status = "user";
      };
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
