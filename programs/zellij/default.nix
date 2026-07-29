
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
      keybinds = {
        unbind = "Ctrl b";
      };
    };
  };
}
