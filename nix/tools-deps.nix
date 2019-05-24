#
# The minimal dependencies required to run utility scripts in
# this (`nix`) directory.
#

{ usePinnedNixpkgs ? true }:

with (import ./sandbox-pkgs.nix { inherit usePinnedNixpkgs; });

runCommand "dummy"
{
  buildInputs = [
    nodePackages.node2nix
    pypi2nix
    coreutils
    nix
    myEnv.tools.getPinnedNixpkgsUrl
    myEnv.tools.getPythonVersion
  ];
} ""

