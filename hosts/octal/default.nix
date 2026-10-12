{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    (import ../common {
      inherit pkgs inputs;
      withNvidia = true;
    })
    ./hardware-configuration.nix
    ../common/aoli.nix
  ];

  # rr (record/replay debugger) support. ptrace_scope is set in common/headless.nix.
  boot.kernel.sysctl."kernel.perf_event_paranoid" = 1;
  # Zen CPUs need the SpecLockMap hardware optimization disabled (MSR
  # 0xC0011020 bit 54) or rr's retired-branch counter is unreliable and rr
  # refuses to start. See https://github.com/rr-debugger/rr/wiki/Zen
  boot.extraModulePackages = [ config.boot.kernelPackages.rr-zen_workaround ];
  boot.kernelModules = [ "zen_workaround" ];
  networking.hostName = "octal";

  # Suspend is disabled on this machine: resumes have been unreliable (see
  # below). Mask the sleep targets so nothing (idle timers, logind, manual
  # `systemctl suspend`) can put it to sleep. Overrides common/headless.nix.
  systemd.targets.sleep.enable = lib.mkForce false;
  systemd.targets.suspend.enable = lib.mkForce false;
  systemd.targets.hibernate.enable = lib.mkForce false;
  systemd.targets.hybrid-sleep.enable = lib.mkForce false;

  # Suspend/resume hardening. Since idle suspend was enabled (2026-09-29), two
  # of three resumes ended in a hard reset with no journal written after wake,
  # and the lock screen reported "Unable to resolve current user" (its PAM
  # helper could not read /etc/passwd). Both point at the root disk (Intel
  # 660p, nvme0) dropping off the bus after S3, a known APST issue on that
  # drive. Disable NVMe autonomous power-state transitions.
  boot.kernelParams = [ "nvme_core.default_ps_max_latency_us=0" ];
  # Preserve VRAM across suspend via nvidia-suspend/resume.service so the GPU
  # comes back reliably after S3.
  hardware.nvidia.powerManagement.enable = true;

  # Post-resume diagnostics written to /data (the Samsung drive), because the
  # journal lives on the root disk and has been lost after every failed
  # resume so far. Tells us whether the root disk is readable after wake.
  powerManagement.resumeCommands = ''
    export PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.util-linux ]}:$PATH
    d=/data/log/resume-debug
    mkdir -p "$d"
    f="$d/$(date +%F_%H%M%S).log"
    {
      echo "== resume $(date -Is)"
      echo "-- root disk read test (/etc/passwd)"
      if timeout 10 head -c 64 /etc/passwd > /dev/null; then echo ok; else echo "FAILED rc=$?"; fi
      echo "-- nvme controllers"
      for n in /sys/class/nvme/nvme*; do
        echo "$(basename "$n") $(cat "$n/model") state=$(cat "$n/state")"
      done
      echo "-- dmesg tail"
      dmesg | tail -n 80
    } > "$f" 2>&1
    sync -f "$d"
  '';

  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_cachyos-lts;
  hardware.nvidia.package = lib.mkForce pkgs.nvidia_cachyos-lts;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="input", KERNEL=="input[0-9]*", ENV{ID_INPUT_MOUSE}=="1", RUN+="${pkgs.coreutils}/bin/chgrp input /sys%p/inhibited", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys%p/inhibited"
  '';
  # gamemode: required for the renice configured in gui.nix to apply.
  users.users.aoli.extraGroups = [
    "input"
    "gamemode"
  ];

  # sched-ext userspace scheduler tuned for gaming/interactivity; the CachyOS
  # kernel ships sched-ext support, and lavd is what CachyOS defaults to.
  services.scx = {
    enable = true;
    scheduler = "scx_lavd";
  };
  networking.firewall.allowedTCPPorts = [ 8211 ];
  networking.firewall.allowedUDPPorts = [ 8211 ];
}
