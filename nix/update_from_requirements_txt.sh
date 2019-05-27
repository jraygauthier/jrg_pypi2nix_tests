#!/usr/bin/env nix-shell
#!nix-shell --pure tools-deps.nix -i bash
set -euf -o pipefail

myEnvPythonVersion="$(my-env-get-python-version)"

if myEnvPinnedNixpkgsUrl="$(my-env-get-pinned-nixpkgs-url)"; then
  export NIX_PATH="nixpkgs=${myEnvPinnedNixpkgsUrl}"
else
  1>&2 echo "WARNING: Could not access pinned nixpkgs url. Using installed nixpkgs from '<nixpkgs>'."
fi

echo "myEnvPythonVersion=\"${myEnvPythonVersion}\""
echo "myEnvPinnedNixpkgsUrl=\"${myEnvPinnedNixpkgsUrl}\""


test -w /nix/var/nix/db || \
  export NIX_REMOTE=daemon
export LOCALE_ARCHIVE="`nix-build --no-out-link  '<nixpkgs>' -A glibcLocales`/lib/locale/locale-archive"
# export LC_ALL=en_CA.utf8
export LANG=en_US.UTF-8

#
# Use the 'pypi2nix' utility to generate / update `requirements.nix`, a nix set of python package that
# correspond to the content of the 'requirement.txt' file. See [garbas/pypi2nix: Generate Nix
# expressions for Python package](https://github.com/garbas/pypi2nix) for more details.
#


SCRIPT_DIR=`cd "$(dirname $0)" > /dev/null;pwd`
REPO_ROOT_DIR=`cd "$(dirname $0)/.." > /dev/null;pwd`

pushd "$REPO_ROOT_DIR" > /dev/null

verbosity_args="-vvv"

interpreter_args="-V ${myEnvPythonVersion}"
reqs_args="-r ./requirements.txt -r ./requirements-dev.txt"
# -e "../#egg=jrg_pypi2nix_tests" \
# overrides_args="--overrides ./nix/python_overrides.nix"
# overrides_args=""
overrides_args="--default-overrides"
generated_files_args="--basename ./nix/requirements"

# Note that moving the cache as part of the repo
# cause issues as the cache itself becomes part of
# the sources.
# TODO: Fix this by excluding those files
# from the sdist and bdist.
# cache_dir="./.pypi2nix_cache"
#
# Note that even tough a cache dir is specified here,
# pypi2nix still use the user's cache for some operations
# (e.g.: "/run/user/1000/pypi2nix/").
# In case you end up with a "OSError: [Errno 28] No space left on device"
# error, you should most likely clear this tmp as the user temp dir
# is usually mounted as a ram fs with limited storage capacity.
cache_dir="$HOME/.cache/pypi2nix_cache"
cache_args="--cache-dir ${cache_dir}"
mkdir -p "${cache_dir}"

#
# All of the setup time dependencies (i.e: which need to be
# present when pypi2nix call each dependency's setup.py
# in order to know the transitive deps).
#
common_setup_args='-s setuptools-scm -s pytest-runner'
pyce_setup_args='-s cryptography'

setup_args=$(cat <<EOF
${common_setup_args} \
${pyce_setup_args}
EOF
)

pypi2nix_cmd=$(cat <<EOF
pypi2nix \
${verbosity_args} \
${interpreter_args} \
${reqs_args} \
${overrides_args} \
${cache_args} \
${generated_files_args} \
${setup_args}
EOF
)

echo "${pypi2nix_cmd}"
${pypi2nix_cmd}


popd > /dev/null
