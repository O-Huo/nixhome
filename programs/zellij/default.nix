
{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    zellij
  ];

  programs.zellij = {
    enable = true;
    settings = {
      show_startup_tips = false;
      default_shell = "fish";
      advanced_mouse_actions = false;
      # Alacritty cannot display Kitty graphics. Let Yazi fall back to
      # Überzug++ on Wayland (also used for rendered PDF pages).
      support_kitty_graphics_protocol = false;
      keybinds = {
        unbind = "Ctrl b";
      };
    };
  };
}
