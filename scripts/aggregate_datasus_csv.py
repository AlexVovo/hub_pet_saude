#!/usr/bin/env python3
"""Aggregate DATASUS CSV outputs into dashboard-ready JSON."""

from __future__ import annotations

import argparse
import csv
import json
import re
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterable


def normalize_number(value: object) -> float:
    if value is None:
        return 0.0
    text = str(value).strip()
    if not text or text.lower() in {"nan", "null", "none", "n/a"}:
        return 0.0
    text = text.replace("R$", "").replace("%", "")
    if "," in text and "." in text:
        text = text.replace(".", "").replace(",", ".")
    elif "," in text:
        text = text.replace(",", ".")
    text = text.replace(".", "", text.count(".") - 1 if text.count(".") > 1 else 0)
    try:
        return float(text)
    except ValueError:
        return 0.0


def candidate_cost_columns(headers: Iterable[str]) -> list[str]:
    header_names = [h.strip() for h in headers if h and h.strip()]
    normalized = {h.upper(): h for h in header_names}

    preferred = [
        "AP_VL_AP",
        "VL_AP",
        "VALOR",
        "VALOR_TOTAL",
        "VLR_AP",
        "VAL_TOT",
        "VALORTOTAL",
        "VLR_TOTAL",
        "TOTAL",
        "VTOTAL",
        "VALOR_TOTAL",
    ]
    for field in preferred:
        if field in normalized:
            return [normalized[field]]

    matches = []
    for header in header_names:
        upper = header.upper()
        if any(token in upper for token in ("VL_", "VAL", "VLR", "TOTAL")) and "DATE" not in upper:
            matches.append(header)
    return matches[:5]


def infer_year_from_path(path: Path) -> int:
    matches = re.findall(r"(19\d{2}|20\d{2})", path.name)
    if matches:
        try:
            return int(matches[-1])
        except ValueError:
            return 0
    return 0


def infer_system(path: Path) -> str:
    if "SIASUS" in path.parts:
        return "SIA"
    if "SIHSUS" in path.parts:
        return "SIH"
    if "painel_oncologia" in path.parts:
        return "PAINEL_ONCOLOGIA"
    return "GERAL"


def infer_region(row: dict, path: Path) -> str:
    for key in ("AP_UFMUN", "UF", "MUNIC_LOC", "REGIAO", "REGIAO_SAUDE"):
        value = str(row.get(key, "") or "").strip()
        if value:
            return value
    return "Brasil"


def infer_tumor(row: dict) -> str:
    for key in ("CIDPRI", "CIDCAS", "AP_PRINCIPAL", "AP_PRIPAL", "CMPT", "DIAGNOSTICO"):
        value = str(row.get(key, "") or "").strip()
        if value:
            return value
    return "Oncologia geral"


def aggregate_csvs(input_dir: Path) -> list[dict]:
    records: list[dict] = []
    for csv_path in sorted(input_dir.rglob("*.csv")):
        if not any(segment in csv_path.parts for segment in ("SIASUS", "SIHSUS", "painel_oncologia")):
            continue

        with csv_path.open("r", encoding="utf-8", newline="") as handle:
            reader = csv.DictReader(handle)
            if not reader.fieldnames:
                continue

            cost_cols = candidate_cost_columns(reader.fieldnames)
            if not cost_cols:
                continue

            for row in reader:
                total_cost = 0.0
                for col in cost_cols:
                    total_cost += normalize_number(row.get(col))
                if total_cost <= 0:
                    continue

                records.append({
                    "year": infer_year_from_path(csv_path),
                    "region": infer_region(row, csv_path),
                    "tumorType": infer_tumor(row),
                    "system": infer_system(csv_path),
                    "cost": round(total_cost, 2),
                    "source": csv_path.name,
                })

    return records


def build_summary(records: list[dict]) -> dict:
    grouped: dict[tuple[str, str, str, str], float] = defaultdict(float)
    for record in records:
        key = (str(record["year"]), str(record["region"]), str(record["tumorType"]), str(record["system"]))
        grouped[key] += float(record["cost"])

    dashboard_rows = []
    for (year, region, tumor_type, system), cost in sorted(grouped.items()):
        dashboard_rows.append({
            "year": int(year),
            "region": region,
            "tumorType": tumor_type,
            "system": system,
            "cost": round(cost, 2),
        })

    return {
        "generatedAt": datetime.now(timezone.utc).isoformat(),
        "totalRecords": len(records),
        "summary": dashboard_rows,
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Aggregate converted DATASUS CSV files to dashboard JSON.")
    parser.add_argument("--input-dir", type=Path, required=True, help="Directory containing converted DATASUS CSV files.")
    parser.add_argument("--output", type=Path, required=True, help="Path to write aggregated JSON output.")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    input_dir = args.input_dir.resolve()
    if not input_dir.exists():
        print(f"Input directory not found: {input_dir}", file=None)
        return 1

    records = aggregate_csvs(input_dir)
    payload = build_summary(records)
    output = args.output
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Aggregated {len(records)} rows into {output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
