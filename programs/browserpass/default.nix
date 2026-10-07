{ pkgs, ... }: {
  programs.browserpass.enable = true;
  services.gnome-keyring.enable = pkgs.stdenv.hostPlatform.isLinux;
  services.gpg-agent.enable = true;
  services.gpg-agent.pinentry.package =
    if pkgs.stdenv.hostPlatform.isDarwin then pkgs.pinentry_mac else pkgs.pinentry-gnome3;
}
