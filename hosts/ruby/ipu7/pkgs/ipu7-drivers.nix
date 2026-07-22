{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  kernel,
  kernelModuleMakeFlags,
}:

stdenv.mkDerivation {
  pname = "ipu7-drivers";
  version = "0-unstable-2026-06-30";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "ipu7-drivers";
    rev = "ba5db745b26e54abbe459e1a38ff1d22d0fe0caa";
    hash = "sha256-WvFsUhAHvQGz7SZ+MZgznCIO3B1wK/Tnfcmvlegyg+E=";
  };

  patches = [
    (fetchpatch {
      name = "psys-register-bus-before-adding-the-psys-device.patch";
      # https://github.com/intel/ipu7-drivers/pull/87
      url = "https://github.com/intel/ipu7-drivers/commit/77e3a0065697314cc7437a6eefd7e0d36ab06a4b.patch";
      hash = "sha256-9wz+t4w94ymx4Ro634mIgRNAhaPj1Di514h2KRBljMU=";
    })
    (fetchpatch {
      name = "guard-ipu7_dir-for-in-tree-core-builds.patch";
      # https://github.com/intel/ipu7-drivers/pull/88
      url = "https://github.com/intel/ipu7-drivers/commit/61ace27b1409a15a7e22f959277c256690f10a31.patch";
      hash = "sha256-7UYUUqRXOLAmGNX/ymfnFjow0Xajxf3GC+ne98nBdDo=";
    })
  ];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KERNEL_SRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  enableParallelBuilding = true;

  preInstall = ''
    sed -i -e "s,INSTALL_MOD_DIR=,INSTALL_MOD_PATH=$out INSTALL_MOD_DIR=," Makefile
  '';

  installTargets = [
    "modules_install"
  ];

  meta = {
    homepage = "https://github.com/intel/ipu7-drivers";
    description = "IPU7 kernel driver";
    license = lib.licenses.gpl2Only;
    platforms = [ "x86_64-linux" ];
    broken = kernel.kernelOlder "6.12";
  };
}
