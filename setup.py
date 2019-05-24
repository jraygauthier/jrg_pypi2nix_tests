from setuptools import setup

with open("src/jrg_pypi2nix_tests/VERSION") as f:
    version = f.read().strip()

# Everything is defined in `setup.cfg`.
setup(
    # version=version,
    use_scm_version=True,
)
