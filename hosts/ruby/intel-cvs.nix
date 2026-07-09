# Out-of-tree intel_cvs (computer vision sensing) driver. The XPS 14's
# MIPI camera sensor (OV08X40 behind the IPU7) declares an ACPI _DEP on
# the CVS device (INTC10E1); without this driver the dependency never
# resolves and the sensor's I2C device is never created.
# https://github.com/intel/vision-drivers
{ lib, stdenv, fetchFromGitHub, kernel }:

stdenv.mkDerivation {
  pname = "intel-vision-drivers";
  version = "0-unstable-2026-05-07-${kernel.version}";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "vision-drivers";
    rev = "845d6f8bdf66ff1f455901da9de5e00a53a83dce";
    hash = "sha256-i/qZN8GXyqaE6n6pRtxQLdmGhmPDjoArzVvflDmwuSs=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;
  hardeningDisable = [ "pic" ];

  makeFlags = [
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KERNEL_SRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "INSTALL_MOD_PATH=$(out)"
  ];

  installTargets = [ "modules_install" ];

  meta = {
    description = "Intel computer vision sensing (intel_cvs) driver";
    homepage = "https://github.com/intel/vision-drivers";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
}
