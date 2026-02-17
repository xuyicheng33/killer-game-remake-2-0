#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

REQUIRED_EVENT_FIELDS = ["id", "title", "description", "options"]
REQUIRED_OPTION_FIELDS = ["label", "effect"]
VALID_EFFECT_TYPES = {
    "none",
    "gold",
    "heal",
    "gold_for_hp",
    "add_card",
    "add_card_for_hp",
    "buy_card",
    "upgrade_card",
    "upgrade_for_hp",
    "remove_card",
    "heal_for_gold",
    "max_hp",
    "cards_for_hp",
}
VALID_TAGS = {"common", "rare", "special"}
ID_PATTERN = re.compile(r"^[a-z][a-z0-9_]*$")

EFFECT_REQUIRED_FIELDS: dict[str, list[str]] = {
    "gold": ["value"],
    "heal": ["value"],
    "gold_for_hp": ["gold", "hp"],
    "add_card": [],
    "add_card_for_hp": ["hp"],
    "buy_card": ["cost"],
    "upgrade_card": [],
    "upgrade_for_hp": ["hp"],
    "remove_card": [],
    "heal_for_gold": ["gold", "heal"],
    "max_hp": ["value"],
    "cards_for_hp": ["hp"],
    "none": [],
}


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


def _validate_option(
    option: Any,
    option_index: int,
    field_prefix: str,
    errors: list[ValidationError],
    source_file: str,
    item_index: int,
    item_id: str,
) -> dict[str, Any] | None:
    if not isinstance(option, dict):
        _append_error(
            errors,
            source_file,
            item_index,
            item_id,
            f"{field_prefix}",
            "EVENT_INVALID_OPTION",
            "option must be an object",
        )
        return None

    for field in REQUIRED_OPTION_FIELDS:
        if field not in option:
            _append_error(
                errors,
                source_file,
                item_index,
                item_id,
                f"{field_prefix}.{field}",
                "EVENT_INVALID_OPTION",
                f"required field '{field}' is missing",
            )

    normalized: dict[str, Any] = {}

    label = option.get("label")
    if label is not None:
        if not isinstance(label, str) or not label.strip():
            _append_error(
                errors,
                source_file,
                item_index,
                item_id,
                f"{field_prefix}.label",
                "EVENT_INVALID_OPTION",
                "'label' must be a non-empty string",
            )
        else:
            normalized["label"] = label.strip()

    effect = option.get("effect")
    if effect is not None:
        if not isinstance(effect, str) or effect not in VALID_EFFECT_TYPES:
            _append_error(
                errors,
                source_file,
                item_index,
                item_id,
                f"{field_prefix}.effect",
                "EVENT_UNKNOWN_EFFECT_TYPE",
                f"effect must be one of {sorted(VALID_EFFECT_TYPES)}",
            )
        else:
            normalized["effect"] = effect
            required = EFFECT_REQUIRED_FIELDS.get(effect, [])
            for req_field in required:
                if req_field not in option:
                    _append_error(
                        errors,
                        source_file,
                        item_index,
                        item_id,
                        f"{field_prefix}.{req_field}",
                        "EVENT_INVALID_OPTION",
                        f"effect '{effect}' requires '{req_field}'",
                    )
                else:
                    val = option[req_field]
                    if not isinstance(val, int):
                        _append_error(
                            errors,
                            source_file,
                            item_index,
                            item_id,
                            f"{field_prefix}.{req_field}",
                            "EVENT_INVALID_OPTION",
                            f"'{req_field}' must be an integer",
                        )
                    else:
                        if req_field in {"hp", "heal"} and val < 0:
                            _append_error(
                                errors,
                                source_file,
                                item_index,
                                item_id,
                                f"{field_prefix}.{req_field}",
                                "EVENT_INVALID_OPTION",
                                f"'{req_field}' must be >= 0",
                            )
                        elif req_field == "cost" and val < 0:
                            _append_error(
                                errors,
                                source_file,
                                item_index,
                                item_id,
                                f"{field_prefix}.{req_field}",
                                "EVENT_INVALID_OPTION",
                                f"'{req_field}' must be >= 0",
                            )
                        normalized[req_field] = val

    value = option.get("value")
    if value is not None:
        if not isinstance(value, int):
            _append_error(
                errors,
                source_file,
                item_index,
                item_id,
                f"{field_prefix}.value",
                "EVENT_INVALID_OPTION",
                "'value' must be an integer",
            )
        else:
            normalized["value"] = value

    count = option.get("count")
    if count is not None:
        if not isinstance(count, int):
            _append_error(
                errors,
                source_file,
                item_index,
                item_id,
                f"{field_prefix}.count",
                "EVENT_INVALID_OPTION",
                "'count' must be an integer",
            )
        elif count < 1:
            _append_error(
                errors,
                source_file,
                item_index,
                item_id,
                f"{field_prefix}.count",
                "EVENT_INVALID_OPTION",
                "'count' must be >= 1",
            )
        else:
            normalized["count"] = count

    requires_gold = option.get("requires_gold")
    if requires_gold is not None:
        if not isinstance(requires_gold, int) or requires_gold < 0:
            _append_error(
                errors,
                source_file,
                item_index,
                item_id,
                f"{field_prefix}.requires_gold",
                "EVENT_INVALID_OPTION",
                "'requires_gold' must be an integer >= 0",
            )
        else:
            normalized["requires_gold"] = requires_gold

    requires_hp_percentage = option.get("requires_hp_percentage")
    if requires_hp_percentage is not None:
        if (
            not isinstance(requires_hp_percentage, (int, float))
            or requires_hp_percentage < 0
            or requires_hp_percentage > 1
        ):
            _append_error(
                errors,
                source_file,
                item_index,
                item_id,
                f"{field_prefix}.requires_hp_percentage",
                "EVENT_INVALID_OPTION",
                "'requires_hp_percentage' must be between 0 and 1",
            )
        else:
            normalized["requires_hp_percentage"] = requires_hp_percentage

    if any(
        e.item_index == item_index and e.field.startswith(field_prefix) for e in errors
    ):
        return None

    return normalized


def _validate_event(
    event: Any,
    index: int,
    source_file: str,
    seen_ids: set[str],
    errors: list[ValidationError],
) -> dict[str, Any] | None:
    if not isinstance(event, dict):
        _append_error(
            errors,
            source_file,
            index,
            "",
            f"events[{index}]",
            "EVENT_INVALID_TYPE",
            "event must be an object",
        )
        return None

    event_id = str(event.get("id", ""))
    for field in REQUIRED_EVENT_FIELDS:
        if field not in event:
            _append_error(
                errors,
                source_file,
                index,
                event_id,
                f"events[{index}].{field}",
                "EVENT_MISSING_REQUIRED",
                f"required field '{field}' is missing",
            )

    normalized: dict[str, Any] = {}

    id_value = event.get("id")
    if isinstance(id_value, str) and id_value:
        if not ID_PATTERN.match(id_value):
            _append_error(
                errors,
                source_file,
                index,
                event_id,
                f"events[{index}].id",
                "EVENT_INVALID_ID_FORMAT",
                f"id '{id_value}' must match pattern ^[a-z][a-z0-9_]*$",
            )
        else:
            normalized["id"] = id_value
            if id_value in seen_ids:
                _append_error(
                    errors,
                    source_file,
                    index,
                    event_id,
                    f"events[{index}].id",
                    "EVENT_DUPLICATE_ID",
                    f"duplicate event id '{id_value}'",
                )
            else:
                seen_ids.add(id_value)

    title = event.get("title")
    if title is not None:
        if not isinstance(title, str) or not title.strip():
            _append_error(
                errors,
                source_file,
                index,
                event_id,
                f"events[{index}].title",
                "EVENT_INVALID_VALUE",
                "'title' must be a non-empty string",
            )
        else:
            normalized["title"] = title.strip()

    description = event.get("description")
    if description is not None:
        if not isinstance(description, str):
            _append_error(
                errors,
                source_file,
                index,
                event_id,
                f"events[{index}].description",
                "EVENT_INVALID_VALUE",
                "'description' must be a string",
            )
        else:
            normalized["description"] = description

    options = event.get("options")
    normalized_options: list[dict[str, Any]] = []
    if not isinstance(options, list):
        _append_error(
            errors,
            source_file,
            index,
            event_id,
            f"events[{index}].options",
            "EVENT_INVALID_OPTION",
            "'options' must be an array",
        )
    elif len(options) == 0:
        _append_error(
            errors,
            source_file,
            index,
            event_id,
            f"events[{index}].options",
            "EVENT_INVALID_OPTION",
            "'options' must contain at least one item",
        )
    elif len(options) > 4:
        _append_error(
            errors,
            source_file,
            index,
            event_id,
            f"events[{index}].options",
            "EVENT_INVALID_OPTION",
            "'options' cannot contain more than 4 items",
        )
    else:
        for opt_idx, opt in enumerate(options):
            normalized_opt = _validate_option(
                opt,
                opt_idx,
                f"events[{index}].options[{opt_idx}]",
                errors,
                source_file,
                index,
                event_id,
            )
            if normalized_opt is not None:
                normalized_options.append(normalized_opt)
    normalized["options"] = normalized_options

    tags = event.get("tags", [])
    if isinstance(tags, list):
        for tag in tags:
            if tag not in VALID_TAGS:
                _append_error(
                    errors,
                    source_file,
                    index,
                    event_id,
                    f"events[{index}].tags",
                    "EVENT_INVALID_VALUE",
                    f"tag '{tag}' must be one of {sorted(VALID_TAGS)}",
                )
        normalized["tags"] = tags

    art_path = event.get("art_path")
    if art_path is not None:
        normalized["art_path"] = art_path

    requires_relic = event.get("requires_relic")
    if requires_relic is not None:
        normalized["requires_relic"] = requires_relic

    excludes_relics = event.get("excludes_relics")
    if excludes_relics is not None:
        normalized["excludes_relics"] = excludes_relics

    if any(e.item_index == index for e in errors):
        return None

    return normalized


def _write_report(
    report_path: Path,
    source_path: Path,
    total_events: int,
    valid_events: int,
    errors: list[ValidationError],
    root: Path,
) -> None:
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "source": _to_repo_relative(source_path, root),
        "summary": {
            "total_events": total_events,
            "valid_events": valid_events,
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
        description="Import and validate event content data."
    )
    parser.add_argument(
        "--input",
        required=True,
        help="input JSON file path (repo-relative or absolute)",
    )
    parser.add_argument(
        "--report",
        default="runtime/modules/content_pipeline/reports/event_import_report.json",
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
        print(f"[event-import] failed: missing input file: {input_path}")
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
        print(f"[event-import] failed: invalid JSON: {exc}")
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
        print("[event-import] failed: top-level JSON must be an object")
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

    events_raw = payload.get("events")
    if not isinstance(events_raw, list):
        _append_error(
            errors,
            _to_repo_relative(input_path, root),
            -1,
            "",
            "events",
            "invalid_type",
            "top-level 'events' must be an array",
        )
        _write_report(report_path, input_path, 0, 0, errors, root)
        print("[event-import] failed: 'events' must be an array")
        return 1

    source_file = _to_repo_relative(input_path, root)
    seen_ids: set[str] = set()
    normalized_events: list[dict[str, Any]] = []

    for index, raw_event in enumerate(events_raw):
        normalized = _validate_event(raw_event, index, source_file, seen_ids, errors)
        if normalized is not None:
            normalized_events.append(normalized)

    if errors:
        _write_report(
            report_path=report_path,
            source_path=input_path,
            total_events=len(events_raw),
            valid_events=len(normalized_events),
            errors=errors,
            root=root,
        )
        print("[event-import] failed with validation errors:")
        for error in errors:
            print(
                "  - {source}:{field} [{code}] {message}".format(
                    source=error.source_file,
                    field=error.field,
                    code=error.code,
                    message=error.message,
                )
            )
        print(f"[event-import] report: {_to_repo_relative(report_path, root)}")
        return 1

    _write_report(
        report_path=report_path,
        source_path=input_path,
        total_events=len(normalized_events),
        valid_events=len(normalized_events),
        errors=errors,
        root=root,
    )

    print("[event-import] ok")
    print(f"  source: {_to_repo_relative(input_path, root)}")
    print(f"  events: {len(normalized_events)}")
    print(f"  report: {_to_repo_relative(report_path, root)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
