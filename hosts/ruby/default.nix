{ pkgs, inputs, ... }: {
  imports = [
    (import ../common {
      inherit pkgs inputs;
      withNvidia = true;
    })
    ./hardware-configuration.nix
    ../common/aoli.nix
  ];
  networking.hostName = "ruby";

  systemd.services.kanata-default.serviceConfig = {
    SupplementaryGroups = [
      "input"
      "uinput"
    ];
  };

  services.kanata = {
    enable = true;
    keyboards.default = {
      config =  builtins.readFile ./logic.kbd;
      devices = [
        "/dev/input/by-id/usb-Topre_REALFORCE_87_US-event-kbd"
      ];
    };
  };
  services.printing = {
    enable = true;
    drivers = [ pkgs.cups-filters pkgs.gutenprint ];
  };
}
