#!/usr/bin/env bash
set -euf -o pipefail
PRJ_ROOT_DIR=`cd "$(dirname $0)" > /dev/null;pwd`

release_type="edist"

egg_name_and_version_stream="$(python setup.py --name --version)"
egg_name=$(echo "$egg_name_and_version_stream" | head -n 1)
release_suffix="-${release_type}"

default_release_keys_output_file="../${egg_name}${release_suffix}.pyce_keys"
release_keys_output_file="${1:-${default_release_keys_output_file}}"

${PRJ_ROOT_DIR}/release_tools/_make_release.sh "$release_type" "sdist"
${PRJ_ROOT_DIR}/release_tools/_encrypt_release.sh "$release_type" "$release_keys_output_file"
${PRJ_ROOT_DIR}/release_tools/_print_release_content.sh "$release_type"