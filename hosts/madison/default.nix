{pkgs, lib, inputs, ...}: {
  imports = [
    (import ../common {
      inherit pkgs inputs;
      withNvidia = false;
    })
    ../common/hao.nix
    ./hardware-configuration.nix
  ];
  networking.hostName = "xiangpeng-madison";
  time.timeZone = "America/Chicago";

  # Intel Arc Pro B70 (Battlemage G31) — uses the `xe` kernel driver
  hardware.enableRedistributableFirmware = true;
  boot.initrd.kernelModules = [ "xe" ];
  environment.systemPackages = [ pkgs.nvtopPackages.intel ];
  hardware.graphics.enable32Bit = true;
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
    vpl-gpu-rt
    intel-compute-runtime
  ];
  hardware.graphics.extraPackages32 = with pkgs.pkgsi686Linux; [
    intel-media-driver
  ];
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

  programs.steam = {
    enable = lib.mkForce true;
    package = pkgs.steam.override {
      # Steam's CEF web UI currently fails to present reliably on Intel BMG
      # under this Wayland/Niri session. Keep games on normal Mesa/Vulkan, but
      # render Steam's web views in software.
      extraArgs = "-cef-disable-gpu";
      extraEnv = {
        NIXOS_OZONE_WL = "0";
        ELECTRON_OZONE_PLATFORM_HINT = "x11";
      };
    };
  };

  # Mount additional data disks at boot
  fileSystems."/mnt/slow-ssd" = {
    device = "/dev/disk/by-uuid/a02dcb2e-9ed8-4536-8eb9-206fac9a0357"; # sda2 (WDC 1TB)
    fsType = "ext4";
    options = [ "nofail" "x-systemd.device-timeout=0" ];
  };

  fileSystems."/mnt/hdd" = {
    device = "/dev/disk/by-uuid/09aae6ee-28dd-44e1-997c-d48f8a87e9cc"; # sdb1 (Seagate 2TB)
    fsType = "ext4";
    options = [ "nofail" "x-systemd.device-timeout=0" ];
  };

  fileSystems."/mnt/pcie5ssd" = {
    device = "/dev/disk/by-uuid/bc2f2425-ff24-4d63-9114-b087f90f7797"; # nvme1n1 (Samsung 2TB)
    fsType = "ext4";
    options = [ "nofail" "x-systemd.device-timeout=0" ];
  };

  # llama.cpp SYCL inference server on the B70.
  # Models live on the fast NVMe; bind to localhost only.
  virtualisation.podman.enable = true;
  virtualisation.oci-containers = {
    backend = "podman";
    containers.llama-server = {
      image = "ghcr.io/ggml-org/llama.cpp:server-intel-b9010";
      autoStart = true;
      ports = [ "8080:8080" ];
      # Writable cache for `-hf` model downloads.
      volumes = [ "/mnt/pcie5ssd/llm-models:/root/.cache/llama.cpp" ];
      environment = {
        # Flip to level_zero:1 if this picks the iGPU instead of the B70.
        ONEAPI_DEVICE_SELECTOR = "level_zero:0";
      };
      cmd = [
        "-m" "/root/.cache/llama.cpp/Qwen3.6-27B-UD-Q4_K_XL.gguf"
        "-ngl" "99"
        "--host" "0.0.0.0"
        "--port" "8080"
        "--temp" "1.0"
        "--top-k" "20"
        "--top-p" "0.95"
        "--min-p" "0.00"
        "--chat-template-kwargs" "{\"enable_thinking\": false}"
        "-c" "65536"
        # Quantize KV cache to q8_0 (~half VRAM, negligible quality loss).
        # Flash attention is required for quantized V cache.
        "--cache-type-k" "q8_0"
        "--cache-type-v" "q8_0"
        "-fa" "on"
      ];
      extraOptions = [
        "--device=/dev/dri"
        "--ipc=host"
        # Image ships a HEALTHCHECK that probes before the model finishes loading.
        "--no-healthcheck"
      ];
    };
  };
}
