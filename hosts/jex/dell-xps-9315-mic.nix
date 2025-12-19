# Dell XPS 9315 Microphone Configuration
{ config, lib, pkgs, ... }:

{
  # Ensure SOF firmware is available
  hardware.firmware = with pkgs; [
    sof-firmware
  ];

  # Dell XPS 9315 specific
  # fu06 is off should we enable it?
  #${pkgs.alsa-utils}/bin/amixer -c 0 cset name='rt714 FU06 Capture Switch' 'on'    
  systemd.services.xps-mic-fix = {
    after = [ "sound.target" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      # Disable power management
      for dev in /sys/bus/soundwire/devices/*/power/control; do
        echo on > $dev || true
      done
      
      # correct ruting
      ${pkgs.alsa-utils}/bin/amixer -c 0 set 'rt714 ADC 22 Mux' 'DMIC1'
      # Enable ONLY the capture path that UCM uses (FU02)
      ${pkgs.alsa-utils}/bin/amixer -c 0 cset name='rt714 FU02 Capture Switch' 'on'
      ${pkgs.alsa-utils}/bin/amixer -c 0 cset name='rt714 FU02 Capture Volume' '70'
      # correct volume
      ${pkgs.alsa-utils}/bin/amixer -c 0 cset name='rt714 FU0C Boost' '0'
    '';
  };

  # services.pulseaudio = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

}
