{ pkgs, lib, inputs, config, ... }:
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
in {
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
      bar.default = {
        position = "top";
        margin_ends = 0;
        start = [ "launcher" "wallpaper" "workspaces" "taskbar" ];
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
      idle = {
        behavior = {
          lock = {
            enabled = true;
            timeout = 120;  # Reduce screen lock timeout for battery saving
            action = "lock";
          };
          screen-off = {
            enabled = true;
            timeout = 150;  # Turn off display sooner
            action = "command";
            command = "${screen-off}";
            resume_command = "${screen-on}";
          };
        };
      };
    };
  };
  home.pointerCursor = {
    enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 48;
    gtk.enable = true;
  };

  home.packages = with pkgs; [
    mouse-inhibit
    grim
    slurp
    wl-clipboard
    xwayland-satellite
    hicolor-icon-theme
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
        "application/pdf" = "firefox.desktop";
      };
    };
    portal = {
      enable = pkgs.stdenv.isLinux;
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
        lid-close.spawn = ["noctalia" "msg" "session" "lock"];
      };
      window-rule = {
        match._props.app-id = "^alacritty-yazi$";
        open-floating = true;
      };
      _children = [
        { spawn-at-startup._args = ["fcitx5" "-d"]; }
        { spawn-at-startup._args = ["blueman-applet"]; }
        { spawn-at-startup._args = ["nm-applet" "--indicator"]; }
        { spawn-at-startup._args = ["noctalia"]; }
      ];
    };
  };
}
