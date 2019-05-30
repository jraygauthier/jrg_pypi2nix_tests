#!/usr/bin/env bash
set -euf -o pipefail
prj_root_dir=`cd "$(dirname $0)" > /dev/null;pwd`

# This is the location the pyce keys should have ended up
# if you ran './make_edist.sh' without arguments.
default_pyce_keys_file_path="$prj_root_dir/../jrg_pypi2nix_tests-edist.pyce_keys.json"

# Otherwise, you can pass another location for the file as first argument.
pyce_keys_file_path="${1:-${default_pyce_keys_file_path}}"

PYCE_KEYS_FILE_JRG_PYPI2NIX_TESTS="$pyce_keys_file_path" jrg_pypi2nix_tests
