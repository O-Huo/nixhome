{ pkgs, ... }:
{
  home.packages = [
    pkgs.teams-for-linux
    pkgs.google-cloud-sdk
  ];

  programs.niri.settings = {
    cursor = {
      size = 32;
    };
    outputs."eDP-1" = {
      scale = 1.5;
      position = {
        x = 320;
        y = 1440;
      };
    };
    outputs."DP-1" = {
      scale = 1.5;
      position = {
        x = 0;
        y = 0;
      };
      mode = {
        width = 3840;
        height = 2160;
        refresh = 120.000;
      };
    };
    outputs."ASUSTek COMPUTER INC PG32UCDM S3LMQS114886" = {
      scale = 1.5;
      # max-bpc = 10;
      variable-refresh-rate = true;
      mode = {
        width = 3840;
        height = 2160;
        refresh = 240.016;
      };
      position = {
        x = 0;
        y = 0;
      };
    };
  };
}
