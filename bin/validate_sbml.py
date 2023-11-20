#!/usr/bin/env python


"""Provide a command line tool to validate an SBML document."""


import argparse
import gzip
import json
import logging
import sys
from pathlib import Path
from typing import Dict, List, Optional, Tuple

from cobra.io import validate_sbml_model


logger = logging.getLogger()


def validate_sbml(sbml: Path) -> Tuple[bool, Dict]:
    """Validate the SBML document and return a report."""
    model, report = validate_sbml_model(
        sbml,
        check_model=True,
        internal_consistency=True,
        check_units_consistency=True,
        check_modeling_practice=True,
    )
    is_valid = True
    if model is None:
        is_valid = False
    if len(report["SBML_FATAL"]) > 0:
        is_valid = False
    if len(report["COBRA_FATAL"]) > 0:
        is_valid = False
    return is_valid, report


def parse_args(argv: Optional[List[str]] = None) -> argparse.Namespace:
    """Define and immediately parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Validate an SBML document for use with COBRApy."
    )
    parser.add_argument(
        "sbml",
        type=Path,
        help="The SBML document as a (gzipped) file.",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        help="Where the validation report should be written to. Output is "
        "gzip-compressed JSON.",
        default=Path("report.json.gz"),
    )
    parser.add_argument(
        "-l",
        "--log-level",
        help="The desired log level (default WARNING).",
        choices=("CRITICAL", "ERROR", "WARNING", "INFO", "DEBUG"),
        default="WARNING",
    )
    return parser.parse_args(argv)


def main(argv: Optional[List[str]] = None) -> None:
    """Coordinate argument parsing and program execution."""
    args = parse_args(argv)
    logging.basicConfig(level=args.log_level, format="[%(levelname)s] %(message)s")

    if not args.sbml.is_file():
        logger.critical("File '{}' not found.", str(args.sbml))
        sys.exit(1)

    args.output.parent.mkdir(parents=True, exist_ok=True)

    is_valid, report = validate_sbml(args.sbml)

    with gzip.open(args.output, "wt") as handle:
        json.dump(report, handle, separators=(",", ":"))

    if is_valid:
        logger.info("SBML document '%s' is **valid** for use in COBRApy.", args.sbml)
        print("valid")
    else:
        logger.critical(
            "SBML document '%s' is **invalid** for use in COBRApy.", args.sbml
        )
        print("invalid")
        sys.exit(1)


if __name__ == "__main__":
    main()
