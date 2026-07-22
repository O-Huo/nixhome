# Packages from nixpkgs PR #542085 ("ipu7: init"): the IPU7 camera HAL stack
# and the icamerasrc GStreamer plugin, wired into pkgs the same way the PR
# wires them into all-packages.nix / gstreamer/default.nix. Delete together
# with ./module.nix and ./pkgs once the PR is merged.
final: prev: {
  ipu7-camera-bins = final.callPackage ./pkgs/ipu7-camera-bins.nix { };

  ipu7x-camera-hal = final.callPackage ./pkgs/ipu7x-camera-hal.nix { };
  ipu75xa-camera-hal = final.ipu7x-camera-hal.override {
    ipuVersion = "ipu75xa";
  };

  gst_all_1 = prev.gst_all_1.overrideScope (
    gfinal: gprev: {
      icamerasrc-ipu7x = gfinal.callPackage ./pkgs/icamerasrc.nix {
        ipuVariant = "ipu7";
        inherit (final) ipu7x-camera-hal;
      };
      icamerasrc-ipu75xa = gfinal.callPackage ./pkgs/icamerasrc.nix {
        ipuVariant = "ipu7";
        ipu7x-camera-hal = final.ipu75xa-camera-hal;
      };
    }
  );
}
