from pyce import PYCEPathFinder
from json import loads
from pathlib import Path
import sys

pyce_key_file = Path("../jrg_pypi2nix_tests-edist.pyce_keys.json")
# Check if file exists.
pyce_key_file.stat()

pyce_key_dict = loads(pyce_key_file.read_text())
PYCEPathFinder.KEYS = pyce_key_dict

sys.meta_path.insert(0, PYCEPathFinder)

print(pyce_key_dict)
