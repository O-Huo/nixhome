{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  pkg-config,
  gst_all_1,
  ipu6-camera-hal,
  ipu7x-camera-hal,
  ipuVariant ? "ipu6",
  libdrm,
  libva,
  apple-sdk_gstreamer,
}:
let
  ipu-camera-hal =
    {
      ipu6 = ipu6-camera-hal;
      ipu7 = ipu7x-camera-hal;
    }
    .${ipuVariant};
in
stdenv.mkDerivation (finalAttrs: {
  pname = "icamerasrc-${ipu-camera-hal.ipuVersion}";
  version = "20260629_2";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "icamerasrc";
    tag = finalAttrs.version;
    hash = "sha256-AJCkHEXKQZUNxYCOdtGXimlKwDVjAR+2qnIT1nUkIPw=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  preConfigure = ''
    export CHROME_SLIM_CAMHAL=ON
  '';

  separateDebugInfo = true;

  __structuredAttrs = true;
  strictDeps = true;

  configureFlags = [
    "--enable-gstdrmformat=yes"
  ];

  buildInputs = [
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-bad
    ipu-camera-hal
    libdrm
    libva
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    apple-sdk_gstreamer
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-Wno-error"
    # gstcameradeinterlace.cpp:55:10: fatal error: gst/video/video.h: No such file or directory
    "-I${gst_all_1.gst-plugins-base.dev}/include/gstreamer-1.0"
  ];

  enableParallelBuilding = true;

  passthru = {
    inherit (ipu-camera-hal) ipuVersion;
  };

  meta = {
    description = "GStreamer Plugin for MIPI camera support through the IPU6/IPU7 on Intel platforms";
    homepage = "https://github.com/intel/icamerasrc/tree/icamerasrc_slim_api";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
  };
})
