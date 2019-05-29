#!/usr/bin/env bash
set -euf -o pipefail
PRJ_ROOT_DIR=`cd "$(dirname $0)" > /dev/null;pwd`

release_type="bdist"

${PRJ_ROOT_DIR}/release_tools/_make_release.sh "$release_type"
${PRJ_ROOT_DIR}/release_tools/_print_release_content.sh "$release_type"
