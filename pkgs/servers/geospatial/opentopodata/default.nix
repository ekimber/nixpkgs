{ pkgs, lib, fetchFromGitHub, python3 }:

# poetry2nix.mkPoetryApplication {
# #  python = pkgs.python39;
#   projectDir = ./.;
#   preferWheels = true;
#   src = fetchFromGitHub {
#     owner = "ajnisbet";
#     repo = "opentopodata";
#     rev = "refs/tags/v1.8.3";
#     hash = "sha256-i42XbhMPRIyu97J9mJuCno85Vxplx9sC206TSKsE7tY=";
#   };
#   buildInputs = [ pkgs.libmemcached ];
#}
  
  
python3.pkgs.buildPythonPackage rec {
  pname = "opentopodata";
  version = "1.8.3";
  format = "setuptools";
  src = fetchFromGitHub {
    owner = "ajnisbet";
    repo = "opentopodata";
    rev = "refs/tags/v1.8.3";
    hash = "sha256-i42XbhMPRIyu97J9mJuCno85Vxplx9sC206TSKsE7tY=";
  };

  #propagatedBuildInputs = with python3.pkgs; [ numpy rasterio flask ];

  doCheck = false;

  preBuild = ''
cat > setup.py << EOF
from setuptools import setup

with open('requirements.txt') as f:
    install_requires = f.read().splitlines()

setup(
    name='opentopodata',
    version='1.8.3',
    install_requires=install_requires,
    packages=['opentopodata']
)
EOF
'';
  
  meta = with lib; {
    description = "Open Topo Data is a REST API server for your elevation data.";
    homepage = "https://www.opentopodata.org/";
    license = licenses.mit;
    maintainers = with maintainers; [ ekimber ];
   };
}
#   prebuild = ''
# cat > pyproject.toml
# << EOF
# [tool.poetry]
# name = "opentopodata"
# version = "1.8.3"
# description = "Open Topo Data is a REST API server for your elevation data."
# authors = ["ajnisbet"]
# license = "MIT"

# [tool.poetry.dependencies]
# python = "^3.9"

# [tool.poetry.dev-dependencies]

# [build-system]
# requires = ["poetry-core>=1.0.0"]
# build-backend = "poetry.core.masonry.api"
# EOF''
    
  # nativeCheckInputs = [
  #   pytestCheckHook
  # ];

#  propagatedBuildInputs = [ numpy rasterio flask ];
  
#   doCheck = false;

#}

