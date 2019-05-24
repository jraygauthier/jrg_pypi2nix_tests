{ usePinnedNixpkgs ? true, customNixpkgsFn ? null }:

let
  sandboxPkgs = (import ./nix/sandbox-pkgs.nix) {
    inherit usePinnedNixpkgs customNixpkgsFn; };
  pkgs = sandboxPkgs;

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
  src = pkgs.nix-gitignore.gitignoreSource additionalIgnores ./.;
  outputs = [ "out" ];
  buildInputs = fromRequirementsFile ./requirements-dev.txt python.packages;
  propagatedBuildInputs = fromRequirementsFile ./requirements.txt python.packages;
  doCheck = true;
  checkPhase = ''
    echo "Running black ..."
    black --check --diff -v setup.py src/
    echo "Running flake8 ..."
    flake8 -v setup.py src/
    echo "Running mypy ..."
    mypy_test_modules="$(find tests -name 'test_*.py')"
    mypy src/ $mypy_test_modules
    echo "Running pytest ..."
    PYTHONPATH=$PWD/src:$PYTHONPATH pytest -v tests/
  '';

  postInstall = ''
  '';
  meta = {
    homepage = https://github.com/jraygauthier/jrg_pypi2nix_tests;
    description = "Some pypi2nix test project";
    maintainers = with pkgs.lib.maintainers; [ jraygauthier ];
  };
}
