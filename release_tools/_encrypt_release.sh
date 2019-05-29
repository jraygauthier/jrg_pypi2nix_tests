#!/usr/bin/env bash
set -euf -o pipefail

RTOOLS_ROOT_DIR=`cd "$(dirname $0)" > /dev/null;pwd`

release_type="${1:-edist}"

egg_name_and_version_stream="$(python setup.py --name --version)"
egg_name=$(echo "$egg_name_and_version_stream" | head -n 1)
release_suffix="-${release_type}"

default_release_keys_output_file="../${egg_name}${release_suffix}.pyce_keys"
release_keys_output_file="${2:-${default_release_keys_output_file}}"

release_repo_dir="../${egg_name}${release_suffix}"
release_keys_dir="$(dirname $release_keys_output_file)"

printf -- "Encrypting release repository content\n"
printf -- "-------------------------------------\n\n"

echo "egg_name=\"$egg_name\""
echo "release_type=\"$release_type\""
echo "release_keys_repo_dir=\"$release_repo_dir\""
echo "release_keys_output_file=\"$release_keys_output_file\""
echo "release_keys_dir=\"$release_keys_dir\""

test -d "$release_repo_dir" || \
  1>&2 echo "ERROR: Target release dir at "$release_repo_dir" does not exists."
test -d "$release_keys_dir" || \
  1>&2 echo "ERROR: Target release keys output file's parent dir "$release_keys_dir" does not exists."

to_be_encrypted_dirs=$(cat <<EOF
${release_repo_dir}/src
EOF
)

to_be_compiled_py_files="$(echo "$to_be_encrypted_dirs" | xargs -r -I % find % -iname '*.py')"

echo "$ echo \"\$to_be_compiled_py_files\""
echo "$to_be_compiled_py_files"

echo "$ python -m compileall -b \"\$to_be_compiled_py_files\""

echo "$to_be_compiled_py_files" | \
  xargs python -m compileall -b


to_be_encrypted_pyc_files="$(echo "$to_be_encrypted_dirs" | xargs -r -I % find % -iname '*.pyc')"
echo "$ echo \"\$to_be_encrypted_pyc_files\""
echo "$to_be_encrypted_pyc_files"

echo "$ python $RTOOLS_ROOT_DIR/_encrypt_using_pyce.py \"\$to_be_encrypted_pyc_files\""
echo "$to_be_encrypted_pyc_files" | \
  xargs python $RTOOLS_ROOT_DIR/_encrypt_using_pyce.py \
    -C "$release_repo_dir" \
    -o "$release_keys_output_file"


to_be_removed_python_files="$(echo "$to_be_encrypted_dirs" | xargs -r -I % find % -iname '*.py' -o -iname '*.pyc')"

echo "$ echo \"\$to_be_removed_python_files\""
echo "$to_be_removed_python_files"

echo "$ rm \"\$to_be_encrypted_py_files\""

echo "$to_be_removed_python_files" | \
  xargs rm

printf "\n"
echo "$ ls -la \"\$release_keys_output_file\""
ls -la "$release_keys_output_file"

printf "\n\n"
