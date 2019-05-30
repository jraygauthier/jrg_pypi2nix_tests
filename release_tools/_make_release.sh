#!/usr/bin/env bash
set -euf -o pipefail

printf -- "Releasing this project to a separate repository\n"
printf -- "===============================================\n\n"

release_type=${1:-sdist}
setup_release_type="${2:-${release_type}}"

default_release_parent_dir=".."
release_parent_dir="${3:-${default_release_parent_dir}}"

platform_tag="$(python -c 'import distutils.util; print(distutils.util.get_platform())')"

if [ "$release_type" == "sdist" ] || [ "$release_type" == "bdist" ]; then
  setup_release_type="$release_type"
else
  # Fallback on sdist
  setup_release_type="sdist"
fi

if [ "$setup_release_type" == "bdist" ]; then
  egg_tarball_suffix=".${platform_tag}"
  release_suffix="-${release_type}-${platform_tag}"
else
  egg_tarball_suffix=""
  release_suffix="-${release_type}"
fi



egg_name_and_version_stream="$(python setup.py --name --version)"
egg_name=$(echo "$egg_name_and_version_stream" | head -n 1)
egg_name_and_version_str="$(echo $egg_name_and_version_stream | xargs printf -- '%s-%s')"
egg_tarball_filename="$PWD/dist/${egg_name_and_version_str}${egg_tarball_suffix}.tar.gz"
release_repo_dir="$release_parent_dir/${egg_name}${release_suffix}"
echo "platform_tag=\"$platform_tag\""
echo "egg_name=\"$egg_name\""
echo "egg_tarball_filename=\"$egg_tarball_filename\""
echo "release_repo_dir=\"$release_repo_dir\""
echo "release_type=\"$release_type\""
printf "\n\n\n"



printf -- "Creating a release for this project\n"
printf -- "-----------------------------------\n\n"
echo "python setup.py \"${setup_release_type}\""
python setup.py -- "${setup_release_type}"
test -f "${egg_tarball_filename}" || \
  1>&2 echo "ERROR: \"${setup_release_type}\" at \"$egg_tarball_filename\" does not exists."
printf "Done.\n\n\n"


printf -- "Removing any previous files from the repository\n"
printf -- "-----------------------------------------------\n\n"
echo "release_repo_dir=\"$release_repo_dir\""
echo "mkdir -p \"$release_repo_dir\""
mkdir -p "$release_repo_dir"
test -d "$release_repo_dir" || \
  1>&2 echo "ERROR: Target release dir at "$release_repo_dir" does not exists."

release_dir_rmved_files=$(find "$release_repo_dir" -maxdepth 1 -mindepth 1 -not -name ".git")
echo "rm -r \"\$release_dir_rmved_files\""
echo "echo \"$release_dir_rmved_files\""
echo "$release_dir_rmved_files"
echo "$release_dir_rmved_files" | \
  xargs --no-run-if-empty rm -r
printf "Done.\n\n\n"


printf -- "Extracting release content to the repository\n"
printf -- "--------------------------------------------\n\n"

echo "egg_tarball_filename=\"$egg_tarball_filename\""
echo "release_repo_dir=\"$release_repo_dir\""
tar -C "$release_repo_dir" --strip-components=1 -xvf "$egg_tarball_filename"
printf "Done.\n\n"
