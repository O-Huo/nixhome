# Home Assistant, reachable at http://jex:8123 (also over Tailscale).
{ config, pkgs, ... }:
{
  services.home-assistant = {
    enable = true;
    customComponents = [
      (pkgs.callPackage ./hacs.nix { })
    ];
    extraComponents = [
      "analytics"
      "google_translate"
      "met"
      "radio_browser"
      "shopping_list"
      "isal"
      "mqtt"
      "homekit"
      "yi"
      "ffmpeg"
      "bluetooth"
    ];
    config = {
      default_config = { };
    };
    openFirewall = true;
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # H5083 plugs can't be controlled over BLE (govee-ble-plugs only supports
  # H5080/H5082/H5086), so bridge them via the Govee cloud API into MQTT.
  # The env file holds GOVEE_EMAIL/GOVEE_PASSWORD/GOVEE_API_KEY and the
  # broker address.
  age.secrets.govee2mqtt-env.file = ../../secrets/govee2mqtt.env.age;
  services.govee2mqtt = {
    enable = true;
    environmentFile = config.age.secrets.govee2mqtt-env.path;
  };

  services.mosquitto = {
    enable = true;
    listeners = [
      {
        address = "127.0.0.1";
        port = 1883;
        omitPasswordAuth = true;
        settings.allow_anonymous = true;
        acl = [ "pattern readwrite #" ];
      }
    ];
  };


  # Govee LAN protocol: devices answer discovery/status on UDP 4002.
  # mDNS (UDP 5353) lets Apple devices discover the HomeKit bridge.
  networking.firewall.allowedUDPPorts = [
    4002
    5353
  ];

  # Default port of the HomeKit bridge (each additional bridge adds one).
  networking.firewall.allowedTCPPorts = [ 21063 ];
}
