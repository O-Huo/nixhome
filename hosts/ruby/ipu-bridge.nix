# The XPS 14's OV08X40 camera module is mounted upside down, but the BIOS
# SSDB reports 0° rotation, so libcamera renders the image inverted. The
# in-tree ipu-bridge has a DMI quirk table for exactly this
# (upside_down_sensor_dmi_ids); this machine just isn't in it yet. Rebuild
# the module with our entry added. External modules install to updates/,
# which depmod prefers over the in-tree copy.
{ lib, stdenv, kernel }:

stdenv.mkDerivation {
  pname = "ipu-bridge-xps14-rotation";
  version = kernel.version;

  src = null;
  unpackPhase = ''
    tar -xf ${kernel.src} --strip-components=5 --wildcards \
      '*/drivers/media/pci/intel/ipu-bridge.c'
    echo 'obj-m += ipu-bridge.o' > Kbuild
    sourceRoot=.
  '';

  patches = [ ./ipu-bridge-xps14-rotation.patch ];

  nativeBuildInputs = kernel.moduleBuildDependencies;
  hardeningDisable = [ "pic" ];

  makeFlags = [
    "-C" "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "M=$(NIX_BUILD_TOP)"
  ];

  buildFlags = [ "modules" ];
  installFlags = [ "INSTALL_MOD_PATH=$(out)" ];
  installTargets = [ "modules_install" ];

  meta = {
    description = "ipu-bridge with 180° rotation quirk for the Dell XPS 14 DA14260 camera";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
}
