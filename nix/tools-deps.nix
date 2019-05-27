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
    nix-prefetch-git
    # Wrap mercurial related stuff. This is because mercurial still uses
    # python2 and its nixpkgs package propagates a bunch of python2
    # dependencies through `PYTHONPATH` which corrupts pypi2nix environment.
    (buildEnv {
      name = "mercurial-no-leaks";
      paths = [mercurial nix-prefetch-hg];
    })
    myEnv.tools.getPinnedNixpkgsUrl
    myEnv.tools.getPythonVersion
  ];
} ""

