#!/usr/bin/env python


"""Provide a command line tool to fetch an SBML document from an online repository."""


import argparse
import logging
import sys
from pathlib import Path
from typing import List, Optional

import httpx
from cobra.io import AbstractModelRepository, BiGGModels, BioModels


logger = logging.getLogger()


def fetch_sbml(
    model_id: str, repositories: List[AbstractModelRepository]
) -> Optional[bytes]:
    """Fetch gzipped SBML from repositories using the given model identifier."""
    for repo in repositories:
        try:
            return repo.get_sbml(model_id)
        except httpx.HTTPStatusError as error:
            if error.response.status_code == 404:
                logger.debug(
                    "Failed to fetch model from '%s': '%s'\n",
                    model_id,
                    repo.name,
                    exc_info=error,
                )
                continue
            else:
                logger.debug("", exc_info=error)
                logger.critical(
                    "Failed to fetch model from '%s': '%s'\n",
                    model_id,
                    repo.name,
                )
                sys.exit(1)


def parse_args(argv: Optional[List[str]] = None) -> argparse.Namespace:
    """Define and immediately parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Fetch a metabolic model in gzipped SBML format."
    )
    parser.add_argument(
        "model_id",
        metavar="MODEL_ID",
        help="The identifier for the model in a supported database.",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        help="Where the gzipped SBML document should be written to "
        "(default '<MODEL_ID>.sbml.gz').",
        default=None,
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

    if args.output is None:
        args.output = Path(f"{args.model_id}.sbml.gz")
    else:
        args.output.parent.mkdir(parents=True, exist_ok=True)

    content = fetch_sbml(args.model_id, [BiGGModels(), BioModels()])
    if content is None:
        logger.critical("Failed to fetch model '%s'.", args.model_id)
        sys.exit(1)
    else:
        with args.output.open("wb") as handle:
            handle.write(content)


if __name__ == "__main__":
    sys.exit(main())
