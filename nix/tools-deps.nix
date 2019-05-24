#
# The minimal dependencies required to run utility scripts in
# this (`nix`) directory.
#

{ usePinnedNixpkgs ? true }:

with (import ./sandbox-pkgs.nix { inherit usePinnedNixpkgs; });

runCommand "dummy"
{
  buildInputs = [
    pypi2nix
    coreutils
    nix
    git
    myEnv.tools.getPinnedNixpkgsUrl
    myEnv.tools.getPythonVersion
  ];
} ""

