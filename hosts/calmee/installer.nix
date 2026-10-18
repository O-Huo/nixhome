{ lib, pkgs, modulesPath, ... }:
let
  source = lib.cleanSourceWith {
    src = ../..;
    filter = path: type:
      let name = baseNameOf path;
      in !(builtins.elem name [ ".git" ".jj" ".direnv" ".claude" "result" "result-calmee-iso" ])
        && lib.cleanSourceFilter path type;
  };
in
{
  imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "calmee-installer";
  # Use the standard kernel and broad hardware support until hardware is known.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };
  users.users.nixos.openssh.authorizedKeys.keys =
    (import ../common/aoli.nix { inherit pkgs; }).users.users.aoli.openssh.authorizedKeys.keys;
  environment.etc."calmee-install.txt".source = ./INSTALL.txt;
  environment.etc."calmee-source".source = source;
  environment.systemPackages = with pkgs; [ pciutils usbutils nvme-cli ];
  image.baseName = lib.mkForce "calmee-installer";
  services.getty.helpLine = lib.mkAfter ''

    Calmee setup: cat /etc/calmee-install.txt
    Find the IP: ip -br address
    SSH from Ruby: ssh nixos@<IP> (existing authorized key required)
    Hardware: lscpu; lspci -nn; lsblk -o NAME,SIZE,MODEL,TYPE,MOUNTPOINTS
  '';
}
