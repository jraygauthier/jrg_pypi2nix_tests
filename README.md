Readme
======

This is a project whose main goal is to test and demonstrate [pypi2nix]'s
capabilities and how to properly structure a project around it.

This project might also serve as a scafolding / template / example for new
[pypi2nix] projects.

Some highlights of this project:

 -  It uses by default a pinned nixpkgs set which you can find in
    `./nix/sandbox-pkgs.nix`.

 -  It uses a completely pure environment from which to run `pypi2nix`.
    This environment is defined in `./nix/tools-deps.nix` which share
    the pinned `<nixpkgs>` with the actual project environement. We
    use nix's shebang notation to run the `update_from_requirements_txt.sh`.

 -  All `pypi2nix` arguments are encoded in the
    `update_from_requirements_txt.sh` script which make running `pypi2nix`
    a reproducible process.

 -  Uses `setuptools_scm` to version the project so that a git tag such
    as `v0.0.0` is used as the single source of truth for the project's
    version.

 -  Creation of encrypted distributions / releases using [pyce]. This is a tool
    which allow one to encrypt / sign all modules of a project and then, at
    runtime, hooking into the python import mechanic, unencrypt and validate the
    module. More info available at [soroco blog post on pyce]

 -  Provide some helper script to help one through a *private* or unofficial (i.e:
    non pypi) release process using repositories. The project also demonstrate
    how to use such releases in a setuptools / pypi2nix compliant way.


Dependencies
------------

Mandatory:

 -  [Nix](https://nixos.org/nix/download.html)

Optional:

 -  [direnv](https://direnv.net/)

    This allows for automatically entering / reloading the nix environment.


Any other dependencies will be automatically introduced / managed by nix.

Note that this project has only been tested on linux but should work on any unix
like system (i.e: systems supported by nix).


Entering the dev environment
----------------------------

```bash
$ nix-shell
```

From this environment, you should have access to all python dependencies
specified in `./requirements-dev.txt` and `./requirements.txt`.

Using direnv, it is done automatically for you upon entering the project
root dir or any of its sub dir. That is, unless this is the first time
you do so:


```bash
$ cd jrg_pypi2nix_tests/
direnv: error .envrc is blocked. Run `direnv allow` to approve its content.

$ direnv allow
direnv: loading .envrc
direnv: using nix
# ...

$ 
```


Reloading the dev environment
-----------------------------

```bash
[nix-shell] $ exit

[myuser@myuser] $ nix-shell
# ...

[nix-shell] $
```

Using direnv, it is much easier:

```bash
direnv reload
```


Building this project
---------------------

```bash
$ nix-build
```

or alternatively:

```bash
$ nix build
```

The result will be under `./result`.

Note that all the tests described in `default.nix::checkPhase` will be
performed.


Entering a prod environment
---------------------------

```bash
nix run -f .
```

From this environement, you should be able to use your program:

```bash
$ jrg_pypi2nix_tests
```

Note that same as described in [building this project] section above,
all test described in `default.nix::checkPhase` will be performed.


Refresh python dependencies from pypi
-------------------------------------

```bash
$ ./nix/update_from_requirements_txt.sh
```

This utility script uses `pypi2nix` in order to create a nix file with the set
of python dependencies specified by the following files:

 -  `requirements.txt`
 -  `requirements-dev.txt`

and generate the following files:

 -  `./nix/requirements_frozen.txt`

    The frozen requirements you are used to.

 -  `./nix/requirements.nix`

    A nix expression defining a python interpreter that has access to the frozen
    set of python dependencies.


Adding a new dependency
-----------------------

 -  A production dependency, then:

     -  Add it to `./requirements.txt` and `./setup.cfg`.

 -  A development or testing dependency, then:

     -  Add it to `./requirements-dev.txt`.

 -  [Refresh python deps from pypi]

 -  [Reload your dev env]


Creating an *sdist* / *source release( for this project
-------------------------------------------------------

One would usually have done it this way:

```bash
$ python setup.py sdist
```

however, we created a helper script `./make_sdist` which will unpack the release
to a side repository `../jrg_pypi2nix_tests-sdist` allowing one to use mere
repository for the release process (e.g: for unofficial or private release).

This also allows one to more easily iterate through the validation process.

A similar `./make_bdist.sh` helper script is provided for producing a *bdist*
in the same fashion. However, it does not function as well with the nix store
(nix store paths are used). 


Creating an *edist* / *encrypted release* for this project using pyce
---------------------------------------------------------------------

Demonstrate the process of producing encrypted distributions / releases using
[pyce]. 

This is a tool which allow one to encrypt / sign all modules of a
project and then, at runtime, hooking into the python import mechanic, unencrypt
and validate the module. 

More info available at [soroco blog post on pyce]

Same as above, we provide a simple to use helper script automating the whole
process:

```bash
$ ./make_edist
# ...
```

Once completed, the following artefacts should have been produced:

 1. `../jrg_pypi2nix_tests`: A readily versionable folder similar to the sdist
    above but with a tweak: all `*.py` module files will have been replaced by
    `*.pyce`, an encrypted and signed version of the module. 

 2. `../jrg_pypi2nix_tests-edist.pyce_keys.json`: A json fragment containing one
    key per *pyce* encrypted / signed module. This should be kept secret and can
    later be used to decrypt the module files and validate their content.


License
-------

All of this code is released under the [Apache v2.0 License].

See the copy at the root of this repository: [LICENSE].




[pypi2nix]: https://github.com/garbas/pypi2nix
[Reload your dev env]: #reloading-the-dev-environment
[Refresh python deps from pypi]: #refresh-python-dependencies-from-pypi
[building this project]: #building-this-project
[pyce]: https://github.com/soroco/pyce
[soroco blog post on pyce]: https://blog.soroco.com/
[Apache v2.0 License]: https://www.apache.org/licenses/LICENSE-2.0
[LICENSE]: ./LICENSE
