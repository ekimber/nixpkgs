{
  lib,
  fetchFromGitHub,
  python3,
  pkgs,
  fetchPypi,
  freetype
}:

let
  ft = freetype.overrideAttrs (oldArgs: { dontDisableStatic = true; });

in python3.pkgs.buildPythonApplication rec {
  pname = "BittyTax";
  version = "0.5.3-dev-a";
  pyproject = true;
  
  src = fetchFromGitHub {
    owner = "BittyTax";
    repo = "BittyTax";
    rev = "4f5dc12cd77e3533d3683e9e010edfd2a3432a9e";
    hash = "sha256-1plOPjuBURglyClcVOeuGlBjGU4tFScf8oMTfptmT3E=";
  };

  # need older reportlab, xhtml2pdf packages because of breakage
  python3 = let 
    packageOverrides = python-self: python-super: {
      reportlab = python-super.reportlab.overridePythonAttrs (oldAttrs: {
        version = "3.6.13";
        src = fetchPypi {          
          hash = "sha256-b3XTP3o3IM9HNxq2PO0PDr0a622xk4aukviXegm+lhE=";          
          pname = "reportlab";
          version = "3.6.13";
        };
        buildInputs = [ ft ];
        propagatedBuildInputs = [ python3.pkgs.pillow ];
          postPatch = ''
    substituteInPlace setup.py \
      --replace "mif = findFile(d,'ft2build.h')" "mif = findFile('${lib.getDev ft}','ft2build.h')"

    # Remove all the test files that require access to the internet to pass.
    rm tests/test_lib_utils.py
    rm tests/test_platypus_general.py
    rm tests/test_platypus_images.py

    # Remove the tests that require Vera fonts installed
    rm tests/test_graphics_render.py
    rm tests/test_graphics_charts.py
  '';

  checkPhase = ''
    cd tests
    LC_ALL="en_US.UTF-8" ${python3.interpreter} runAll.py
  '';
      });
      xhtml2pdf = python-super.xhtml2pdf.overridePythonAttrs (oldAttrs: {
        version = "0.2.11";
        src = fetchFromGitHub {
          owner = "xhtml2pdf";
          repo = "xhtml2pdf";
          rev = "v0.2.11";
          hash = "sha256-L/HCw+O8bidtE5nDdO+cLS54m64dlJL+9Gjcye5gM+w=";
        };
      });
    };
  in pkgs.python3.override {inherit packageOverrides; self = python3;};

   nativeBuildInputs = [
     python3.pkgs.setuptools
   ];

   propagatedBuildInputs = with python3.pkgs; [
     colorama jinja2 openpyxl defusedxml pyyaml python-dateutil requests
     typing-extensions xlrd xlsxwriter reportlab xhtml2pdf tqdm ];
  
  meta = with lib; {
    description = "A cryptocurrency tax calculator";
    longDescription = ''
BittyTax is a collection of command-line tools to help you calculate your cryptoasset taxes in the UK.
    '';
    homepage = "https://github.com/BittyTax/BittyTax";
    license = licenses.agpl3Only;
    maintainers = [ maintainers.ekimber ];
    platforms = platforms.all;
  };
}
