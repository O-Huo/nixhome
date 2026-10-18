{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.gpg-agent.enableSshSupport = true;
  services.gnome-keyring.components = [
    "pkcs11"
    "secrets"
  ];

  systemd.user.services.yubikey-touch-detector = {
    Unit = {
      Description = "Show a notification when the YubiKey needs a touch";
      After = [
        "graphical-session.target"
        "noctalia.service"
        "gpg-agent.socket"
        "gpg-agent-ssh.socket"
      ];
      Requires = [
        "gpg-agent.socket"
        "gpg-agent-ssh.socket"
      ];
      # Restore the agent sockets before they are stopped or replaced.
      PartOf = [
        "graphical-session.target"
        "gpg-agent.socket"
        "gpg-agent-ssh.socket"
      ];
    };
    Service = {
      ExecStart = lib.escapeShellArgs [
        (lib.getExe pkgs.yubikey-touch-detector)
        "--notify"
        "--no-socket"
        "--notify-title"
        "Touch your YubiKey"
      ];
      Environment = [
        "PATH=${lib.makeBinPath [ pkgs.gnupg ]}"
        "GNUPGHOME=${config.programs.gpg.homedir}"
        "SSH_AUTH_SOCK=%t/gnupg/S.gpg-agent.ssh"
      ];
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  programs.noctalia.settings.lockscreen = {
    lock_before_suspend = true;
    blurred_desktop = false;
    # Transitions display a desktop snapshot after the session is locked.
    # Suspend can freeze that image and expose it briefly on resume.
    transition = [ ];
  };

  programs.noctalia.settings.shell.session.power.suspend = "${pkgs.systemd}/bin/systemctl suspend";

  programs.noctalia.settings.idle.behavior.suspend = {
    enabled = true;
    timeout = 600;
    # Noctalia restarts idle timers after the existing two-minute lock.
    locked_timeout = 480;
    action = "suspend";
  };

  home.packages = [
    pkgs.fleet-desktop
    pkgs.fleet-orbit
    pkgs.teams-for-linux
    pkgs.google-cloud-sdk
    pkgs.powertop
  ];

  wayland.windowManager.niri.settings = {
    cursor.xcursor-size = 32;
    _children = [
      {
        output = {
          _args = [ "eDP-1" ];
          scale = 1.5;
          # variable-refresh-rate = { };
          position._props = {
            x = 320;
            y = 1440;
          };
        };
      }
      {
        output = {
          _args = [ "Dell Inc. DELL U2722D 3GH2ZG3" ];
          scale = 1;
          position._props = {
            x = 0;
            y = 0;
          };
        };
      }
      {
        output = {
          _args = [ "LG Electronics LG HDR 4K 607INLV0R112" ];
          scale = 1.25;
          position._props = {
            x = 0;
            y = 0;
          };
          mode = "3840x2160@59.997";
        };
      }
      {
        output = {
          _args = [ "ASUSTek COMPUTER INC PG32UCDM S3LMQS114886" ];
          scale = 1.25;
          # max-bpc = 10;
          variable-refresh-rate = { };
          mode = "3840x2160@240.016";
          position._props = {
            x = 0;
            y = 0;
          };
        };
      }
    ];
  };
}
