#!/usr/bin/env python3
"""Convert DATASUS .dbc files into CSV tables compatible with the dashboard."""

from __future__ import annotations

import argparse
import csv
import shutil
import sys
from pathlib import Path
from tempfile import NamedTemporaryFile

from dbfread import DBF


def iter_dbc_files(root: Path):
    yield from sorted(root.rglob("*.dbc"))


def convert_file(input_path: Path, output_path: Path) -> dict:
    with NamedTemporaryFile(suffix=".dbf") as tmp:
        shutil.copy2(input_path, tmp.name)
        table = DBF(tmp.name)
        rows = list(table)

    output_path.parent.mkdir(parents=True, exist_ok=True)

    fieldnames = table.field_names
    with output_path.open("w", newline="", encoding="utf-8") as csv_file:
        writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow(row)

    return {
        "input": str(input_path),
        "output": str(output_path),
        "records": len(rows),
        "fields": len(fieldnames),
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Convert DATASUS .dbc files to CSV.")
    parser.add_argument(
        "--input-dir",
        type=Path,
        default=Path("data/datasus"),
        help="Directory containing downloaded DATASUS .dbc files.",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("data/converted"),
        help="Directory for generated CSV outputs.",
    )
    parser.add_argument(
        "--recursive",
        action="store_true",
        help="Search subdirectories for DATASUS files.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    input_dir = args.input_dir.resolve()
    if not input_dir.exists():
        print(f"Input directory not found: {input_dir}", file=sys.stderr)
        return 1

    files = list(iter_dbc_files(input_dir))
    if not files:
        print(f"No .dbc files found in {input_dir}", file=sys.stderr)
        return 1

    total = 0
    for dbc_file in files:
        rel_path = dbc_file.relative_to(input_dir)
        output_path = args.output_dir / rel_path.with_suffix(".csv")
        result = convert_file(dbc_file, output_path)
        print(
            f"{dbc_file.name}: {result['records']} rows -> {output_path}"
        )
        total += result["records"]

    print(f"Converted {len(files)} files with {total} rows total.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
