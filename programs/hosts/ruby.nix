{ programs, ... }:
{
  programs.niri.settings = {
    cursor = {
      theme = "Nordic-cursors";
      size = 48;
    };
    outputs."eDP-1" = {
      scale = 1.5;
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
