{ pkgs, ... }:
{
  targets.genericLinux.enable = true;

  # Ubuntu box: there is no NixOS module to carry these, and nix itself comes
  # from the system daemon profile, so write ~/.config/nix/nix.conf directly
  # rather than via `nix.settings` (which would pull in its own nix package).
  # The substituters below are only honoured because `aoli` is listed in
  # trusted-users in /etc/nix/nix.conf.
  home.file.".config/nix/nix.conf".text = ''
    experimental-features = nix-command flakes
    extra-substituters = https://cache.numtide.com https://nix-community.cachix.org
    extra-trusted-public-keys = niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=
  '';

  home.packages = [
    pkgs.google-cloud-sdk
  ];
}
