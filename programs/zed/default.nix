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
      vim_mode = true;
      base_keymap = "JetBrains";
      ui_font_size = 16;
      buffer_font_size = 16;
      autosave = "on_focus_change";
      format_on_save = "off";
      soft_wrap = "editor_width";
    };
  };
}
