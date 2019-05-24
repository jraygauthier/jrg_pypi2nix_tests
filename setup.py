from setuptools import setup

FALLBACK_V_PATH = "src/jrg_pypi2nix_tests/fallback_version.txt"
FALLBACK_V_FROM_SCM_PATH = (
    "src/jrg_pypi2nix_tests/fallback_version_from_setuptools_scm.txt"
)


def parse_version(version):
    """Use parse_version from pkg_resources or distutils as available."""
    global parse_version
    try:
        from pkg_resources import parse_version
    except ImportError:
        from distutils.version import LooseVersion as parse_version
    return parse_version(version)


with open(FALLBACK_V_PATH) as f:
    fb_version_str = f.read().strip()

try:
    with open(FALLBACK_V_FROM_SCM_PATH) as f:
        fb_version_from_scm_str = f.read().strip()

    fb_version_from_scm = parse_version(fb_version_from_scm_str)
    if parse_version(fb_version_str) < fb_version_from_scm:
        fb_version_str = fb_version_from_scm_str

except FileNotFoundError:
    pass


# Everything is defined in `setup.cfg`.
setup(
    # version=fb_version_str,
    use_scm_version={
        "write_to": FALLBACK_V_FROM_SCM_PATH,
        "fallback_version": fb_version_str,
    }
)
