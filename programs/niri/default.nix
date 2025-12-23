{ pkgs, lib, inputs, config, ... }: {
  imports = [
    inputs.noctalia.homeModules.default
    ./bindings.nix
  ];
  programs.noctalia-shell = {
    enable = true;
    settings = {
      dock = {
        enabled = true;
        displayMode = "auto_hide";
      };
      bar = {
        density = "compact";
        position = "top";
        showCapsule = false;
        widgets = {
          left = [
            {
              id = "ControlCenter";
              useDistroLogo = true;
            }
            {
              id = "WiFi";
            }
            {
              id = "Bluetooth";
            }
            {
              id = "ActiveWindow";
            }
          ];
          center = [
            {
              hideUnoccupied = false;
              id = "Workspace";
              labelMode = "none";
            }
          ];
          right = [
            {
              alwaysShowPercentage = false;
              id = "Battery";
              warningThreshold = 30;
            }
            {
              id = "SystemMonitor";
            }
            {
              id = "Tray";
              blacklist = [ "*Bluetooth*" ];
            }
            {
              id = "NotificationHistory";
            }
            {
              formatHorizontal = "HH:mm";
              formatVertical = "HH mm";
              id = "Clock";
              useMonospacedFont = true;
              usePrimaryColor = true;
            }
          ];
        };
      };
      colorSchemes = {
        predefinedScheme = "Catppuccin";
        darkMode = false;
      };
      wallpaper = {
        enabled = true;
        directory = ./imgs;
        enableMultiMonitorDirectories = false;
        setWallpaperOnAllMonitors = true;
        defaultWallpaper = "";
        fillMode = "crop";
        fillColor = "#000000";
        randomEnabled = true;
        randomIntervalSec = 30000;
        transitionDuration = 1500;
        transitionType = "random";
        transitionEdgeSmoothness = 0.05;
      };
      appLauncher = {
        enableClipboardHistory = false;
        position = "center";
        backgroundOpacity = 1;
        pinnedExecs = [ ];
        useApp2Unit = false;
        sortByMostUsed = true;
        terminalCommand = "xterm -e";
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
          before_sleep_cmd = "noctalia-shell ipc call lockScreen lock";
          ignore_dbus_inhibit = false;
          lock_cmd = "noctalia-shell ipc call lockScreen lock";
        };
        listener = [
          {
            timeout = 120;  # Reduce screen lock timeout for battery saving
            on-timeout = "noctalia-shell ipc call lockScreen lock";
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
          matches = [{ app-id = "^kitty-yazi$"; }];
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
        ];
    };
  };
}
