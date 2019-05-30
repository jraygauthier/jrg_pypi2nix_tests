import sys
import os
from pyce import PYCEPathFinder
from json import loads
from pathlib import Path


def install_pyce_w_keys():
    pyce_key_file = None
    try:
        pyce_key_file_env_str = os.environ['PYCE_KEYS_FILE_JRG_PYPI2NIX_TESTS'].strip()
        # Support the case where the env var was explicitly left empty. This might
        # be useful for testing purposes or even establish the expectation that
        # the project is installed *unencrypted".
        if pyce_key_file_env_str:
            pyce_key_file = Path(pyce_key_file_env_str)
            # Check if file exists.
            pyce_key_file.stat()
    except KeyError:
        # Fallback on this convenience path (this is meant only for
        # demonstration purpose and not to be used in a production setup).
        pyce_key_file = Path("../jrg_pypi2nix_tests-edist.pyce_keys.json")
        try:
            # Check if file exists.
            pyce_key_file.stat()
        except FileNotFoundError:
            pass

    if pyce_key_file is not None:
        pyce_key_dict = loads(pyce_key_file.read_text())
        PYCEPathFinder.KEYS = pyce_key_dict

    # Note how we still install the path finder even tough not key are loaded.
    # This is so that the loader can give us better error message in case it
    # encounter encrypted modules.
    sys.meta_path.insert(0, PYCEPathFinder)


install_pyce_w_keys()
