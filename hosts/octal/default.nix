{ pkgs, inputs, ... }: {
  imports = [
    (import ../common {
      inherit pkgs inputs;
      withNvidia = true;
    })
    ./hardware-configuration.nix
    ../common/aoli.nix
  ];

  boot.kernel.sysctl."kernel.perf_event_paranoid" = 1;
  networking.hostName = "octal";
  environment.etc."hypr/hyprland.conf".text = ''
    monitor=DP-6, 3840x2160@240, 0x0, 1.5
    
    # Add any other Hyprland config here
  '';
}
