#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

REQUIRED_ENEMY_FIELDS = ["id", "max_health"]
REQUIRED_ENCOUNTER_FIELDS = ["id", "enemies"]
REQUIRED_INTENT_FIELDS = ["name", "type"]
REQUIRED_EFFECT_FIELDS = ["op"]
VALID_INTENT_TYPES = {"conditional", "chance_based"}
VALID_EFFECT_OPS = {"damage", "block", "apply_status", "heal"}
VALID_EFFECT_TARGETS = {"player", "self"}
VALID_TAGS = {"common", "elite", "boss"}
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


def _validate_id_format(
    value: str,
    field_prefix: str,
    errors: list[ValidationError],
    source_file: str,
    item_index: int,
    item_id: str,
) -> bool:
    if not ID_PATTERN.match(value):
        _append_error(
            errors,
            source_file,
            item_index,
            item_id,
            f"{field_prefix}",
            "ENEMY_INVALID_ID_FORMAT",
            f"id '{value}' must match pattern ^[a-z][a-z0-9_]*$",
        )
        return False
    return True


def _validate_effect(
    effect: dict[str, Any],
    effect_index: int,
    field_prefix: str,
    errors: list[ValidationError],
    source_file: str,
    item_index: int,
    item_id: str,
) -> bool:
    op = effect.get("op")
    if not isinstance(op, str) or op not in VALID_EFFECT_OPS:
        _append_error(
            errors,
            source_file,
            item_index,
            item_id,
            f"{field_prefix}.op",
            "ENEMY_INVALID_EFFECT",
            f"op must be one of {sorted(VALID_EFFECT_OPS)}",
        )
        return False

    if op in {"damage", "block", "heal"}:
        amount = effect.get("amount")
        if not isinstance(amount, int):
            _append_error(
                errors,
                source_file,
                item_index,
                item_id,
                f"{field_prefix}.amount",
                "ENEMY_INVALID_EFFECT",
                "'amount' must be an integer",
            )
            return False
        if amount < 0:
            _append_error(
                errors,
                source_file,
                item_index,
                item_id,
                f"{field_prefix}.amount",
                "ENEMY_INVALID_EFFECT",
                "'amount' must be >= 0",
            )
            return False
    elif op == "apply_status":
        status_id = effect.get("status_id")
        stacks = effect.get("stacks")
        if not isinstance(status_id, str) or not status_id:
            _append_error(
                errors,
                source_file,
                item_index,
                item_id,
                f"{field_prefix}.status_id",
                "ENEMY_INVALID_EFFECT",
                "'status_id' must be a non-empty string",
            )
            return False
        if not isinstance(stacks, int):
            _append_error(
                errors,
                source_file,
                item_index,
                item_id,
                f"{field_prefix}.stacks",
                "ENEMY_INVALID_EFFECT",
                "'stacks' must be an integer",
            )
            return False
        if stacks < 1:
            _append_error(
                errors,
                source_file,
                item_index,
                item_id,
                f"{field_prefix}.stacks",
                "ENEMY_INVALID_EFFECT",
                "'stacks' must be >= 1",
            )
            return False

    target = effect.get("target", "player")
    if target not in VALID_EFFECT_TARGETS:
        _append_error(
            errors,
            source_file,
            item_index,
            item_id,
            f"{field_prefix}.target",
            "ENEMY_INVALID_EFFECT",
            f"target must be one of {sorted(VALID_EFFECT_TARGETS)}",
        )
        return False

    return True


def _validate_intent(
    intent: Any,
    intent_index: int,
    field_prefix: str,
    errors: list[ValidationError],
    source_file: str,
    item_index: int,
    item_id: str,
) -> bool:
    if not isinstance(intent, dict):
        _append_error(
            errors,
            source_file,
            item_index,
            item_id,
            f"{field_prefix}",
            "ENEMY_INVALID_INTENT",
            "intent must be an object",
        )
        return False

    for field in REQUIRED_INTENT_FIELDS:
        if field not in intent:
            _append_error(
                errors,
                source_file,
                item_index,
                item_id,
                f"{field_prefix}.{field}",
                "ENEMY_INVALID_INTENT",
                f"required field '{field}' is missing",
            )

    intent_type = intent.get("type")
    if isinstance(intent_type, str) and intent_type not in VALID_INTENT_TYPES:
        _append_error(
            errors,
            source_file,
            item_index,
            item_id,
            f"{field_prefix}.type",
            "ENEMY_INVALID_INTENT",
            f"type must be one of {sorted(VALID_INTENT_TYPES)}",
        )

    if intent_type == "chance_based":
        weight = intent.get("weight")
        if weight is None:
            _append_error(
                errors,
                source_file,
                item_index,
                item_id,
                f"{field_prefix}.weight",
                "ENEMY_INVALID_INTENT",
                "chance_based intent requires 'weight'",
            )
        elif not isinstance(weight, (int, float)):
            _append_error(
                errors,
                source_file,
                item_index,
                item_id,
                f"{field_prefix}.weight",
                "ENEMY_INVALID_INTENT",
                "'weight' must be a number",
            )
        elif weight < 0:
            _append_error(
                errors,
                source_file,
                item_index,
                item_id,
                f"{field_prefix}.weight",
                "ENEMY_INVALID_INTENT",
                "'weight' must be >= 0",
            )

    if intent_type == "conditional":
        condition = intent.get("condition")
        if not isinstance(condition, str) or not condition:
            _append_error(
                errors,
                source_file,
                item_index,
                item_id,
                f"{field_prefix}.condition",
                "ENEMY_INVALID_INTENT",
                "conditional intent requires 'condition' string",
            )

    effects = intent.get("effects", [])
    if isinstance(effects, list):
        for eff_idx, effect in enumerate(effects):
            if isinstance(effect, dict):
                _validate_effect(
                    effect,
                    eff_idx,
                    f"{field_prefix}.effects[{eff_idx}]",
                    errors,
                    source_file,
                    item_index,
                    item_id,
                )

    return not any(
        e.item_index == item_index and e.field.startswith(field_prefix) for e in errors
    )


def _validate_enemy(
    enemy: Any,
    index: int,
    source_file: str,
    seen_ids: set[str],
    errors: list[ValidationError],
) -> dict[str, Any] | None:
    if not isinstance(enemy, dict):
        _append_error(
            errors,
            source_file,
            index,
            "",
            f"enemies[{index}]",
            "ENEMY_INVALID_TYPE",
            "enemy must be an object",
        )
        return None

    enemy_id = str(enemy.get("id", ""))
    for field in REQUIRED_ENEMY_FIELDS:
        if field not in enemy:
            _append_error(
                errors,
                source_file,
                index,
                enemy_id,
                f"enemies[{index}].{field}",
                "ENEMY_MISSING_REQUIRED",
                f"required field '{field}' is missing",
            )

    normalized: dict[str, Any] = {}

    id_value = enemy.get("id")
    if isinstance(id_value, str) and id_value:
        _validate_id_format(
            id_value, f"enemies[{index}].id", errors, source_file, index, enemy_id
        )
        normalized["id"] = id_value
        if id_value in seen_ids:
            _append_error(
                errors,
                source_file,
                index,
                enemy_id,
                f"enemies[{index}].id",
                "ENEMY_DUPLICATE_ID",
                f"duplicate enemy id '{id_value}'",
            )
        else:
            seen_ids.add(id_value)

    name = enemy.get("name")
    if name is not None and isinstance(name, str):
        normalized["name"] = name

    max_health = enemy.get("max_health")
    if isinstance(max_health, int):
        if max_health < 1 or max_health > 9999:
            _append_error(
                errors,
                source_file,
                index,
                enemy_id,
                f"enemies[{index}].max_health",
                "ENEMY_INVALID_VALUE",
                "max_health must be between 1 and 9999",
            )
        else:
            normalized["max_health"] = max_health

    intents = enemy.get("intents", [])
    normalized_intents: list[dict[str, Any]] = []
    if isinstance(intents, list):
        if len(intents) == 0:
            _append_error(
                errors,
                source_file,
                index,
                enemy_id,
                f"enemies[{index}].intents",
                "ENEMY_INVALID_INTENT",
                "intents must contain at least one item",
            )
        else:
            for intent_idx, intent in enumerate(intents):
                _validate_intent(
                    intent,
                    intent_idx,
                    f"enemies[{index}].intents[{intent_idx}]",
                    errors,
                    source_file,
                    index,
                    enemy_id,
                )
                if isinstance(intent, dict):
                    normalized_intents.append(intent)
    normalized["intents"] = normalized_intents

    tags = enemy.get("tags", [])
    if isinstance(tags, list):
        for tag in tags:
            if tag not in VALID_TAGS:
                _append_error(
                    errors,
                    source_file,
                    index,
                    enemy_id,
                    f"enemies[{index}].tags",
                    "ENEMY_INVALID_VALUE",
                    f"tag '{tag}' must be one of {sorted(VALID_TAGS)}",
                )
        normalized["tags"] = tags

    art_path = enemy.get("art_path")
    if art_path is not None:
        normalized["art_path"] = art_path

    ai_scene_path = enemy.get("ai_scene_path")
    if ai_scene_path is not None:
        normalized["ai_scene_path"] = ai_scene_path

    if any(e.item_index == index for e in errors):
        return None

    return normalized


def _validate_encounter(
    encounter: Any,
    index: int,
    source_file: str,
    enemy_ids: set[str],
    seen_encounter_ids: set[str],
    errors: list[ValidationError],
) -> dict[str, Any] | None:
    if not isinstance(encounter, dict):
        _append_error(
            errors,
            source_file,
            index,
            "",
            f"encounters[{index}]",
            "ENEMY_INVALID_TYPE",
            "encounter must be an object",
        )
        return None

    encounter_id = str(encounter.get("id", ""))
    for field in REQUIRED_ENCOUNTER_FIELDS:
        if field not in encounter:
            _append_error(
                errors,
                source_file,
                index,
                encounter_id,
                f"encounters[{index}].{field}",
                "ENEMY_MISSING_REQUIRED",
                f"required field '{field}' is missing",
            )

    normalized: dict[str, Any] = {}

    id_value = encounter.get("id")
    if isinstance(id_value, str) and id_value:
        _validate_id_format(
            id_value,
            f"encounters[{index}].id",
            errors,
            source_file,
            index,
            encounter_id,
        )
        normalized["id"] = id_value
        if id_value in seen_encounter_ids:
            _append_error(
                errors,
                source_file,
                index,
                encounter_id,
                f"encounters[{index}].id",
                "ENEMY_DUPLICATE_ID",
                f"duplicate encounter id '{id_value}'",
            )
        else:
            seen_encounter_ids.add(id_value)

    enemies = encounter.get("enemies")
    if isinstance(enemies, list):
        if len(enemies) == 0:
            _append_error(
                errors,
                source_file,
                index,
                encounter_id,
                f"encounters[{index}].enemies",
                "ENEMY_INVALID_VALUE",
                "enemies must contain at least one enemy id",
            )
        elif len(enemies) > 5:
            _append_error(
                errors,
                source_file,
                index,
                encounter_id,
                f"encounters[{index}].enemies",
                "ENEMY_INVALID_VALUE",
                "enemies cannot contain more than 5 enemy ids",
            )
        else:
            for enemy_ref in enemies:
                if enemy_ref not in enemy_ids:
                    _append_error(
                        errors,
                        source_file,
                        index,
                        encounter_id,
                        f"encounters[{index}].enemies",
                        "ENEMY_UNKNOWN_REFERENCE",
                        f"unknown enemy id '{enemy_ref}'",
                    )
        normalized["enemies"] = enemies

    weight = encounter.get("weight", 1)
    if isinstance(weight, int) and weight >= 1:
        normalized["weight"] = weight

    floor_range = encounter.get("floor_range")
    if floor_range is not None:
        normalized["floor_range"] = floor_range

    tags = encounter.get("tags", [])
    if isinstance(tags, list):
        normalized["tags"] = tags

    if any(e.item_index == index for e in errors):
        return None

    return normalized


def _write_report(
    report_path: Path,
    source_path: Path,
    total_enemies: int,
    valid_enemies: int,
    total_encounters: int,
    valid_encounters: int,
    errors: list[ValidationError],
    root: Path,
) -> None:
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "source": _to_repo_relative(source_path, root),
        "summary": {
            "total_enemies": total_enemies,
            "valid_enemies": valid_enemies,
            "total_encounters": total_encounters,
            "valid_encounters": valid_encounters,
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
        description="Import and validate enemy content data."
    )
    parser.add_argument(
        "--input",
        required=True,
        help="input JSON file path (repo-relative or absolute)",
    )
    parser.add_argument(
        "--report",
        default="runtime/modules/content_pipeline/reports/enemy_import_report.json",
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
        _write_report(report_path, input_path, 0, 0, 0, 0, errors, root)
        print(f"[enemy-import] failed: missing input file: {input_path}")
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
        _write_report(report_path, input_path, 0, 0, 0, 0, errors, root)
        print(f"[enemy-import] failed: invalid JSON: {exc}")
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
        _write_report(report_path, input_path, 0, 0, 0, 0, errors, root)
        print("[enemy-import] failed: top-level JSON must be an object")
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

    enemies_raw = payload.get("enemies")
    if not isinstance(enemies_raw, list):
        _append_error(
            errors,
            _to_repo_relative(input_path, root),
            -1,
            "",
            "enemies",
            "invalid_type",
            "top-level 'enemies' must be an array",
        )
        _write_report(report_path, input_path, 0, 0, 0, 0, errors, root)
        print("[enemy-import] failed: 'enemies' must be an array")
        return 1

    source_file = _to_repo_relative(input_path, root)
    seen_enemy_ids: set[str] = set()
    normalized_enemies: list[dict[str, Any]] = []

    for index, raw_enemy in enumerate(enemies_raw):
        normalized = _validate_enemy(
            raw_enemy, index, source_file, seen_enemy_ids, errors
        )
        if normalized is not None:
            normalized_enemies.append(normalized)

    enemy_id_set = {e["id"] for e in normalized_enemies if "id" in e}

    encounters_raw = payload.get("encounters", [])
    normalized_encounters: list[dict[str, Any]] = []
    seen_encounter_ids: set[str] = set()

    if isinstance(encounters_raw, list):
        for index, raw_encounter in enumerate(encounters_raw):
            normalized = _validate_encounter(
                raw_encounter,
                index,
                source_file,
                enemy_id_set,
                seen_encounter_ids,
                errors,
            )
            if normalized is not None:
                normalized_encounters.append(normalized)

    if errors:
        _write_report(
            report_path=report_path,
            source_path=input_path,
            total_enemies=len(enemies_raw),
            valid_enemies=len(normalized_enemies),
            total_encounters=len(encounters_raw)
            if isinstance(encounters_raw, list)
            else 0,
            valid_encounters=len(normalized_encounters),
            errors=errors,
            root=root,
        )
        print("[enemy-import] failed with validation errors:")
        for error in errors:
            print(
                "  - {source}:{field} [{code}] {message}".format(
                    source=error.source_file,
                    field=error.field,
                    code=error.code,
                    message=error.message,
                )
            )
        print(f"[enemy-import] report: {_to_repo_relative(report_path, root)}")
        return 1

    _write_report(
        report_path=report_path,
        source_path=input_path,
        total_enemies=len(normalized_enemies),
        valid_enemies=len(normalized_enemies),
        total_encounters=len(normalized_encounters),
        valid_encounters=len(normalized_encounters),
        errors=errors,
        root=root,
    )

    print("[enemy-import] ok")
    print(f"  source: {_to_repo_relative(input_path, root)}")
    print(f"  enemies: {len(normalized_enemies)}")
    print(f"  encounters: {len(normalized_encounters)}")
    print(f"  report: {_to_repo_relative(report_path, root)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
