#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

REQUIRED_POTION_FIELDS = ["id", "title", "effect_type", "value"]
VALID_EFFECT_TYPES = {"heal", "gold", "block", "damage_all_enemies"}
ID_PATTERN = re.compile(r"^[a-z][a-z0-9_]*$")


@dataclass
class ValidationError:
    source_file: str
    item_index: int
    item_id: str
    field: str
    code: str
    message: str

    def to_dict(self) -> dict[str, Any]:
        return {
            "source_file": self.source_file,
            "item_index": self.item_index,
            "item_id": self.item_id,
            "field": self.field,
            "code": self.code,
            "message": self.message,
        }


def _root_dir() -> Path:
    return Path(__file__).resolve().parents[2]


def _to_repo_relative(path: Path, root: Path) -> str:
    try:
        return path.resolve().relative_to(root.resolve()).as_posix()
    except ValueError:
        return path.resolve().as_posix()


def _deterministic_generated_at(source_path: Path) -> str:
    try:
        timestamp = source_path.stat().st_mtime
    except OSError:
        return datetime.fromtimestamp(0, timezone.utc).isoformat()
    return datetime.fromtimestamp(timestamp, timezone.utc).replace(microsecond=0).isoformat()


def _append_error(
    errors: list[ValidationError],
    source_file: str,
    item_index: int,
    item_id: str,
    field: str,
    code: str,
    message: str,
) -> None:
    errors.append(
        ValidationError(
            source_file=source_file,
            item_index=item_index,
            item_id=item_id,
            field=field,
            code=code,
            message=message,
        )
    )


def _validate_potion(
    potion: Any,
    index: int,
    source_file: str,
    seen_ids: set[str],
    errors: list[ValidationError],
) -> dict[str, Any] | None:
    if not isinstance(potion, dict):
        _append_error(errors, source_file, index, "", f"potions[{index}]", "POTION_INVALID_TYPE", "potion must be an object")
        return None

    potion_id = str(potion.get("id", ""))
    for field in REQUIRED_POTION_FIELDS:
        if field not in potion:
            _append_error(errors, source_file, index, potion_id, f"potions[{index}].{field}", "POTION_MISSING_REQUIRED", f"required field '{field}' is missing")

    if any(e.item_index == index and e.code == "POTION_MISSING_REQUIRED" for e in errors):
        return None

    normalized: dict[str, Any] = {}

    id_value = potion.get("id")
    if isinstance(id_value, str) and id_value:
        if not ID_PATTERN.match(id_value):
            _append_error(errors, source_file, index, potion_id, f"potions[{index}].id", "POTION_INVALID_ID", f"id '{id_value}' must match ^[a-z][a-z0-9_]*$")
        normalized["id"] = id_value
        if id_value in seen_ids:
            _append_error(errors, source_file, index, potion_id, f"potions[{index}].id", "POTION_DUPLICATE_ID", f"duplicate potion id '{id_value}'")
        else:
            seen_ids.add(id_value)

    for str_field in ["title", "description"]:
        value = potion.get(str_field, "")
        if value is not None and isinstance(value, str):
            normalized[str_field] = value

    effect_type = potion.get("effect_type")
    if isinstance(effect_type, str) and effect_type in VALID_EFFECT_TYPES:
        normalized["effect_type"] = effect_type
    else:
        _append_error(errors, source_file, index, potion_id, f"potions[{index}].effect_type", "POTION_INVALID_EFFECT", f"effect_type must be one of {sorted(VALID_EFFECT_TYPES)}")

    value = potion.get("value")
    if isinstance(value, int) and value >= 0:
        normalized["value"] = value
    else:
        _append_error(errors, source_file, index, potion_id, f"potions[{index}].value", "POTION_INVALID_VALUE", "value must be a non-negative integer")

    if any(e.item_index == index for e in errors):
        return None

    return normalized


def _write_report(
    report_path: Path,
    source_path: Path,
    total: int,
    valid: int,
    errors: list[ValidationError],
    root: Path,
) -> None:
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report = {
        "generated_at": _deterministic_generated_at(source_path),
        "source": _to_repo_relative(source_path, root),
        "summary": {"total_potions": total, "valid_potions": valid, "error_count": len(errors)},
        "errors": [e.to_dict() for e in errors],
    }
    report_path.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def main() -> int:
    root = _root_dir()
    parser = argparse.ArgumentParser(description="Import and validate potion content data.")
    parser.add_argument("--input", required=True, help="input JSON file path")
    parser.add_argument("--report", default="runtime/modules/content_pipeline/reports/potion_import_report.json", help="validation report output path")

    args = parser.parse_args()
    input_path = Path(args.input)
    if not input_path.is_absolute():
        input_path = root / input_path
    report_path = Path(args.report)
    if not report_path.is_absolute():
        report_path = root / report_path

    errors: list[ValidationError] = []

    if not input_path.exists():
        _append_error(errors, _to_repo_relative(input_path, root), -1, "", "input", "not_found", "input file does not exist")
        _write_report(report_path, input_path, 0, 0, errors, root)
        print(f"[potion-import] failed: missing input file: {input_path}")
        return 1

    try:
        payload = json.loads(input_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        _append_error(errors, _to_repo_relative(input_path, root), -1, "", "input", "invalid_json", f"invalid JSON: {exc}")
        _write_report(report_path, input_path, 0, 0, errors, root)
        print(f"[potion-import] failed: invalid JSON: {exc}")
        return 1

    if not isinstance(payload, dict):
        _append_error(errors, _to_repo_relative(input_path, root), -1, "", "input", "invalid_type", "top-level JSON must be an object")
        _write_report(report_path, input_path, 0, 0, errors, root)
        return 1

    if payload.get("schema_version") != 1:
        _append_error(errors, _to_repo_relative(input_path, root), -1, "", "schema_version", "unsupported_version", f"expected schema_version 1")

    potions_raw = payload.get("potions")
    if not isinstance(potions_raw, list):
        _append_error(errors, _to_repo_relative(input_path, root), -1, "", "potions", "invalid_type", "'potions' must be an array")
        _write_report(report_path, input_path, 0, 0, errors, root)
        return 1

    source_file = _to_repo_relative(input_path, root)
    seen_ids: set[str] = set()
    valid_potions: list[dict[str, Any]] = []

    for index, raw in enumerate(potions_raw):
        normalized = _validate_potion(raw, index, source_file, seen_ids, errors)
        if normalized is not None:
            valid_potions.append(normalized)

    _write_report(report_path, input_path, len(potions_raw), len(valid_potions), errors, root)

    if errors:
        print("[potion-import] failed with validation errors:")
        for error in errors:
            print(f"  - {error.source_file}:{error.field} [{error.code}] {error.message}")
        return 1

    print("[potion-import] ok")
    print(f"  source: {_to_repo_relative(input_path, root)}")
    print(f"  potions: {len(valid_potions)}")
    print(f"  report: {_to_repo_relative(report_path, root)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
