{ pkgs, python }:

let
 removeDependencies = names: deps:
    with builtins; with pkgs.lib;
      filter
      (drv: all
        (suf:
          ! hasSuffix ("-" + suf)
          (parseDrvName drv.name).name
        )
        names
      )
      deps;
in

self: super: {

  "more-itertools" = python.overrideDerivation super."more-itertools" (old: {
    buildInputs = old.buildInputs ++ [ self."setuptools-scm" ];
   });

  "py" = python.overrideDerivation super."py" (old: {
    buildInputs = old.buildInputs ++ [ self."setuptools-scm" ];
   });

  "pytest-runner" = python.overrideDerivation super."pytest-runner" (old: {
    buildInputs = old.buildInputs ++ [ self."setuptools-scm" ];
   });

  "mccabe" = python.overrideDerivation super."mccabe" (old: {
    buildInputs = old.buildInputs ++ [ self."pytest-runner" ];
   });

  "attrs" = python.overrideDerivation super."attrs" (old: {
    propagatedBuildInputs =
      removeDependencies [ "pytest" ] old.propagatedBuildInputs;
  });

  "cryptography" = python.overrideDerivation super."cryptography" (old: {
    propagatedBuildInputs =
      removeDependencies [ "flake8" ] old.propagatedBuildInputs;
  });

  "zipp" = python.overrideDerivation super."zipp" (old: {
    buildInputs = old.buildInputs ++ [ self."setuptools-scm" ];
    propagatedBuildInputs =
      removeDependencies [ "pytest" ] old.propagatedBuildInputs;
  });

  "pluggy" = python.overrideDerivation super."pluggy" (old: {
    buildInputs = old.buildInputs ++ [ self."setuptools-scm" ];
   });
}