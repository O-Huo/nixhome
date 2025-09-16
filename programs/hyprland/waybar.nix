{ pkgs, ... }: {

  programs.waybar = {
    enable = pkgs.stdenv.isLinux;
    style = builtins.readFile ./style.css;
    settings = [{
      layer = "top";
      position = "top";
      mod = "dock";
      exclusive = true;
      passtrough = false;
      gtk-layer-shell = true;
      height = 0;
      modules-left = [
        "custom/launcher"
        "custom/divider"
        "hyprland/workspaces"
        "custom/divider"
        "cpu"
        "custom/divider"
        "memory"
      ];
      modules-center = [ "hyprland/window" ];
      modules-right = [
        "tray"
        "custom/divider"
        "network"
        "custom/divider"
        "backlight"
        "custom/divider"
        "wireplumber"
        "custom/divider"
        "battery"
        "custom/divider"
        "clock"
      ];
      "hyprland/window" = { format = "{}"; };
      "hyprland/workspaces" = {
        format = "{icon}";
        show-special = true;
        on-click = "activate";
        on-scroll-up = "hyprctl dispatch workspace e+1";
        on-scroll-down = "hyprctl dispatch workspace e-1";
      };
      battery = { format = "󰁹 {}%"; };
      cpu = {
        interval = 10;
        format = "󰻠 {}%";
        max-length = 10;
        on-click = "";
      };
      memory = {
        interval = 30;
        format = "  {}%";
        format-alt = " {used:0.1f}G";
        max-length = 10;
      };
      backlight = {
        format = "󰖨 {}";
        device = "acpi_video0";
      };
      tray = {
        icon-size = 13;
        tooltip = false;
        spacing = 10;
      };
      network = {
        format = "󰖩 {essid}";
        format-disconnected = "󰖪 disconnected";
      };
      clock = {
        format = " {:%I:%M %p   %m/%d} ";
        tooltip-format = ''
          <big>{:%Y %B}</big>
          <tt><small>{calendar}</small></tt>'';
      };
      wireplumber = {
        format = "{volume}% {icon}";
        format-muted = "";
        on-click = "helvum";
        format-icons = ["" "" ""];
      };
      "custom/divider" = {
        format = " | ";
        interval = "once";
        tooltip = false;
      };
      "custom/endright" = {
        format = "_";
        interval = "once";
        tooltip = false;
      };
      "custom/launcher" = {
        format = "🦁";
      };
    }];
  };
}


