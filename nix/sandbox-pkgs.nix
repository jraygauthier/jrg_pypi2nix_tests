{ usePinnedNixpkgs ? true, customNixpkgsFn ? null, overlays ? [] }:

let
  pinnedNixpkgs = rec {
    rev = "cf3e277dd0bd710af0df667e9364f4bd80c72713";
    # Get this info from the output of: `nix-prefetch-url --unpack $url` where `url` is
    # the `url` expression below.
    sha256 = "1abyadl3sxf67yi65758hq6hf2j07afgp1fmkk7kd94dadx6r6f4";
    url = "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
    src = builtins.fetchTarball {
      inherit url;
      inherit sha256;
    };
  };

  nixpkgsConfig = {
    allowUnfree = true;
  };

  pkgsOverlay = self: super: rec {
    # pypi2nixRepoLocal = builtins.filterSource (pypi2nixSourceFilter ../../pypi2nix) ../../pypi2nix;
    pypi2nixRepoRemote = builtins.fetchTarball {
      url = "https://github.com/garbas/pypi2nix/archive/ff1ba9006839fd46e4b237d2757be5b22d408565.tar.gz";
      sha256 = "0l4ywjn0lb53519m2155r6sfcrlkpx6pnha54kmsqd45pv6lz0rv";
    };

    # pypi2nixRepo = pypi2nixRepoLocal;
    pypi2nixRepo = pypi2nixRepoRemote;
    pypi2nixNixpkgs = super;

    pypi2nix = (import "${pypi2nixRepo}/default.nix" {
      pkgs = pypi2nixNixpkgs;
    });

    # TODO: Need special case for pypy?
    pythonVersionToNixpkgsPythonAttrSetName = versionStr: "python${super.lib.replaceChars ["."] [""] versionStr}";
    pythonVersionToNixpkgsPythonPackagesAttrSetName = versionStr: "${pythonVersionToNixpkgsPythonAttrSetName versionStr}Packages";

    # Some useful extensions to nix lib (used as dependency to various `default.nix` files).
    myNixLib = rec {
      cleanSourceExcludingRegexes = src: regexes: super.lib.cleanSourceWith {
          filter = (path: type:
            let relPath = super.lib.removePrefix (toString src + "/") (toString path);
            in !(super.lib.any (re: builtins.match re relPath != null) regexes)
               && super.lib.cleanSourceFilter path type);
          inherit src;
        };
      cleanPythonSource = src: cleanSourceExcludingRegexes src [
        "(^|.+/)(__pycache__|.mypy_cache|.pytest_cache)$"
        "^build$"
        ".*\.egg-info$" ".*\.pyc$"
      ];
    };

    # Add a description of the user's environement to nixpkgs package set.
    myEnv = rec {
      # Provide information that can be accessed from nix.
      info = rec {
        inherit pinnedNixpkgs;
        /*
          Should be one of the version listed when performing the following command:

          ```
          $ pypi2nix --help | grep 'python-version'
            -V, --python-version [2.6|2.7|3.2|3.3|3.4|3.5|3.6|3.7|3|pypy]
          ```
        */
        pythonVersion = "3";
      };

      pkgs = rec {
        nixpkgsPythonPackages = super."${pythonVersionToNixpkgsPythonPackagesAttrSetName info.pythonVersion}";
        #nixpkgsPythonPackages = super.python3Packages;
      };

      # Provide information that can be access from bash or other languages.
      tools = rec {
        # Print the pinned nixpkgs url when pinned, otherwise print
        # nothing and return an error.
        getPinnedNixpkgsUrl = super.writeScriptBin "my-env-get-pinned-nixpkgs-url" ''
          #!${super.bash}/bin/sh
          ${if usePinnedNixpkgs then ''
             echo "${info.pinnedNixpkgs.url}"
          '' else ''
            false
          ''}
        '';

        getPythonVersion = super.writeScriptBin "my-env-get-python-version" ''
          #!${super.bash}/bin/sh
          echo "${info.pythonVersion}"
        '';
      };
    };

    # Dependencies of various dependent `shell.nix` files.
    myPythonAttrStr = "${pythonVersionToNixpkgsPythonAttrSetName myEnv.info.pythonVersion}";
    myPythonCallPackage = path: args: self."${myPythonAttrStr}".pkgs.callPackage path args;
  };
  pkgsOverlays = [ pkgsOverlay ];

  defaultNixpkgsFn = attrs: if pinnedNixpkgs != null && usePinnedNixpkgs
    then import pinnedNixpkgs.src attrs
    else import <nixpkgs> attrs;
  sandboxPkgsFn = if customNixpkgsFn != null then customNixpkgsFn else defaultNixpkgsFn;
  sandboxPkgs = sandboxPkgsFn { overlays = [ pkgsOverlay ] ++ overlays; config = nixpkgsConfig; };

in

sandboxPkgs