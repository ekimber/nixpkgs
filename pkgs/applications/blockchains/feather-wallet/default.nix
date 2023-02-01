{ lib, stdenv, makeDesktopItem, fetchFromGitHub, pkg-config, pkgs, qt6 }:
with lib;

stdenv.mkDerivation rec {
  pname = "feather-wallet";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "feather-wallet";
    repo = "feather";
    rev = "${version}";
    sha256 = "LaAyVBmvPt4XATnbIEqgOA2OLH6tnlYBpSw9Si41L8A=";
    fetchSubmodules = true;
    leaveDotGit = true;
  };
  
  nativeBuildInputs = [ pkg-config qt6.wrapQtAppsHook ];

  buildInputs = with pkgs; [ cmake git qrencode zbar boost xorg.libX11 libsodium                              
                             openssl unbound zlib readline hidapi protobuf
                             graphviz gnupg libzip libgcrypt libgpg-error
                             readline doxygen libusb1 ccache
                             qt6.qtbase qt6.qtsvg qt6.qtwebsockets qt6.qttools
                             qt6.qtmultimedia ];
 
  desktopItem = makeDesktopItem {
    name = "feather-wallet";
    exec = "feather";
    icon = "feather-wallet";
    desktopName = "Feather";
    genericName = "Wallet";
    categories  = [ "Utility" ];
  };
  
  cmakeFlags = [
    "-DTOR_DIR=${pkgs.tor}/bin"
    "-DTOR_VERSION=${pkgs.tor.version}"
    "-DCMAKE_BUILD_TYPE=Release"
  ] ++ (if stdenv.hostPlatform.system == "x86_64-linux" then [
    "-DARCH=x86-64"
    "-DBUILD_TAG=\"linux-x64\""
  ] else if stdenv.hostPlatform.system == "aarch64-linux" then [
    "-DARCH=armv8-a"
    "-DBUILD_TAG=\"linux-armv8\""
  ] else throw "Architecture not supported");

  postInstall = ''
    # install desktop entry
    install -Dm644 -t $out/share/applications \
      ${desktopItem}/share/applications/*
    # install icons
    for n in 32 48 64 96 128 256; do
      size=$n"x"$n
      install -Dm644 \
        -t $out/share/icons/hicolor/$size/apps/feather-wallet.png \
        $src/src/assets/images/appicons/$size.png
    done;
  '';

  meta = {
    description = "Feather Monero wallet";
    longDescription = ''Feather is a free, open-source Monero wallet for Linux,
Tails, macOS and Windows. It is written in C++ with the Qt framework.'';
    homepage = "https://featherwallet.org/";
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    license = licenses.bsd3;
  };
}
