{ pkgs, inputs, ... }: {
  imports = [
    (import ../common {
      inherit pkgs inputs;
      withNvidia = false;
    })
    ./hardware-configuration.nix
    ../common/aoli.nix
  ];
  services.logind = {
    lidSwitch = "suspend";
  };
  services.thermald.enable = true;
  
  # PowerTOP optimizations
  powerManagement.enable = true;
  powerManagement.powertop.enable = true;
  
  # Kernel parameters for power saving
  boot.kernelParams = [
    # Intel P-state driver optimizations
    "intel_pstate=passive"
    # Enable power saving features
    "pcie_aspm=force"
    # Disable NMI watchdog (powertop recommendation)
    "nmi_watchdog=0"
    # Runtime power management
    "pci=pcie_bus_perf"
  ];
  
  # Additional kernel modules for power management
  boot.kernelModules = [ "acpi_cpufreq" ];
  
  # System-wide power optimizations
  boot.kernel.sysctl = {
    # VM writeback timeout (from powertop report)
    "vm.dirty_writeback_centisecs" = 1500;
    # Laptop mode for better power management
    "vm.laptop_mode" = 5;
    # Network power saving
    "net.core.dev_weight" = 64;
  };
  services.tlp = {
    enable = true;
    settings = {
      # CPU optimizations
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 50;
      CPU_BOOST_ON_BAT = 0;
      
      # Platform profile (from powertop recommendations)
      PLATFORM_PROFILE_ON_BAT = "low-power";
      PLATFORM_PROFILE_ON_AC = "performance";
      
      # Runtime power management for PCI devices
      RUNTIME_PM_ON_BAT = "auto";
      RUNTIME_PM_ON_AC = "on";
      
      # Audio power management
      SOUND_POWER_SAVE_ON_BAT = 1;
      SOUND_POWER_SAVE_CONTROLLER = "Y";
      
      # USB autosuspend
      USB_AUTOSUSPEND = 1;
      USB_BLACKLIST_WWAN = 0;
      
      # WiFi power save
      WIFI_PWR_ON_BAT = "on";
      
      # Hard disk power management
      DISK_APM_LEVEL_ON_BAT = "128 128";
      DISK_SPINDOWN_TIMEOUT_ON_BAT = "60 60";
      
      # Kernel laptop mode and VM writeback timeout (from powertop)
      DISK_IDLE_SECS_ON_BAT = 2;
      MAX_LOST_WORK_SECS_ON_BAT = 15;
    };
  };

  # Intel graphics power management
  services.xserver.deviceSection = ''
    Option "DRI" "3"
    Option "TearFree" "true"
  '';

  services.upower.enable = true;
  
  # Bluetooth power optimization
  hardware.bluetooth.settings = {
    General = {
      AutoEnable = false;
    };
    Policy = {
      AutoEnable = false;
    };
  };
  
  services.kanata = {
    enable = true;
    keyboards.default = {
      config =  builtins.readFile ./dell.kbd;
      devices = [
        "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
      ];
    };
  };
  networking.hostName = "jex";
}
