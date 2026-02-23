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
      lsp = {
        rust-analyzer = {
          binary = {
            path_lookup = true;
          };
        };
      };
      hour_format = "hour24";
      vim_mode = true;
      base_keymap = "JetBrains";
      ui_font_size = 16;
      buffer_font_size = 16;
      auto_save = "on_focus_change";
    };
  };
}
