{
  lib,
  stdenv,
  fetchurl,
  cmake,
  kdoctools,
  qt6,
  aws-sdk-cpp,

  # These come from pkgs.kdePackages — passed explicitly in callPackage.
  extra-cmake-modules,
  kio,
  ki18n,
  kconfig,
  kcmutils,
  kirigami-addons,
}:

let
  version = "1.0.2";

  # Build only the S3 and core components — the full SDK is massive.
  awssdk = aws-sdk-cpp.override {
    apis = [
      "core"
      "s3"
    ];
  };
in
stdenv.mkDerivation {
  pname = "kio-s3";
  inherit version;

  src = fetchurl {
    url = "https://invent.kde.org/network/kio-s3/-/archive/v${version}/kio-s3-v${version}.tar.gz";
    hash = "sha256-SfzO/4oJb7XjH1xUWf+Jw1Z5Oh2BLQPjrRne+r36kgI=";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    kdoctools
    ki18n
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
    kio
    ki18n
    kconfig
    kcmutils
    kirigami-addons
    awssdk
  ];

  meta = with lib; {
    description = "KIO worker for Amazon S3 and S3-compatible storage services";
    longDescription = ''
      KIO S3 is a KIO worker that allows you to browse and manage files stored in
      Amazon S3 and S3-compatible storage services (such as Cloudflare R2,
      DigitalOcean Spaces, MinIO, and others) directly from Dolphin and other KDE
      applications.
    '';
    homepage = "https://apps.kde.org/kio_s3/";
    changelog = "https://invent.kde.org/network/kio-s3/-/tags/v${version}";
    license = with licenses; [ bsd3 cc0 gpl2Plus ];
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
