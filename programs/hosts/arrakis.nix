{ pkgs, ... }:
{
  targets.genericLinux.enable = true;

  home.packages = [
    pkgs.google-cloud-sdk
  ];
}
