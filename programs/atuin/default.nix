{ pkgs, ...}: {
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      daemon.enabled = false; 
    };
  };
}
