{ pkgs, ... }: {
  wayland.windowManager.hyprland.extraConfig = "
    monitor=eDP-1, 1920x1200@60, 0x0, 1
    ";
  
  services.hypridle.settings.listener = [
    {
      timeout = 600;  # Suspend after 10 minutes (only on jex)
      on-timeout = "systemctl suspend";
    }
  ];
  programs.niri.settings = {
    cursor = {
        theme = "Nordic-cursors";
        size = 48;
      };
    outputs."eDP-1" = {
      scale = 1;
      mode = {
        width = 1920;
        height = 1200;
        refresh = 59.950;
      };
    };
    outputs."ASUSTek COMPUTER INC PG32UCDM S3LMQS114886" = {
      scale = 1.5;
      mode = {
        width = 3840;
        height = 2160;
        refresh = 119.880;
      };
    };
  };
}
