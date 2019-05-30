#!/usr/bin/env bash
set -euf -o pipefail
prj_root_dir=`cd "$(dirname $0)" > /dev/null;pwd`

release_type="sdist"

default_release_parent_dir=".."
release_parent_dir="${1:-${default_release_parent_dir}}"

${prj_root_dir}/release_tools/_make_release.sh \
  "$release_type" "$release_type" "$release_parent_dir"
${prj_root_dir}/release_tools/_print_release_content.sh \
  "$release_type" "$release_parent_dir"
