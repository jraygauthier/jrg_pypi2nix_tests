Readme
======

This is a project whose main goal is to test and demonstrate pypi2nix's
capabilities and how to properly structure a project around it.


Dependencies
------------

Mandatory:

 -  [Nix](https://nixos.org/nix/download.html)

Optional:

 -  [direnv](https://direnv.net/)

    This allows for automatically


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


Refresh python dependencies from pypi
-------------------------------------

```bash
$ ./nix/update_from_requirements_txt.sh
```

This will update the following files:

 -  `./nix/requirements.nix`
 -  `./nix/requirements_frozen.txt`


Adding a new dependency
-----------------------

 -  A production dependency, then:

     -  Add it to `./requirements.txt` and `./setup.cfg`.

 -  A development or testing dependency, then:

     -  Add it to `./requirements-dev.txt`.

 -  [Refresh python deps from pypi]

 -  [Reload your dev env]



[Reload your dev env]: #reloading-the-dev-environment
[Refresh python deps from pypi]: #refresh-python-dependencies-from-pypi
