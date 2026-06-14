{ pkgs, lib, inputs, config, ... }: {
  imports = [
    inputs.noctalia.homeModules.default
    ./bindings.nix
  ];
  programs.noctalia = {
    enable = true;
    settings = {
      location = {
        auto_locate = true;
      };
      dock = {
        enabled = true;
        auto_hide = true;
        reserve_space = false;
      };
      bar = {
        density = "compact";
        position = "top";
      };
      theme = {
        source = "builtin";
        builtin = "Catppuccin";
        mode = "light";
      };
      wallpaper = {
        enabled = true;
        directory = ./imgs;
        fill_mode = "crop";
        fill_color = "#000000";
      };
    };
  };
  home.packages = with pkgs; [
    hypridle
    grim
    slurp
    wl-clipboard
    xwayland-satellite
    nordic
  ];

  xdg = {
    enable = pkgs.stdenv.isLinux;
    configFile."mimeapps.list" = lib.mkIf pkgs.stdenv.isLinux {
      force = true;
    };
    mime.enable = pkgs.stdenv.isLinux;
    mimeApps = {
      enable = pkgs.stdenv.isLinux;
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "application/xhtml+xml" = "firefox.desktop";
      };
    };
    portal = {
      enable = pkgs.stdenv.isLinux;
      extraPortals = [
        pkgs.xdg-desktop-portal-gnome
      ];
    };
  };


  services = {
    hypridle = {
      enable = pkgs.stdenv.isLinux;
      settings = {
        general = {
          after_sleep_cmd = "${lib.getExe pkgs.niri-unstable} msg action power-off-monitors";
          before_sleep_cmd = "noctalia msg session lock";
          ignore_dbus_inhibit = false;
          lock_cmd = "noctalia msg session lock";
        };
        listener = [
          {
            timeout = 120;  # Reduce screen lock timeout for battery saving
            on-timeout = "noctalia msg session lock";
          }
          {
            timeout = 150;  # Turn off display sooner
            on-timeout = "${lib.getExe pkgs.niri-unstable} msg action power-off-monitors";
            on-resume = "${lib.getExe pkgs.niri-unstable} msg action power-on-monitors";
          }
        ];
      };
    };
  };


  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;

    settings = {
      window-rules = [
        {
          matches = [{ app-id = "^alacritty-yazi$"; }];
          open-floating = true;
        }
      ];
      spawn-at-startup = [
          {
            command = ["fcitx5" "-d"];
          }
          {
            command = ["blueman-applet"];
          }
          {
            command = ["nm-applet" "--indicator"];
          }
          {
            command = ["noctalia"];
          }
        ];
    };
  };
}
