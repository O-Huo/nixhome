{
  pkgs,
  ...
}: {
  programs.fish.enable = true;
  users.users.hao = {
    isNormalUser = true;
    uid = 1000;
    shell = pkgs.fish;
    description = "Xiangpeng Hao";
    extraGroups = [
      "docker"
      "networkmanager"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJF1GHapK3qlBfJOAnxj3yolJa6ll1DbrC4OwEeya1DW"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINo3/3dfsnQvaFW+hG63w+rOmngogaXtzYoi3/rbOdD6"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPWHg5wa4nzGfoupxbYPnbspSBg45ETQYQUlYwYCi7v7"
    ];
  };
}
