{ lib
, stdenv
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "mev-boost";
  version = "1.5.0";
  src = fetchFromGitHub {
      owner = "flashbots";
      repo = "mev-boost";
      rev = "v${version}";
      sha256 = "sha256-GAi55+BtYtqhB83TKAF/AVeR7T9/F1fkX6el5Tw6OrI=";
  };

  blst-src = fetchFromGitHub {
    owner = "supranational";
    repo = "blst";
    rev = "v0.3.10";
    sha256 = "sha256-xero1aTe2v4IhWIJaEDUsVDOfE77dOV5zKeHWntHogY=";
  };

  vendorHash = "sha256-+6h6q+AOQII9TxI595LKdoT6T75q/8zlARE868YsBdw=";

  # copy C source ignored by go vendoring
  preBuild = ''
if [ -d vendor ]; then
  chmod -R u+w vendor/github.com/supranational/blst
  cp -R --reflink=auto ${blst-src}/src ./vendor/github.com/supranational/blst/
  cp -R --reflink=auto ${blst-src}/bindings ./vendor/github.com/supranational/blst/
  cp -R --reflink=auto ${blst-src}/build ./vendor/github.com/supranational/blst/
fi
'';

  meta = with lib; {
    description = "Ethereum block-building middleware";
    homepage = "https://github.com/flashbots/mev-boost";
    license = licenses.mit;
    maintainers = with maintainers; [ ekimber ];
    platforms = platforms.unix;
  };
}
