
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
      keybinds = {
        unbind = "Ctrl b";
      };
    };
  };
}
