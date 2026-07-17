# Yi Home cameras flashed with yi-hack firmware, exposed to Home Assistant
# over local RTSP/MQTT. Not in nixpkgs, so packaged from the release tag.
{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
}:

buildHomeAssistantComponent {
  owner = "roleoroleo";
  domain = "yi_hack";
  version = "0.5.7";

  src = fetchFromGitHub {
    owner = "roleoroleo";
    repo = "yi-hack_ha_integration";
    rev = "0.5.7";
    hash = "sha256-3ktM6+XdMzmNLiuCtzigJpOWDEV3/SxDyrWkf3nXrmo=";
  };

  meta = {
    description = "Yi Home cameras with yi-hack firmware in Home Assistant";
    homepage = "https://github.com/roleoroleo/yi-hack_ha_integration";
    license = lib.licenses.gpl3Only;
  };
}
