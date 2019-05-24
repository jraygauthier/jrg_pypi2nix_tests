{ usePinnedNixpkgs ? true, customNixpkgsFn ? null }:

let
  sandboxPkgs = (import ./nix/sandbox-pkgs.nix) {
    inherit usePinnedNixpkgs customNixpkgsFn; };
  pkgs = sandboxPkgs;

  # https://github.com/siers/nix-gitignore
  nix-gitignore-src = pkgs.fetchFromGitHub {
    owner = "siers";
    repo = "nix-gitignore";
    rev = "221d4aea15b4b7cc957977867fd1075b279837b3";
    sha256 = "0xgxzjazb6qzn9y27b2srsp2h9pndjh3zjpbxpmhz0awdi7h8y9m";
  };
  nix-gitignore = pkgs.callPackage nix-gitignore-src {};
  python = import ./nix/requirements.nix { inherit pkgs; };
  version = pkgs.lib.fileContents ./src/jrg_pypi2nix_tests/VERSION;
  additionalIgnores = [];

  readLines = file: with pkgs.lib; splitString "\n" (removeSuffix "\n" (builtins.readFile file));
  removeAfter = delim: line:
    let split = pkgs.lib.splitString delim line; in
    if builtins.length split > 1 then builtins.head split else line;
  applyTransform = lines: transform: builtins.map transform lines;
  transforms =
    [ (removeAfter "#") # remove after comment
    ];
  fromRequirementsFile = file: pythonPackages:
    builtins.map (name: builtins.getAttr name pythonPackages)
      (builtins.filter (x: x != "")
        (builtins.foldl' applyTransform (readLines file) transforms));
in python.mkDerivation {
  name = "pypi2nix-${version}";
  src = nix-gitignore.gitignoreSource additionalIgnores ./.;
  outputs = [ "out" ];
  buildInputs = fromRequirementsFile ./requirements-dev.txt python.packages;
  propagatedBuildInputs = fromRequirementsFile ./requirements.txt python.packages;
  doCheck = false;
  checkPhase = ''
    echo "Running black ..."
    black --check --diff -v setup.py src/
    echo "Running flake8 ..."
    flake8 -v setup.py src/
    echo "Running pytest ..."
    PYTHONPATH=$PWD/src:$PYTHONPATH pytest -v --cov=src/ tests/
  '';

  postInstall = ''
  '';
  meta = {
    homepage = https://github.com/jraygauthier/jrg_jrg_pypi2nix_tests;
    description = "Some pypi2nix test project";
    maintainers = with pkgs.lib.maintainers; [ jraygauthier ];
  };
}
