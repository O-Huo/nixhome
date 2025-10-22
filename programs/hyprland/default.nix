{ pkgs, lib, inputs, config, ... }: {
  imports = [
    inputs.noctalia.homeModules.default
    ./bind.nix
  ];
  programs.noctalia-shell = {
    enable = true;
    settings = {
      bar = {
        density = "compact";
        position = "top";
        showCapsule = false;
        widgets = {
          left = [
            {
              id = "SidePanelToggle";
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
              id = "SystemMonitor";
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
        randomIntervalSec = 300;
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
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
      ];
      configPackages = [pkgs.hyprland];
    };
  };


  services = {
    hypridle = {
      enable = pkgs.stdenv.isLinux;
      settings = {
        general = {
          after_sleep_cmd = "hyprctl dispatch dpms on";
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
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };
  };

  wayland.windowManager.hyprland = {
    enable = pkgs.stdenv.isLinux;
    systemd.enable = pkgs.stdenv.isLinux;
    plugins = [
    ];
    settings = {
      decoration = {
        shadow.enabled = false;
        blur.enabled = false;
        rounding = 0;         # Disable rounding for performance
      };
      animations = {
        enabled = false;      # Disable animations for battery saving
      };
      misc = {
        vfr = true;           # Variable refresh rate
        vrr = 1;              # Variable refresh rate on fullscreen
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        always_follow_on_dnd = false;
        layers_hog_keyboard_focus = false;
        animate_manual_resizes = false;
        animate_mouse_windowdragging = false;
        disable_autoreload = true;
      };
      xwayland = {
        force_zero_scaling = true;
      };
      input = {
        kb_options = "ctrl:nocaps";
        follow_mouse = 2;
        touchpad = {
          natural_scroll = true;
        };
      };
      gestures = {
        workspace_swipe_distance = 300;
        workspace_swipe_invert = true;
        workspace_swipe_min_speed_to_force = 30;
        workspace_swipe_cancel_ratio = 0.5;
        workspace_swipe_create_new = true;
        workspace_swipe_forever = false;
      };
      general = {
        gaps_in = 0;
        gaps_out = 0;
        border_size = 0;
        no_border_on_floating = true;
      };
      plugin = {
      };
      windowrulev2 = [
        # IM
        "tag +im, class:^(org.telegram.desktop)$"
        "tag +im, class:^(.*Discord.*)$"
        "tag +im, class:^(.*Slack.*)$"
        "tag +im, class:^(.*zoom.*)$"
        "workspace special, tag:im*"

        # Game
        "tag +game, class:^(.*Steam.*)$"
        "tag +game, class:^(.*DotA.*)$"
        "tag +games, class:^(steam_app_\d+)$"
        "fullscreen, tag:games"

        # Screenshot utilities - disable animations and optimize performance
        "noanim, class:^(grim)$"
        "noanim, class:^(slurp)$"
        "noblur, class:^(slurp)$"
        "noshadow, class:^(slurp)$"
        "noborder, class:^(slurp)$"
        "immediate, class:^(slurp)$"

        "float, class:^(.*fcitx.*)$"
        "noinitialfocus, class:^(.*jetbrains.*)$, title:^(win.*)$"
        "nofocus, class:^(.*jetbrains.*)$, title:^(win.*)$"
        "noinitialfocus, class:^(.*jetbrains.*)$, title:^\\s$"
        "nofocus, class:^(.*jetbrains.*)$, title:^\\s$"
      ];
      exec-once = [
        "fcitx5 -d"
        "blueman-applet"
        "nm-applet --indicator"
        "hyprctl setcursor catppuccin-latte-red-cursors 30"
        "hyprshell run"
      ] ++ lib.optionals (config.programs.atuin.enable or false) [
          "atuin daemon&"
        ];
    };
  };
}
