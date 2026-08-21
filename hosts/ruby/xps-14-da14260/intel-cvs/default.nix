# The in-tree Intel CVS driver (drivers/media/i2c/cvs, CONFIG_VIDEO_INTEL_CVS,
# new in 7.2) built as an external module because the CachyOS kernel config
# does not enable it. Since 7.2, ipu-bridge lists the CVS ACPI ids (INTC10E1
# on Panther Lake) as IVSC devices and wires the sensor's fwnode graph
# through a CVS V4L2 subdev; a CVS driver without subdev support (the
# out-of-tree intel/vision-drivers this file used to build) leaves that graph
# node empty, the ISYS async notifier never completes, and the sensor never
# binds. Drop this once the kernel config enables VIDEO_INTEL_CVS.
{
  stdenv,
  lib,
  kernel,
  kernelModuleMakeFlags,
}:

stdenv.mkDerivation {
  name = "intel-cvs-${kernel.version}";

  src = kernel.src;

  unpackPhase = ''
    runHook preUnpack
    tar -xaf "$src" --wildcards '*/drivers/media/i2c/cvs'
    sourceRoot=$(echo */drivers/media/i2c/cvs)
    runHook postUnpack
  '';

  hardeningDisable = [ "pic" ];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "-C"
    "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "M=$(PWD)"
    "CONFIG_VIDEO_INTEL_CVS=m"
  ];

  buildFlags = [ "modules" ];
  installFlags = [ "INSTALL_MOD_PATH=$(out)" ];
  installTargets = [ "modules_install" ];

  meta = {
    description = "Intel CVS driver (in-tree drivers/media/i2c/cvs) with V4L2 subdev support";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
}
