#!/usr/bin/env bash
set -euf -o pipefail

printf -- "Releasing this project to a separate repository\n"
printf -- "===============================================\n\n"
egg_name_and_version="$(python setup.py --name --version)"
egg_name=$(echo "$egg_name_and_version" | head -n 1)
egg_tarball_filename="$PWD/dist/$(echo $egg_name_and_version | xargs printf -- '%s-%s').tar.gz"
release_repo_dir="../${egg_name}_release"
echo "egg_name=\"$egg_name\""
echo "egg_tarball_filename=\"$egg_tarball_filename\""
echo "release_repo_dir=\"$release_repo_dir\""
printf "\n\n\n"

printf -- "Creating an sdist for this project\n"
printf -- "----------------------------------\n\n"
echo "python setup.py sdist"
python setup.py sdist
test -f "${egg_tarball_filename}" || \
  1>&2 echo "ERROR: sdist at \"$egg_tarball_filename\" does not exists."
printf "Done.\n\n\n"

printf -- "Removing any previous files from the repository\n"
printf -- "-----------------------------------------------\n\n"
release_dir_rmved_files=$(find "$release_repo_dir" -maxdepth 1 -mindepth 1 -not -name ".git")

echo "release_repo_dir=\"$release_repo_dir\""
echo "rm -r \"\$release_dir_rmved_files\""
echo "echo \"$release_dir_rmved_files\""
echo "$release_dir_rmved_files"
echo "$release_dir_rmved_files" | \
  xargs --no-run-if-empty rm -r
printf "Done.\n\n\n"

printf -- "Extracting sdist content to the repository\n"
printf -- "------------------------------------------\n\n"

echo "egg_tarball_filename=\"$egg_tarball_filename\""
echo "release_repo_dir=\"$release_repo_dir\""
mkdir -p "$release_repo_dir"
test -d "$release_repo_dir" || \
  1>&2 echo "ERROR: Target release dir at "$release_repo_dir" does not exists."
tar -C "$release_repo_dir" --strip-components=1 -xvf "$egg_tarball_filename"
printf "Done.\n\n"

echo "Release top level content is:"
echo "ls -la \"$release_repo_dir\""
ls -la "$release_repo_dir"
