#!/usr/bin/env python3
"""Download and aggregate DATASUS SIA/SIH oncology data.

The importer streams one DBC at a time and stores a checkpoint after every
file, so interrupted multi-year imports can be resumed safely.
"""

from __future__ import annotations

import argparse
import concurrent.futures
import ftplib
import json
import re
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path

from dbc_reader import DbcReader


FTP_HOST = "ftp.datasus.gov.br"
REMOTE_DIRS = {
    "SIA": "/dissemin/publicos/SIASUS/200801_/Dados",
    "SIH": "/dissemin/publicos/SIHSUS/200801_/Dados",
}
FILE_RE = re.compile(
    # Large PA files can be split by DATASUS (for example PASP2401a.dbc,
    # PASP2401b.dbc).  The former strict pattern silently discarded them.
    r"^(?P<prefix>PA|RD)(?P<uf>[A-Z]{2})(?P<yy>\d{2})"
    r"(?P<month>0[1-9]|1[0-2])(?P<part>[a-z])?\.dbc$",
    re.IGNORECASE,
)
UF_REGIONS = {
    **dict.fromkeys(("AC", "AP", "AM", "PA", "RO", "RR", "TO"), "Norte"),
    **dict.fromkeys(("AL", "BA", "CE", "MA", "PB", "PE", "PI", "RN", "SE"), "Nordeste"),
    **dict.fromkeys(("DF", "GO", "MS", "MT"), "Centro-Oeste"),
    **dict.fromkeys(("ES", "MG", "RJ", "SP"), "Sudeste"),
    **dict.fromkeys(("PR", "RS", "SC"), "Sul"),
}
TUMOR_CID_PREFIXES = {
    "Câncer de mama": ("C50",),
    "Câncer de colo": ("C53",),
    "Câncer de pulmão": ("C34",),
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Import oncology costs from DATASUS SIA and SIH DBC files."
    )
    parser.add_argument("--start-year", type=int, default=2015)
    parser.add_argument("--end-year", type=int, default=2026)
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("assets/data/oncologia_summary.json"),
    )
    parser.add_argument(
        "--work-dir", type=Path, default=Path("data/datasus-oncology")
    )
    parser.add_argument("--keep-dbc", action="store_true")
    parser.add_argument("--workers", type=int, default=4)
    parser.add_argument("--limit", type=int, help="Process only N files (for testing).")
    return parser.parse_args()


def connect() -> ftplib.FTP:
    ftp = ftplib.FTP(FTP_HOST, timeout=90)
    ftp.login()
    ftp.set_pasv(True)
    return ftp


def available_files(start_year: int, end_year: int) -> list[tuple[str, str, str]]:
    selected: list[tuple[str, str, str]] = []
    with connect() as ftp:
        for system, remote_dir in REMOTE_DIRS.items():
            for remote_name in ftp.nlst(remote_dir):
                filename = Path(remote_name).name
                match = FILE_RE.match(filename)
                if not match:
                    continue
                expected_prefix = "PA" if system == "SIA" else "RD"
                year = 2000 + int(match.group("yy"))
                if match.group("prefix").upper() != expected_prefix:
                    continue
                if start_year <= year <= end_year:
                    selected.append((system, remote_dir, filename))
    return sorted(
        selected,
        key=lambda item: (
            item[2][4:6],
            item[2][6:8],
            item[0],
            item[2][2:4],
            item[2].lower(),
        ),
    )


def normalize_cid(value: object) -> str:
    return re.sub(r"[^A-Z0-9]", "", str(value or "").upper())


def is_malignant_cid(cid: str) -> bool:
    if not re.fullmatch(r"C\d{2}[A-Z0-9]?", cid):
        return False
    return 0 <= int(cid[1:3]) <= 97


def tumor_types(cids: list[str]) -> list[str]:
    matches = [
        tumor
        for tumor, prefixes in TUMOR_CID_PREFIXES.items()
        if any(cid.startswith(prefixes) for cid in cids)
    ]
    return ["Oncologia geral", *matches]


def sia_values(row: dict) -> tuple[bool, list[str], float]:
    cids = [normalize_cid(row.get(field)) for field in ("PA_CIDPRI", "PA_CIDSEC", "PA_CIDCAS")]
    procedure = str(row.get("PA_PROC_ID") or "").strip()
    oncology_procedure = procedure.startswith(("0304", "0416"))
    return (
        oncology_procedure or any(is_malignant_cid(cid) for cid in cids),
        cids,
        float(row.get("PA_VALAPR") or 0),
    )


def sih_values(row: dict) -> tuple[bool, list[str], float]:
    fields = ["DIAG_PRINC", "DIAG_SECUN", *[f"DIAGSEC{i}" for i in range(1, 10)]]
    cids = [normalize_cid(row.get(field)) for field in fields]
    return (
        any(is_malignant_cid(cid) for cid in cids),
        cids,
        float(row.get("VAL_TOT") or 0),
    )


def load_checkpoint(path: Path) -> tuple[set[str], defaultdict[str, float]]:
    totals: defaultdict[str, float] = defaultdict(float)
    if not path.exists():
        return set(), totals
    payload = json.loads(path.read_text(encoding="utf-8"))
    totals.update({key: float(value) for key, value in payload.get("totals", {}).items()})
    return set(payload.get("processedFiles", [])), totals


def save_checkpoint(path: Path, processed: set[str], totals: dict[str, float]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    payload = {"processedFiles": sorted(processed), "totals": dict(totals)}
    temporary = path.with_suffix(".tmp")
    temporary.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")
    temporary.replace(path)


def download(remote_dir: str, filename: str, destination: Path) -> None:
    partial = destination.with_suffix(f"{destination.suffix}.part")
    with connect() as ftp, partial.open("wb") as handle:
        ftp.retrbinary(f"RETR {remote_dir}/{filename}", handle.write, blocksize=1024 * 1024)
    partial.replace(destination)


def aggregate_file(system: str, filename: str, path: Path, totals: defaultdict[str, float]) -> int:
    match = FILE_RE.match(filename)
    if not match:
        return 0
    year = 2000 + int(match.group("yy"))
    month = int(match.group("month"))
    region = UF_REGIONS[match.group("uf").upper()]
    included = 0
    extractor = sia_values if system == "SIA" else sih_values

    for row in DbcReader(path):
        is_oncology, cids, cost = extractor(row)
        if not is_oncology or cost <= 0:
            continue
        included += 1
        for tumor in tumor_types(cids):
            for geography in ("Brasil", region):
                key = json.dumps(
                    [year, month, geography, tumor, system], ensure_ascii=False
                )
                totals[key] += cost
    return included


def process_file(task: tuple[str, str, str, str, bool]) -> tuple[str, int, dict[str, float]]:
    system, remote_dir, filename, download_dir_value, keep_dbc = task
    download_dir = Path(download_dir_value)
    path = download_dir / filename
    file_totals: defaultdict[str, float] = defaultdict(float)
    try:
        if not path.exists():
            download(remote_dir, filename, path)
        included = aggregate_file(system, filename, path, file_totals)
        return filename, included, dict(file_totals)
    finally:
        if path.exists() and not keep_dbc:
            path.unlink()
        partial = path.with_suffix(f"{path.suffix}.part")
        if partial.exists() and not keep_dbc:
            partial.unlink()


def write_summary(
    output: Path,
    processed: set[str],
    totals: dict[str, float],
    available: set[str] | None = None,
) -> None:
    rows = []
    for encoded_key, cost in totals.items():
        year, month, region, tumor, system = json.loads(encoded_key)
        rows.append(
            {
                "year": year,
                "month": month,
                "region": region,
                "tumorType": tumor,
                "system": system,
                "cost": round(cost, 2),
            }
        )
    rows.sort(
        key=lambda row: (
            row["year"],
            row["month"],
            row["region"],
            row["tumorType"],
            row["system"],
        )
    )
    coverage_sets: defaultdict[tuple[int, int, str], set[str]] = defaultdict(set)
    source_file_counts: defaultdict[tuple[int, str], int] = defaultdict(int)
    for filename in processed:
        match = FILE_RE.match(filename)
        if not match:
            continue
        year = 2000 + int(match.group("yy"))
        month = int(match.group("month"))
        system = "SIA" if match.group("prefix").upper() == "PA" else "SIH"
        uf = match.group("uf").upper()
        coverage_sets[(year, month, system)].add(uf)
        source_file_counts[(year, system)] += 1

    coverage = []
    for (year, month, system), ufs in sorted(coverage_sets.items()):
        coverage.append(
            {
                "year": year,
                "month": month,
                "system": system,
                "coveredStates": len(ufs),
                "expectedStates": len(UF_REGIONS),
                "complete": len(ufs) == len(UF_REGIONS),
            }
        )

    complete_years = []
    years = sorted({year for year, _, _ in coverage_sets})
    for year in years:
        coverage_complete = all(
            len(coverage_sets[(year, month, system)]) == len(UF_REGIONS)
            for month in range(1, 13)
            for system in REMOTE_DIRS
        )
        expected_for_year = {
            filename
            for filename in (available or set())
            if (match := FILE_RE.match(filename))
            and 2000 + int(match.group("yy")) == year
        }
        files_complete = not expected_for_year or expected_for_year <= processed
        if coverage_complete and files_complete:
            complete_years.append(year)

    payload = {
        "generatedAt": datetime.now(timezone.utc).isoformat(),
        "schemaVersion": 2,
        "source": f"ftp://{FTP_HOST}/dissemin/publicos/",
        "methodology": (
            "Valor aprovado da produção ambulatorial (SIA PA_VALAPR) e valor total "
            "das AIH (SIH VAL_TOT). Recorte próprio: CID-10 C00-C97 ou, no SIA, "
            "procedimentos dos grupos 0304/0416. Não representa custo econômico nem "
            "necessariamente pagamento efetivo."
        ),
        "processedFiles": len(processed),
        "dataStatus": (
            "complete"
            if available is not None and available <= processed
            else "partial"
        ),
        "pendingFiles": (
            len(available - processed) if available is not None else None
        ),
        "completeYears": complete_years,
        "coverage": coverage,
        "summary": rows,
    }
    output.parent.mkdir(parents=True, exist_ok=True)
    temporary = output.with_suffix(".tmp")
    temporary.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
    temporary.replace(output)


def main() -> int:
    args = parse_args()
    if args.start_year > args.end_year:
        raise SystemExit("--start-year must be less than or equal to --end-year")

    args.work_dir.mkdir(parents=True, exist_ok=True)
    checkpoint = args.work_dir / "checkpoint-monthly.json"
    download_dir = args.work_dir / "dbc"
    download_dir.mkdir(parents=True, exist_ok=True)
    processed, totals = load_checkpoint(checkpoint)
    all_files = available_files(args.start_year, args.end_year)
    available_names = {item[2] for item in all_files}
    files = [item for item in all_files if item[2] not in processed]
    pending_total = len(files)
    if args.limit is not None:
        files = files[: args.limit]

    print(
        f"Found {pending_total} pending files; {len(processed)} already processed; "
        f"processing {len(files)} in this run.",
        flush=True,
    )
    tasks = [
        (system, remote_dir, filename, str(download_dir), args.keep_dbc)
        for system, remote_dir, filename in files
    ]
    with concurrent.futures.ProcessPoolExecutor(max_workers=args.workers) as executor:
        task_iterator = iter(tasks)
        pending: dict[concurrent.futures.Future, tuple[str, str, str, str, bool]] = {}

        def submit_next() -> bool:
            try:
                task = next(task_iterator)
            except StopIteration:
                return False
            pending[executor.submit(process_file, task)] = task
            return True

        for _ in range(min(len(tasks), args.workers * 2)):
            submit_next()

        completed = 0
        while pending:
            done, _ = concurrent.futures.wait(
                pending,
                return_when=concurrent.futures.FIRST_COMPLETED,
            )
            for future in done:
                pending.pop(future)
                filename, included, file_totals = future.result()
                for key, cost in file_totals.items():
                    totals[key] += cost
                processed.add(filename)
                completed += 1
                save_checkpoint(checkpoint, processed, totals)
                write_summary(args.output, processed, totals, available_names)
                print(
                    f"[{completed}/{len(files)}] {filename}: included rows={included}; "
                    f"total processed={len(processed)}",
                    flush=True,
                )
                submit_next()

    write_summary(args.output, processed, totals, available_names)
    print(f"Done: {len(processed)} files -> {args.output}", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
