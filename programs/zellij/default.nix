
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
      keybinds = {
        unbind = "Ctrl b";
      };
    };
  };
}
