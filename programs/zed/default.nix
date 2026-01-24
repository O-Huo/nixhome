{
  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "toml"
      "rust"
      "latex"
    ];
    userSettings = {
      hour_format = "hour24";
      vim_mode = true;
      base_keymap = "JetBrains";
      ui_font_size = 16;
      buffer_font_size = 16;
      auto_save = "on_focus_change";
    };
  };
}
