#!/usr/bin/env bash
set -euf -o pipefail
prj_root_dir=`cd "$(dirname $0)" > /dev/null;pwd`

release_type="edist"

egg_name_and_version_stream="$(python setup.py --name --version)"
egg_name=$(echo "$egg_name_and_version_stream" | head -n 1)
release_suffix="-${release_type}"

default_release_keys_output_file="$prj_root_dir/../${egg_name}${release_suffix}.pyce_keys.json"
release_keys_output_file="${1:-${default_release_keys_output_file}}"

default_release_parent_dir=".."
release_parent_dir="${2:-${default_release_parent_dir}}"

${prj_root_dir}/release_tools/_make_release.sh \
  "$release_type" "sdist" "$release_parent_dir"
${prj_root_dir}/release_tools/_encrypt_release.sh \
  "$release_type" "$release_keys_output_file" "$release_parent_dir"
${prj_root_dir}/release_tools/_print_release_content.sh \
  "$release_type" "$release_parent_dir"