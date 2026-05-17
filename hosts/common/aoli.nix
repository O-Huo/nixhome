{
  pkgs,
  ...
}: {
  programs.fish.enable = true;
  users.users.aoli = {
    isNormalUser = true;
    description = "Ao Li";
    shell = pkgs.fish;
    uid = 1000;
    extraGroups = [
      "podman"
      "networkmanager"
      "wheel"
      "libvirtd"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFDOWYrrl2qfy3wQlkPvtydLozCa3yCe8Tn3MQ/VL27e"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIADuUNeWGvQM3BX7q79a6vN8kY/BQlSrYsVznpIgfRhn"
    ];
  };
}
