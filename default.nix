{ usePinnedNixpkgs ? true, customNixpkgsFn ? null }:

let
  sandboxPkgs = (import ./nix/sandbox-pkgs.nix) {
    inherit usePinnedNixpkgs customNixpkgsFn; };
  pkgs = sandboxPkgs;

  python = import ./nix/requirements.nix { inherit pkgs; };
  version = pkgs.lib.fileContents ./src/jrg_pypi2nix_tests/fallback_version.txt;
  additionalIgnores = [];

  readLines = file: with pkgs.lib; splitString "\n" (removeSuffix "\n" (builtins.readFile file));

  hasContent = line:
    let split = builtins.split "(^[[:space:]]*#|^[[:space:]]*$)" line; in
    builtins.length split <= 1;
  readMeaninfulLines = file: builtins.filter hasContent (readLines file);

  removeAfter = delim: line:
    let split = pkgs.lib.splitString delim line; in
    if builtins.length split > 1 then builtins.head split else line;
  urlToPackageName = line:
    let split = builtins.split "#egg=(.+)" line; in
    if builtins.length split > 1 then builtins.head (builtins.elemAt split 1) else line;
  sanitizedPackageName = line:
    let split = builtins.split "([-_\.a-zA-Z0-9]+)" line; in
    if builtins.length split > 1 then builtins.head (builtins.elemAt split 1) else line;
  # We assume package name with version listed in req files are
  # of the same form as nix derivations.
  removeVersionSuffix = line: (builtins.parseDrvName line).name;

  applyTransform = lines: transform: builtins.map transform lines;
  transforms =
    [
      urlToPackageName # Take the egg name from urls
      (removeAfter "#") # Remove after comment
      sanitizedPackageName
      removeVersionSuffix
    ];
  fromRequirementsFile = file: pythonPackages:
    builtins.map (name: builtins.getAttr name pythonPackages)
      (builtins.filter (x: x != "")
        (builtins.foldl' applyTransform (readMeaninfulLines file) transforms));
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
