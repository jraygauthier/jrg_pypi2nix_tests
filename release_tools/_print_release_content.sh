#!/usr/bin/env bash
set -euf -o pipefail

RTOOLS_ROOT_DIR=`cd "$(dirname $0)" > /dev/null;pwd`

release_type=${1:-sdist}

platform_tag="$(python -c 'import distutils.util; print(distutils.util.get_platform())')"
egg_name_and_version_stream="$(python setup.py --name --version)"
egg_name=$(echo "$egg_name_and_version_stream" | head -n 1)
if [ "$release_type" == "bdist" ]; then
  release_suffix="-${release_type}-${platform_tag}"
else
  release_suffix="-${release_type}"
fi
release_repo_dir="../${egg_name}${release_suffix}"

printf -- "Printing final release repository content\n"
printf -- "-----------------------------------------\n\n"

echo "All release files after encryption are:"
echo "$ ls -R -la \"$release_repo_dir\""
ls -R -la "$release_repo_dir"

printf "\n"