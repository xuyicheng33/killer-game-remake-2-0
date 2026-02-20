#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

REQUIRED_RELIC_FIELDS = ["id", "title"]
VALID_RARITIES = {"common", "uncommon", "rare", "boss", "special", "starter"}
VALID_TAGS = {"starter", "obtainable", "special"}
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


def _validate_relic(
    relic: Any,
    index: int,
    source_file: str,
    seen_ids: set[str],
    errors: list[ValidationError],
) -> dict[str, Any] | None:
    if not isinstance(relic, dict):
        _append_error(
            errors,
            source_file,
            index,
            "",
            f"relics[{index}]",
            "RELIC_INVALID_TYPE",
            "relic must be an object",
        )
        return None

    relic_id = str(relic.get("id", ""))
    for field in REQUIRED_RELIC_FIELDS:
        if field not in relic:
            _append_error(
                errors,
                source_file,
                index,
                relic_id,
                f"relics[{index}].{field}",
                "RELIC_MISSING_REQUIRED",
                f"required field '{field}' is missing",
            )

    normalized: dict[str, Any] = {}

    id_value = relic.get("id")
    if isinstance(id_value, str) and id_value:
        if not ID_PATTERN.match(id_value):
            _append_error(
                errors,
                source_file,
                index,
                relic_id,
                f"relics[{index}].id",
                "RELIC_INVALID_ID_FORMAT",
                f"id '{id_value}' must match pattern ^[a-z][a-z0-9_]*$",
            )
        else:
            normalized["id"] = id_value
            if id_value in seen_ids:
                _append_error(
                    errors,
                    source_file,
                    index,
                    relic_id,
                    f"relics[{index}].id",
                    "RELIC_DUPLICATE_ID",
                    f"duplicate relic id '{id_value}'",
                )
            else:
                seen_ids.add(id_value)

    title = relic.get("title")
    if title is not None:
        if not isinstance(title, str) or not title.strip():
            _append_error(
                errors,
                source_file,
                index,
                relic_id,
                f"relics[{index}].title",
                "RELIC_INVALID_VALUE",
                "'title' must be a non-empty string",
            )
        else:
            normalized["title"] = title.strip()

    description = relic.get("description")
    if description is not None:
        if not isinstance(description, str):
            _append_error(
                errors,
                source_file,
                index,
                relic_id,
                f"relics[{index}].description",
                "RELIC_INVALID_VALUE",
                "'description' must be a string",
            )
        else:
            normalized["description"] = description

    rarity = relic.get("rarity", "common")
    if not isinstance(rarity, str) or rarity not in VALID_RARITIES:
        _append_error(
            errors,
            source_file,
            index,
            relic_id,
            f"relics[{index}].rarity",
            "RELIC_INVALID_RARITY",
            f"rarity must be one of {sorted(VALID_RARITIES)}",
        )
    else:
        normalized["rarity"] = rarity

    starter = relic.get("starter", False)
    if not isinstance(starter, bool):
        _append_error(
            errors,
            source_file,
            index,
            relic_id,
            f"relics[{index}].starter",
            "RELIC_INVALID_VALUE",
            "'starter' must be a boolean",
        )
    else:
        normalized["starter"] = starter

    effects = relic.get("effects")
    normalized_effects: dict[str, Any] = {}
    if effects is not None:
        if not isinstance(effects, dict):
            _append_error(
                errors,
                source_file,
                index,
                relic_id,
                f"relics[{index}].effects",
                "RELIC_INVALID_VALUE",
                "'effects' must be an object",
            )
        else:
            valid_effect_fields = {
                "on_battle_start_heal": (int, 0, 9999),
                "on_card_played_gold": (int, 0, 9999),
                "card_play_interval": (int, 1, 99),
                "on_player_hit_block": (int, 0, 9999),
                "on_enemy_killed_gold": (int, 0, 9999),
                "on_turn_start_block": (int, 0, 9999),
                "on_turn_end_heal": (int, 0, 9999),
                "shop_discount_percent": (int, 0, 90),
                "on_run_start_gold": (int, 0, 9999),
                "on_run_start_max_health": (int, 0, 9999),
                "on_turn_start_energy": (int, 0, 99),
                "on_turn_start_damage": (int, 0, 9999),
                "on_enemy_killed_strength": (int, 0, 99),
                "on_enemy_killed_damage": (int, 0, 9999),
                "on_enemy_killed_draw": (int, 0, 99),
                "on_battle_end_heal_per_kill": (int, 0, 9999),
                "on_attack_played_strength": (int, 0, 99),
                "attack_play_strength_max": (int, 0, 99),
                "on_run_start_strength": (int, 0, 99),
            }
            for eff_field, (eff_type, min_val, max_val) in valid_effect_fields.items():
                if eff_field in effects:
                    val = effects[eff_field]
                    if not isinstance(val, eff_type):
                        _append_error(
                            errors,
                            source_file,
                            index,
                            relic_id,
                            f"relics[{index}].effects.{eff_field}",
                            "RELIC_INVALID_EFFECT",
                            f"'{eff_field}' must be an integer",
                        )
                    elif val < min_val or val > max_val:
                        _append_error(
                            errors,
                            source_file,
                            index,
                            relic_id,
                            f"relics[{index}].effects.{eff_field}",
                            "RELIC_INVALID_EFFECT",
                            f"'{eff_field}' must be between {min_val} and {max_val}",
                        )
                    else:
                        normalized_effects[eff_field] = val
            for eff_field in effects:
                if eff_field not in valid_effect_fields:
                    _append_error(
                        errors,
                        source_file,
                        index,
                        relic_id,
                        f"relics[{index}].effects.{eff_field}",
                        "RELIC_UNKNOWN_EFFECT_FIELD",
                        f"unknown effect field '{eff_field}'; valid fields: {sorted(valid_effect_fields)}",
                    )
            normalized["effects"] = normalized_effects

    tags = relic.get("tags", [])
    if isinstance(tags, list):
        for tag in tags:
            if tag not in VALID_TAGS:
                _append_error(
                    errors,
                    source_file,
                    index,
                    relic_id,
                    f"relics[{index}].tags",
                    "RELIC_INVALID_VALUE",
                    f"tag '{tag}' must be one of {sorted(VALID_TAGS)}",
                )
        normalized["tags"] = tags

    art_path = relic.get("art_path")
    if art_path is not None:
        normalized["art_path"] = art_path

    if any(e.item_index == index for e in errors):
        return None

    return normalized


def _write_report(
    report_path: Path,
    source_path: Path,
    total_relics: int,
    valid_relics: int,
    errors: list[ValidationError],
    root: Path,
) -> None:
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "source": _to_repo_relative(source_path, root),
        "summary": {
            "total_relics": total_relics,
            "valid_relics": valid_relics,
            "error_count": len(errors),
        },
        "errors": [error.to_dict() for error in errors],
    }
    report_path.write_text(
        json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )


def main() -> int:
    root = _root_dir()
    parser = argparse.ArgumentParser(
        description="Import and validate relic content data."
    )
    parser.add_argument(
        "--input",
        required=True,
        help="input JSON file path (repo-relative or absolute)",
    )
    parser.add_argument(
        "--report",
        default="runtime/modules/content_pipeline/reports/relic_import_report.json",
        help="validation report output path",
    )

    args = parser.parse_args()

    input_path = Path(args.input)
    if not input_path.is_absolute():
        input_path = root / input_path

    report_path = Path(args.report)
    if not report_path.is_absolute():
        report_path = root / report_path

    errors: list[ValidationError] = []

    if not input_path.exists():
        _append_error(
            errors,
            _to_repo_relative(input_path, root),
            -1,
            "",
            "input",
            "not_found",
            "input file does not exist",
        )
        _write_report(report_path, input_path, 0, 0, errors, root)
        print(f"[relic-import] failed: missing input file: {input_path}")
        return 1

    try:
        payload = json.loads(input_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        _append_error(
            errors,
            _to_repo_relative(input_path, root),
            -1,
            "",
            "input",
            "invalid_json",
            f"invalid JSON: {exc}",
        )
        _write_report(report_path, input_path, 0, 0, errors, root)
        print(f"[relic-import] failed: invalid JSON: {exc}")
        return 1

    if not isinstance(payload, dict):
        _append_error(
            errors,
            _to_repo_relative(input_path, root),
            -1,
            "",
            "input",
            "invalid_type",
            "top-level JSON value must be an object",
        )
        _write_report(report_path, input_path, 0, 0, errors, root)
        print("[relic-import] failed: top-level JSON must be an object")
        return 1

    schema_version = payload.get("schema_version")
    if schema_version != 1:
        _append_error(
            errors,
            _to_repo_relative(input_path, root),
            -1,
            "",
            "schema_version",
            "unsupported_version",
            f"unsupported schema_version {schema_version}, expected 1",
        )

    relics_raw = payload.get("relics")
    if not isinstance(relics_raw, list):
        _append_error(
            errors,
            _to_repo_relative(input_path, root),
            -1,
            "",
            "relics",
            "invalid_type",
            "top-level 'relics' must be an array",
        )
        _write_report(report_path, input_path, 0, 0, errors, root)
        print("[relic-import] failed: 'relics' must be an array")
        return 1

    source_file = _to_repo_relative(input_path, root)
    seen_ids: set[str] = set()
    normalized_relics: list[dict[str, Any]] = []

    for index, raw_relic in enumerate(relics_raw):
        normalized = _validate_relic(raw_relic, index, source_file, seen_ids, errors)
        if normalized is not None:
            normalized_relics.append(normalized)

    if errors:
        _write_report(
            report_path=report_path,
            source_path=input_path,
            total_relics=len(relics_raw),
            valid_relics=len(normalized_relics),
            errors=errors,
            root=root,
        )
        print("[relic-import] failed with validation errors:")
        for error in errors:
            print(
                "  - {source}:{field} [{code}] {message}".format(
                    source=error.source_file,
                    field=error.field,
                    code=error.code,
                    message=error.message,
                )
            )
        print(f"[relic-import] report: {_to_repo_relative(report_path, root)}")
        return 1

    _write_report(
        report_path=report_path,
        source_path=input_path,
        total_relics=len(normalized_relics),
        valid_relics=len(normalized_relics),
        errors=errors,
        root=root,
    )

    print("[relic-import] ok")
    print(f"  source: {_to_repo_relative(input_path, root)}")
    print(f"  relics: {len(normalized_relics)}")
    print(f"  report: {_to_repo_relative(report_path, root)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
