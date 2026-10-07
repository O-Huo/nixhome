# Imported by hosts/pittsburgh/default.nix. Build the local image first:
# cd /home/hao/china-proxy && docker build -f deploy/Dockerfile -t china-proxy:0.1.0 .
# Credentials stay in the private bind mount, outside the Nix store.
{ lib, pkgs, ... }:
{
  virtualisation.oci-containers = {
    backend = "docker";
    containers.china-proxy = {
      image = "china-proxy:0.1.0";
      pull = "never";
      autoStart = true;
      networks = [ "china-proxy" ];
      ports = [
        "100.119.64.79:51820:51820/udp"
        "192.168.50.197:51820:51820/udp"
      ];
      volumes = [ "/home/hao/china-proxy/.state:/state" ];
      capabilities.NET_ADMIN = true;
      extraOptions = [
        "--ulimit=nofile=8192:8192"
        "--log-driver=local"
        "--log-opt=max-size=10m"
        "--log-opt=max-file=3"
        "--security-opt=no-new-privileges"
        "--read-only"
        "--tmpfs=/run"
        "--tmpfs=/tmp"
        "--sysctl=net.ipv4.ip_unprivileged_port_start=0"
        "--sysctl=net.ipv4.conf.all.rp_filter=0"
        "--sysctl=net.ipv4.conf.default.rp_filter=0"
        "--sysctl=net.ipv4.conf.all.src_valid_mark=0"
        "--sysctl=net.ipv6.conf.all.disable_ipv6=0"
      ];
    };
  };
  systemd.services.docker-china-proxy = {
    after = [ "tailscaled.service" "network-online.target" ];
    serviceConfig.ExecStartPre = lib.mkBefore [
      (pkgs.writeShellScript "china-proxy-network" ''
        ${pkgs.docker}/bin/docker network inspect china-proxy >/dev/null 2>&1 ||
          ${pkgs.docker}/bin/docker network create china-proxy
      '')
    ];
  };
  networking.firewall.interfaces.tailscale0.allowedUDPPorts = [ 51820 ];
  networking.firewall.interfaces.enp3s0.allowedUDPPorts = [ 51820 ];
}
