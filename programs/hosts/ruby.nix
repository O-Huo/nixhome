{ pkgs, ... }:
{
  home.packages = [
    pkgs.teams-for-linux
  ];

  programs.niri.settings = {
    cursor = {
      theme = "Nordic-cursors";
      size = 48;
    };
    outputs."eDP-1" = {
      scale = 1.5;
      position = {
        x = 320;
        y = 1440;
      };
    };
    outputs."Dell Inc. DELL S2725QC 4P7MS84" = {
      scale = 1.5;
      position = {
        x = 0;
        y = 0;
      };
    };
    outputs."Dell Inc. DELL S2725QC 2NGMS84" = {
      scale = 1.5;
      position = {
        x = 0;
        y = 0;
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
    };
  };
}
