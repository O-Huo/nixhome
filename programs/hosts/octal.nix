{ pkgs, ... }:
{
  programs.noctalia.settings.shell.session.power.suspend = "${pkgs.systemd}/bin/systemctl suspend";

  # Idle suspend disabled: resumes on octal have been unreliable (see
  # hosts/octal/default.nix). Lock still happens; the machine stays awake.
  programs.noctalia.settings.idle.behavior.suspend = {
    enabled = false;
    timeout = 600;
    # Noctalia restarts idle timers after the existing two-minute lock.
    locked_timeout = 480;
    action = "suspend";
  };

  wayland.windowManager.niri.settings = {
    cursor.xcursor-size = 32;
    _children = [
      {
        output = {
          _args = [ "DP-3" ];
          scale = 1.25;
          # max-bpc = 10;
          variable-refresh-rate = { };
          mode = "3840x2160@119.880";
        };
      }
    ];
  };
}
