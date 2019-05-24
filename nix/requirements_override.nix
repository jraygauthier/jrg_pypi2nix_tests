{ pkgs, python }:

let

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
}