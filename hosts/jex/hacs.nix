# HACS (Home Assistant Community Store), not packaged in nixpkgs.
# Uses the release zip because it bundles the hacs_frontend assets and a
# stamped manifest version, unlike the plain git tree.
{
  lib,
  fetchurl,
  unzip,
  buildHomeAssistantComponent,
  home-assistant,
}:

buildHomeAssistantComponent rec {
  owner = "hacs";
  domain = "hacs";
  version = "2.0.5";

  src = fetchurl {
    url = "https://github.com/hacs/integration/releases/download/${version}/hacs.zip";
    hash = "sha256-l75rgkpPOOaDcozG3XI2f2uLrQpDQosbO5h6MIet9BM=";
  };

  # The zip unpacks flat (manifest.json at the root).
  sourceRoot = ".";
  nativeBuildInputs = [ unzip ];

  dependencies = [
    home-assistant.python3Packages.aiogithubapi
  ];

  meta = {
    changelog = "https://github.com/hacs/integration/releases/tag/${version}";
    description = "Home Assistant Community Store";
    homepage = "https://hacs.xyz";
    license = lib.licenses.mit;
  };
}
