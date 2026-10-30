{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:
let
  mouse-inhibit = pkgs.writeShellScriptBin "mouse-inhibit" ''
    for dev in /sys/class/input/input*; do
      ${pkgs.systemd}/bin/udevadm info -q property -p "$dev" 2>/dev/null \
        | ${pkgs.gnugrep}/bin/grep -qx 'ID_INPUT_MOUSE=1' || continue
      echo "$1" > "$dev/inhibited" || true
    done
  '';
  screen-off = pkgs.writeShellScript "screen-off" ''
    ${lib.getExe pkgs.niri} msg action power-off-monitors
    ${lib.getExe mouse-inhibit} 1
  '';
  screen-on = pkgs.writeShellScript "screen-on" ''
    ${lib.getExe mouse-inhibit} 0
    ${lib.getExe pkgs.niri} msg action power-on-monitors
  '';
  # Launch apps in order so columns land left-to-right as listed, then
  # stack Slack under Thunderbird in one column on the "browser" workspace.
  restore-layout = pkgs.writeShellScript "niri-restore-layout" ''
    niri=${lib.getExe pkgs.niri}
    jq=${lib.getExe pkgs.jq}
    window_id() {
      $niri msg -j windows | $jq -r --arg app "$1" \
        'map(select((.app_id // "") | ascii_downcase == $app)) | .[0].id // empty'
    }
    wait_for() {
      for _ in $(seq 60); do
        id=$(window_id "$1")
        [ -n "$id" ] && { echo "$id"; return; }
        sleep 0.5
      done
    }

    thunderbird &
    wait_for thunderbird >/dev/null
    slack &
    slack_id=$(wait_for slack)
    [ -n "$slack_id" ] && $niri msg action consume-or-expel-window-left --id "$slack_id"
    firefox &
    alacritty &
    Telegram &
  '';
in
{
  imports = [
    ./bindings.nix
  ];
  programs.noctalia = {
    enable = true;
    package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
    systemd.enable = true;
    settings = {
      shell.launch_apps_as_systemd_services = true;
      shell.screenshot = {
        annotate = true;
        save_to_file = false;
        copy_to_clipboard = true;
      };
      location = {
        auto_locate = true;
      };
      dock = {
        enabled = true;
        auto_hide = true;
        reserve_space = false;
      };
      bar.default = {
        position = "top";
        margin_ends = 0;
        start = [
          "launcher"
          "wallpaper"
          "workspaces"
          "taskbar"
        ];
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
        automation = {
          enabled = true;
          interval_seconds = 1800;
          order = "random";
        };
      };
      idle = {
        behavior = {
          lock = {
            enabled = true;
            timeout = 120; # Reduce screen lock timeout for battery saving
            action = "lock";
          };
          screen-off = {
            enabled = true;
            timeout = 150; # Turn off display sooner
            action = "command";
            command = "${screen-off}";
            resume_command = "${screen-on}";
          };
        };
      };
    };
  };
  systemd.user.services.noctalia.Service.OOMPolicy = "continue";
  home.pointerCursor = {
    enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 48;
    gtk.enable = true;
  };

  home.packages = with pkgs; [
    mouse-inhibit
    wl-clipboard
    xwayland-satellite
    hicolor-icon-theme
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop
  ];

  xdg = {
    enable = pkgs.stdenv.hostPlatform.isLinux;
    configFile."mimeapps.list" = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      force = true;
    };
    mime.enable = pkgs.stdenv.hostPlatform.isLinux;
    mimeApps = {
      enable = pkgs.stdenv.hostPlatform.isLinux;
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "application/xhtml+xml" = "firefox.desktop";
        "application/pdf" = "firefox.desktop";
        "x-scheme-handler/claude" = "claude-desktop.desktop";
      };
    };
    portal = {
      enable = pkgs.stdenv.hostPlatform.isLinux;
      extraPortals = [
        pkgs.xdg-desktop-portal-gnome
        pkgs.xdg-desktop-portal-gtk
      ];
    };
  };

  wayland.windowManager.niri = {
    enable = true;

    settings = {
      cursor.xcursor-theme = "Bibata-Modern-Classic";
      input.touchpad = {
        dwt = { };
        natural-scroll = { };
        click-method = "clickfinger";
      };
      layout = {
        default-column-width.proportion = 0.5;
      };
      switch-events = {
        lid-close.spawn = [
          "noctalia"
          "msg"
          "session"
          "lock"
        ];
      };
      window-rule = {
        match._props.app-id = "^alacritty-yazi$";
        open-floating = true;
      };
      _children = [
        { workspace._args = [ "browser" ]; }
        { workspace._args = [ "terminal" ]; }
        { workspace._args = [ "im" ]; }
        {
          window-rule = {
            match._props.app-id = "^firefox$";
            open-on-workspace = "browser";
            default-column-width.proportion = 2.0 / 3.0;
          };
        }
        {
          window-rule = {
            match._props.app-id = "(?i)^(thunderbird|slack)$";
            open-on-workspace = "browser";
            default-column-width.proportion = 1.0 / 3.0;
          };
        }
        {
          window-rule = {
            match._props.app-id = "^Alacritty$";
            open-on-workspace = "terminal";
            default-column-width.proportion = 1.0;
          };
        }
        {
          window-rule = {
            match._props.app-id = "(?i)^(signal|org\\.telegram\\.desktop|teams-for-linux)$";
            open-on-workspace = "im";
          };
        }
        { spawn-at-startup._args = [ "${restore-layout}" ]; }
        {
          spawn-at-startup._args = [
            "fcitx5"
            "-d"
          ];
        }
        { spawn-at-startup._args = [ "blueman-applet" ]; }
        {
          spawn-at-startup._args = [
            "nm-applet"
            "--indicator"
          ];
        }
      ];
    };
  };
}
