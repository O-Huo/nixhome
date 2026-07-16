# Home Assistant, reachable at http://jex:8123 (also over Tailscale).
{ pkgs, ... }:
{
  services.home-assistant = {
    enable = true;
    customComponents = [
      (pkgs.callPackage ./hacs.nix { })
    ];
    extraComponents = [
      # Components required to complete the onboarding
      "analytics"
      "google_translate"
      "met"
      "radio_browser"
      "shopping_list"
      # Fast zlib compression, recommended by upstream
      "isal"
      # Receives the devices govee2mqtt announces over the local broker
      "mqtt"
      # HomeKit Bridge: exposes HA devices to the Apple Home app
      "homekit"
      # Yi camera (requires yi-hack firmware on the camera) + ffmpeg it
      # streams through
      "yi"
      "ffmpeg"
    ];
    config = {
      # Enables the default set of integrations and mDNS/SSDP discovery;
      # further setup happens in the web UI.
      default_config = { };

      # The password comes from /var/lib/hass/secrets.yaml, which is not
      # managed by nix; create it once on jex:
      #   sudo tee -a /var/lib/hass/secrets.yaml <<< 'yi_camera_password: "123456"'
      camera = [
        {
          platform = "yi";
          name = "Yi Camera";
          host = "192.168.50.243";
          password = "123456";
        }
      ];
    };
    # Opens TCP 8123.
    openFirewall = true;
  };

  # Local MQTT broker connecting govee2mqtt and Home Assistant. Only
  # listens on loopback, so anonymous access is fine.
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

  # Bridges Govee devices (LAN protocol + cloud/IoT) to Home Assistant via
  # MQTT autodiscovery. Credentials are not in the repo; create the
  # environment file once on jex, then restart the service:
  #   sudo install -d -m 750 -o govee2mqtt -g govee2mqtt /var/lib/govee2mqtt
  #   sudoedit /var/lib/govee2mqtt/govee2mqtt.env
  #     GOVEE_EMAIL=you@example.com
  #     GOVEE_PASSWORD=...
  #     GOVEE_API_KEY=...        # from the Govee Home app, optional but recommended
  #     GOVEE_MQTT_HOST=127.0.0.1
  #     GOVEE_MQTT_PORT=1883
  #   sudo systemctl restart govee2mqtt
  services.govee2mqtt = {
    enable = true;
    environmentFile = "/var/lib/govee2mqtt/govee2mqtt.env";
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
