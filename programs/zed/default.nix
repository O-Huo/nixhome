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
    };
  };
}
