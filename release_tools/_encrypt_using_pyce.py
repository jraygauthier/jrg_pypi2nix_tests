import argparse
import os.path
import logging
import itertools
import json
from pyce import encrypt_path
from dataclasses import dataclass
from pathlib import Path
from typing import List, Optional

LOGGER = logging.getLogger(__name__)


@dataclass(frozen=True)
class _Args:
    paths_to_encrypt: List[Path]
    project_root_dir: Optional[Path]
    output_file: Optional[Path]
    excluded_files: List[Path]


def _parse_args() -> _Args:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "paths",
        nargs="+",
        help="Paths of file or a folders to encrypt using pyce."
    )
    parser.add_argument(
        "-C",
        dest="root_dir",
        help="Project root directory."
    )
    parser.add_argument(
        "-o",
        dest="output_file",
        help="Output file where the per module key dictionary will be output as json."
    )
    parser.add_argument(
        "--excluded-file",
        action='append',
        dest="excluded_files",
        help="A list of file paths that should not be encrypted",
        default=[]
    )

    args = parser.parse_args()

    paths_to_encrypt = [Path(p) for p in args.paths]
    project_root_dir = None if args.root_dir is None else Path(args.root_dir)
    output_file = None if args.output_file is None else Path(args.output_file)
    excluded_files = [Path(p) for p in args.excluded_files]

    return _Args(
        paths_to_encrypt=paths_to_encrypt,
        project_root_dir=project_root_dir,
        output_file=output_file,
        excluded_files=excluded_files
    )


def main() -> None:
    args = _parse_args()
    LOGGER.info("Encrypting some files / directory using pyce.")
    paths = [p.expanduser().resolve() for p in args.paths_to_encrypt]
    excluded = [p.expanduser().resolve() for p in args.excluded_files]

    for p in paths:
        # Ensure the file exists.
        p.stat()
        # print("p: {}".format(p))

    for p in excluded:
        # Ensure the file exists.
        p.stat()
        # print("excluded: {}".format(p))

    if args.project_root_dir is None:
        root_dir = Path.cwd()
    else:
        # Ensure the file exists.
        args.project_root_dir.stat()
        root_dir = args.project_root_dir.resolve()

    if args.output_file is not None:
        # Ensure the file's parent dir exists.
        args.output_file.parent.stat()

    excluded_set=set(excluded)
    encrypted_paths = [
        encrypt_path(
            p,
            # TODO: Investigate. The exclusions do not seem to be effective.
            exclusions=excluded_set
        )
        for p in paths
    ]

    def mk_rel_to_root(k: str):
        kp = Path(k)
        # Ensure the file exists.
        kp.stat()
        return str(kp.relative_to(root_dir))

    per_path_key = list(itertools.chain.from_iterable(encrypted_paths))
    per_path_key_dict = {mk_rel_to_root(k): v for k, v in per_path_key}
    per_path_key_json = json.dumps(
        per_path_key_dict, sort_keys=True, indent=2)

    if args.output_file is None:
        # When no output file specified, print to stdout.
        print(per_path_key_json)
    else:
        # args.output_file.touch()
        args.output_file.write_text(per_path_key_json)

main()
