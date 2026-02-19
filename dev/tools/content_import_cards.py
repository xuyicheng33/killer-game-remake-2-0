#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

TYPE_TO_RUNTIME = {
    "attack": 0,
    "skill": 1,
    "power": 2,
    "status": 1,
    "curse": 1,
}

RUNTIME_TYPE_COMPAT = {
    "status": "skill",
    "curse": "skill",
}

TARGET_TO_RUNTIME = {
    "self": 0,
    "enemy": 1,
    "all_enemies": 2,
    "none": 0,
}

RARITY_VALUES = {"common", "uncommon", "rare"}
STATUS_VALUES = {"strength", "dexterity", "vulnerable", "weak", "poison"}
EFFECT_OPS = {"damage", "block", "apply_status", "draw", "gain_energy", "energy"}
REQUIRED_FIELDS = ["id", "name", "type", "rarity", "cost", "target", "text", "effects"]


@dataclass
class ValidationError:
    source_file: str
    card_index: int
    card_id: str
    field: str
    code: str
    message: str

    def to_dict(self) -> dict[str, Any]:
        return {
            "source_file": self.source_file,
            "card_index": self.card_index,
            "card_id": self.card_id,
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


def _to_res_path(path: Path, root: Path) -> str:
    rel = path.resolve().relative_to(root.resolve()).as_posix()
    return "res://" + rel


def _write_text(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def _json_string(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def _append_error(
    errors: list[ValidationError],
    source_file: str,
    card_index: int,
    card_id: str,
    field: str,
    code: str,
    message: str,
) -> None:
    errors.append(
        ValidationError(
            source_file=source_file,
            card_index=card_index,
            card_id=card_id,
            field=field,
            code=code,
            message=message,
        )
    )


def _validate_card(
    card: Any,
    index: int,
    source_file: str,
    root: Path,
    seen_ids: set[str],
    errors: list[ValidationError],
) -> dict[str, Any] | None:
    if not isinstance(card, dict):
        _append_error(errors, source_file, index, "", f"cards[{index}]", "invalid_type", "card must be an object")
        return None

    card_id = str(card.get("id", ""))
    for field in REQUIRED_FIELDS:
        if field not in card:
            _append_error(
                errors,
                source_file,
                index,
                card_id,
                f"cards[{index}].{field}",
                "missing_field",
                f"required field '{field}' is missing",
            )

    if errors and any(err.card_index == index and err.code == "missing_field" for err in errors):
        return None

    normalized: dict[str, Any] = {}

    for field in ["id", "name", "type", "rarity", "target", "text"]:
        value = card.get(field)
        if not isinstance(value, str) or value.strip() == "":
            _append_error(
                errors,
                source_file,
                index,
                card_id,
                f"cards[{index}].{field}",
                "invalid_type",
                f"'{field}' must be a non-empty string",
            )
        else:
            normalized[field] = value.strip()

    cost_value = card.get("cost")
    if not isinstance(cost_value, int):
        _append_error(
            errors,
            source_file,
            index,
            card_id,
            f"cards[{index}].cost",
            "invalid_type",
            "'cost' must be an integer",
        )
    else:
        if cost_value < -1 or cost_value > 10:
            _append_error(
                errors,
                source_file,
                index,
                card_id,
                f"cards[{index}].cost",
                "out_of_range",
                "'cost' must be between -1 and 10",
            )
        normalized["cost"] = cost_value

    rarity = normalized.get("rarity")
    if isinstance(rarity, str) and rarity not in RARITY_VALUES:
        _append_error(
            errors,
            source_file,
            index,
            card_id,
            f"cards[{index}].rarity",
            "invalid_enum",
            f"unsupported rarity '{rarity}'",
        )

    card_type = normalized.get("type")
    if isinstance(card_type, str) and card_type not in TYPE_TO_RUNTIME:
        _append_error(
            errors,
            source_file,
            index,
            card_id,
            f"cards[{index}].type",
            "invalid_enum",
            f"unsupported type '{card_type}'",
        )

    target = normalized.get("target")
    if isinstance(target, str) and target not in TARGET_TO_RUNTIME:
        _append_error(
            errors,
            source_file,
            index,
            card_id,
            f"cards[{index}].target",
            "invalid_enum",
            f"unsupported target '{target}'",
        )

    effects = card.get("effects")
    normalized_effects: list[dict[str, Any]] = []
    if not isinstance(effects, list):
        _append_error(
            errors,
            source_file,
            index,
            card_id,
            f"cards[{index}].effects",
            "invalid_type",
            "'effects' must be an array",
        )
    elif len(effects) == 0:
        _append_error(
            errors,
            source_file,
            index,
            card_id,
            f"cards[{index}].effects",
            "invalid_value",
            "'effects' must contain at least one item",
        )
    else:
        for effect_index, effect in enumerate(effects):
            field_prefix = f"cards[{index}].effects[{effect_index}]"
            if not isinstance(effect, dict):
                _append_error(
                    errors,
                    source_file,
                    index,
                    card_id,
                    field_prefix,
                    "invalid_type",
                    "effect must be an object",
                )
                continue
            op = effect.get("op")
            if not isinstance(op, str) or op.strip() == "":
                _append_error(
                    errors,
                    source_file,
                    index,
                    card_id,
                    f"{field_prefix}.op",
                    "missing_field",
                    "effect 'op' must be a non-empty string",
                )
                continue
            op = op.strip()
            if op not in EFFECT_OPS:
                _append_error(
                    errors,
                    source_file,
                    index,
                    card_id,
                    f"{field_prefix}.op",
                    "invalid_enum",
                    f"unsupported effect op '{op}'",
                )
                continue

            if op == "energy":
                op = "gain_energy"

            normalized_effect: dict[str, Any] = {"op": op}
            if op in {"damage", "block"}:
                amount = effect.get("amount")
                if not isinstance(amount, int):
                    _append_error(
                        errors,
                        source_file,
                        index,
                        card_id,
                        f"{field_prefix}.amount",
                        "invalid_type",
                        "'amount' must be an integer",
                    )
                    continue
                if amount < 0:
                    _append_error(
                        errors,
                        source_file,
                        index,
                        card_id,
                        f"{field_prefix}.amount",
                        "out_of_range",
                        "'amount' must be >= 0",
                    )
                    continue
                normalized_effect["amount"] = amount
            elif op == "apply_status":
                status_id = effect.get("status_id")
                stacks = effect.get("stacks")
                if not isinstance(status_id, str) or status_id not in STATUS_VALUES:
                    _append_error(
                        errors,
                        source_file,
                        index,
                        card_id,
                        f"{field_prefix}.status_id",
                        "invalid_enum",
                        f"'status_id' must be one of {sorted(STATUS_VALUES)}",
                    )
                    continue
                if not isinstance(stacks, int):
                    _append_error(
                        errors,
                        source_file,
                        index,
                        card_id,
                        f"{field_prefix}.stacks",
                        "invalid_type",
                        "'stacks' must be an integer",
                    )
                    continue
                if stacks == 0:
                    _append_error(
                        errors,
                        source_file,
                        index,
                        card_id,
                        f"{field_prefix}.stacks",
                        "invalid_value",
                        "'stacks' must not be 0",
                    )
                    continue
                normalized_effect["status_id"] = status_id
                normalized_effect["stacks"] = stacks
            elif op in {"draw", "gain_energy"}:
                amount = effect.get("amount")
                if not isinstance(amount, int):
                    _append_error(
                        errors,
                        source_file,
                        index,
                        card_id,
                        f"{field_prefix}.amount",
                        "invalid_type",
                        "'amount' must be an integer",
                    )
                    continue
                if amount <= 0:
                    _append_error(
                        errors,
                        source_file,
                        index,
                        card_id,
                        f"{field_prefix}.amount",
                        "out_of_range",
                        "'amount' must be > 0",
                    )
                    continue
                normalized_effect["amount"] = amount

            normalized_effects.append(normalized_effect)

    normalized["effects"] = normalized_effects

    tags = card.get("tags", [])
    normalized_tags: list[str] = []
    if tags is None:
        tags = []
    if not isinstance(tags, list):
        _append_error(
            errors,
            source_file,
            index,
            card_id,
            f"cards[{index}].tags",
            "invalid_type",
            "'tags' must be an array when provided",
        )
    else:
        for tag_index, tag in enumerate(tags):
            if not isinstance(tag, str) or tag.strip() == "":
                _append_error(
                    errors,
                    source_file,
                    index,
                    card_id,
                    f"cards[{index}].tags[{tag_index}]",
                    "invalid_type",
                    "tag must be a non-empty string",
                )
                continue
            normalized_tags.append(tag.strip())
    normalized["tags"] = normalized_tags

    upgrade_to = card.get("upgrade_to", "")
    if upgrade_to is None:
        upgrade_to = ""
    if not isinstance(upgrade_to, str):
        _append_error(
            errors,
            source_file,
            index,
            card_id,
            f"cards[{index}].upgrade_to",
            "invalid_type",
            "'upgrade_to' must be a string when provided",
        )
    normalized["upgrade_to"] = upgrade_to.strip() if isinstance(upgrade_to, str) else ""

    starter_copies = card.get("starter_copies", 0)
    if not isinstance(starter_copies, int):
        _append_error(
            errors,
            source_file,
            index,
            card_id,
            f"cards[{index}].starter_copies",
            "invalid_type",
            "'starter_copies' must be an integer when provided",
        )
        starter_copies = 0
    if starter_copies < 0:
        _append_error(
            errors,
            source_file,
            index,
            card_id,
            f"cards[{index}].starter_copies",
            "out_of_range",
            "'starter_copies' must be >= 0",
        )
        starter_copies = 0
    normalized["starter_copies"] = starter_copies

    for field in ["icon", "sound"]:
        value = card.get(field, "")
        if value is None:
            value = ""
        if not isinstance(value, str):
            _append_error(
                errors,
                source_file,
                index,
                card_id,
                f"cards[{index}].{field}",
                "invalid_type",
                f"'{field}' must be a string when provided",
            )
            value = ""
        value = value.strip()
        if value != "":
            if not value.startswith("res://"):
                _append_error(
                    errors,
                    source_file,
                    index,
                    card_id,
                    f"cards[{index}].{field}",
                    "invalid_value",
                    f"'{field}' must start with 'res://'",
                )
            else:
                disk_path = root / value.replace("res://", "", 1)
                if not disk_path.exists():
                    _append_error(
                        errors,
                        source_file,
                        index,
                        card_id,
                        f"cards[{index}].{field}",
                        "not_found",
                        f"resource not found: {value}",
                    )
        normalized[field] = value

    if isinstance(normalized.get("id"), str) and normalized["id"]:
        if normalized["id"] in seen_ids:
            _append_error(
                errors,
                source_file,
                index,
                normalized["id"],
                f"cards[{index}].id",
                "duplicate_id",
                f"duplicate card id '{normalized['id']}'",
            )
        else:
            seen_ids.add(normalized["id"])

    runtime_type = normalized.get("type", "")
    if isinstance(runtime_type, str):
        normalized["runtime_type"] = RUNTIME_TYPE_COMPAT.get(runtime_type, runtime_type)

    # Skip cards that have validation errors in this item.
    if any(err.card_index == index for err in errors):
        return None

    return normalized


def _generate_card_script(card: dict[str, Any]) -> str:
    is_x_cost = card.get("cost") == -1 or "x_cost" in card.get("tags", [])
    lines: list[str] = [
        "extends Card",
        "",
        "",
        "# Generated by dev/tools/content_import_cards.py",
        "func apply_effects(_targets: Array[Node], _battle_context: RefCounted = null) -> void:",
    ]

    for idx, effect in enumerate(card["effects"]):
        op = effect["op"]
        suffix = idx + 1
        if op == "damage":
            amount = effect["amount"]
            amount_expr = f"{amount} * last_x_value" if is_x_cost else str(amount)
            lines.extend(
                [
                    f"\tvar damage_effect_{suffix} := DamageEffect.new()",
                    f"\tdamage_effect_{suffix}.amount = {amount_expr}",
                    f"\tdamage_effect_{suffix}.sound = sound",
                    f"\tdamage_effect_{suffix}.execute(_targets, _battle_context)",
                ]
            )
        elif op == "block":
            amount = effect["amount"]
            amount_expr = f"{amount} * last_x_value" if is_x_cost else str(amount)
            lines.extend(
                [
                    f"\tvar block_effect_{suffix} := BlockEffect.new()",
                    f"\tblock_effect_{suffix}.amount = {amount_expr}",
                    f"\tblock_effect_{suffix}.sound = sound",
                    f"\tblock_effect_{suffix}.execute(_targets, _battle_context)",
                ]
            )
        elif op == "apply_status":
            lines.extend(
                [
                    f"\tvar status_effect_{suffix} := ApplyStatusEffect.new()",
                    f"\tstatus_effect_{suffix}.status_id = {_json_string(effect['status_id'])}",
                    f"\tstatus_effect_{suffix}.stacks = {effect['stacks']}",
                    f"\tstatus_effect_{suffix}.sound = sound",
                    f"\tstatus_effect_{suffix}.execute(_targets, _battle_context)",
                ]
            )
        elif op == "draw":
            lines.extend(
                [
                    f"\tvar draw_effect_{suffix} := preload(\"res://content/effects/draw_card_effect.gd\").new()",
                    f"\tdraw_effect_{suffix}.amount = {effect['amount']}",
                    f"\tdraw_effect_{suffix}.sound = sound",
                    f"\tdraw_effect_{suffix}.execute(_targets, _battle_context)",
                ]
            )
        elif op == "gain_energy":
            lines.extend(
                [
                    f"\tvar energy_effect_{suffix} := preload(\"res://content/effects/gain_energy_effect.gd\").new()",
                    f"\tenergy_effect_{suffix}.amount = {effect['amount']}",
                    f"\tenergy_effect_{suffix}.sound = sound",
                    f"\tenergy_effect_{suffix}.execute(_targets, _battle_context)",
                ]
            )

    return "\n".join(lines) + "\n"


def _build_tooltip(card: dict[str, Any]) -> str:
    name = card["name"]
    text = card["text"]
    return f"[center]{name}\\n{text}[/center]"


def _generate_card_tres(card: dict[str, Any], script_res_path: str) -> str:
    ext_lines: list[str] = [
        f"[ext_resource type=\"Script\" path=\"{script_res_path}\" id=\"1_card_script\"]"
    ]
    icon_id = ""
    sound_id = ""

    next_id = 2
    if card.get("icon"):
        icon_id = f"{next_id}_icon"
        ext_lines.append(
            f"[ext_resource type=\"Texture2D\" path=\"{card['icon']}\" id=\"{icon_id}\"]"
        )
        next_id += 1
    if card.get("sound"):
        sound_id = f"{next_id}_sound"
        ext_lines.append(
            f"[ext_resource type=\"AudioStream\" path=\"{card['sound']}\" id=\"{sound_id}\"]"
        )

    load_steps = len(ext_lines) + 1
    lines: list[str] = [
        f"[gd_resource type=\"Resource\" load_steps={load_steps} format=3]",
        "",
    ]
    lines.extend(ext_lines)
    lines.append("")
    lines.append("[resource]")
    lines.append("script = ExtResource(\"1_card_script\")")
    lines.append(f"id = {_json_string(card['id'])}")
    lines.append(f"type = {TYPE_TO_RUNTIME[card['runtime_type']]}")
    lines.append(f"target = {TARGET_TO_RUNTIME[card['target']]}")
    lines.append(f"cost = {card['cost']}")

    tags = set(card.get("tags", []))
    keyword_x_cost = card["cost"] == -1 or ("x_cost" in tags)
    lines.append(f"keyword_exhaust = {'true' if 'exhaust' in tags else 'false'}")
    lines.append(f"keyword_retain = {'true' if 'retain' in tags else 'false'}")
    lines.append(f"keyword_void = {'true' if 'void' in tags else 'false'}")
    lines.append(f"keyword_ethereal = {'true' if 'ethereal' in tags else 'false'}")
    lines.append(f"keyword_x_cost = {'true' if keyword_x_cost else 'false'}")
    lines.append(f"upgrade_to = {_json_string(card.get('upgrade_to', ''))}")
    lines.append(f"tooltip_text = {_json_string(_build_tooltip(card))}")

    if icon_id:
        lines.append(f"icon = ExtResource(\"{icon_id}\")")
    if sound_id:
        lines.append(f"sound = ExtResource(\"{sound_id}\")")

    return "\n".join(lines) + "\n"


def _generate_starting_deck_tres(deck_cards: list[str]) -> str:
    unique_paths: list[str] = []
    for path in deck_cards:
        if path not in unique_paths:
            unique_paths.append(path)

    id_map: dict[str, str] = {}
    ext_lines = [
        "[ext_resource type=\"Script\" path=\"res://content/custom_resources/card_pile.gd\" id=\"1_card_pile_script\"]"
    ]
    for idx, card_path in enumerate(unique_paths):
        ext_id = f"2_card_{idx:03d}"
        id_map[card_path] = ext_id
        ext_lines.append(
            f"[ext_resource type=\"Resource\" path=\"{card_path}\" id=\"{ext_id}\"]"
        )

    refs = ", ".join(f"ExtResource(\"{id_map[path]}\")" for path in deck_cards)
    load_steps = len(ext_lines) + 1

    lines: list[str] = [
        f"[gd_resource type=\"Resource\" script_class=\"CardPile\" load_steps={load_steps} format=3 uid=\"uid://dyyfi3rcfxyug\"]",
        "",
    ]
    lines.extend(ext_lines)
    lines.append("")
    lines.append("[resource]")
    lines.append("script = ExtResource(\"1_card_pile_script\")")
    lines.append(
        "cards = Array[Resource(\"res://content/custom_resources/card.gd\")]([%s])" % refs
    )
    return "\n".join(lines) + "\n"


def _write_report(
    report_path: Path,
    source_path: Path,
    cards_total: int,
    cards_valid: int,
    errors: list[ValidationError],
    outputs: list[str],
    root: Path,
) -> None:
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "source": _to_repo_relative(source_path, root),
        "summary": {
            "total_cards": cards_total,
            "valid_cards": cards_valid,
            "error_count": len(errors),
            "output_count": len(outputs),
        },
        "outputs": outputs,
        "errors": [error.to_dict() for error in errors],
    }
    report_path.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def main() -> int:
    root = _root_dir()
    parser = argparse.ArgumentParser(description="Import and validate card content data.")
    parser.add_argument(
        "--input",
        default="runtime/modules/content_pipeline/sources/cards/warrior_cards.json",
        help="input JSON file path (repo-relative or absolute)",
    )
    parser.add_argument(
        "--output-dir",
        default="content/characters/warrior/cards/generated",
        help="generated card output directory (repo-relative or absolute)",
    )
    parser.add_argument(
        "--deck-output",
        default="content/characters/warrior/warrior_starting_deck.tres",
        help="generated warrior starting deck resource",
    )
    parser.add_argument(
        "--report",
        default="runtime/modules/content_pipeline/reports/card_import_report.json",
        help="validation report output path",
    )

    args = parser.parse_args()

    input_path = Path(args.input)
    if not input_path.is_absolute():
        input_path = root / input_path

    output_dir = Path(args.output_dir)
    if not output_dir.is_absolute():
        output_dir = root / output_dir

    deck_output = Path(args.deck_output)
    if not deck_output.is_absolute():
        deck_output = root / deck_output

    report_path = Path(args.report)
    if not report_path.is_absolute():
        report_path = root / report_path

    errors: list[ValidationError] = []
    outputs: list[str] = []

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
        _write_report(report_path, input_path, 0, 0, errors, outputs, root)
        print(f"[content-import] failed: missing input file: {input_path}")
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
        _write_report(report_path, input_path, 0, 0, errors, outputs, root)
        print(f"[content-import] failed: invalid JSON: {exc}")
        return 1

    cards_raw: Any = payload.get("cards") if isinstance(payload, dict) else None
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
    elif not isinstance(cards_raw, list):
        _append_error(
            errors,
            _to_repo_relative(input_path, root),
            -1,
            "",
            "cards",
            "invalid_type",
            "top-level 'cards' must be an array",
        )

    normalized_cards: list[dict[str, Any]] = []
    if isinstance(cards_raw, list):
        seen_ids: set[str] = set()
        source_file = _to_repo_relative(input_path, root)
        for index, raw_card in enumerate(cards_raw):
            normalized = _validate_card(raw_card, index, source_file, root, seen_ids, errors)
            if normalized is not None:
                normalized_cards.append(normalized)

    if errors:
        _write_report(
            report_path=report_path,
            source_path=input_path,
            cards_total=len(cards_raw) if isinstance(cards_raw, list) else 0,
            cards_valid=len(normalized_cards),
            errors=errors,
            outputs=outputs,
            root=root,
        )
        print("[content-import] failed with validation errors:")
        for error in errors:
            print(
                "  - {source}:{field} [{code}] {message}".format(
                    source=error.source_file,
                    field=error.field,
                    code=error.code,
                    message=error.message,
                )
            )
        print(f"[content-import] report: {_to_repo_relative(report_path, root)}")
        return 1

    output_dir.mkdir(parents=True, exist_ok=True)
    for stale in sorted(output_dir.glob("*.gd")):
        stale.unlink()
    for stale in sorted(output_dir.glob("*.tres")):
        stale.unlink()

    deck_cards: list[str] = []
    for card in normalized_cards:
        script_path = output_dir / f"{card['id']}.gd"
        resource_path = output_dir / f"{card['id']}.tres"
        script_res_path = _to_res_path(script_path, root)
        resource_res_path = _to_res_path(resource_path, root)

        _write_text(script_path, _generate_card_script(card))
        _write_text(resource_path, _generate_card_tres(card, script_res_path))
        outputs.append(_to_repo_relative(script_path, root))
        outputs.append(_to_repo_relative(resource_path, root))

        for _ in range(card["starter_copies"]):
            deck_cards.append(resource_res_path)

    if not deck_cards:
        _append_error(
            errors,
            _to_repo_relative(input_path, root),
            -1,
            "",
            "cards",
            "invalid_value",
            "at least one card must have starter_copies > 0",
        )
        _write_report(report_path, input_path, len(normalized_cards), len(normalized_cards), errors, outputs, root)
        print("[content-import] failed: no starter deck cards generated")
        return 1

    _write_text(deck_output, _generate_starting_deck_tres(deck_cards))
    outputs.append(_to_repo_relative(deck_output, root))

    _write_report(
        report_path=report_path,
        source_path=input_path,
        cards_total=len(normalized_cards),
        cards_valid=len(normalized_cards),
        errors=errors,
        outputs=outputs,
        root=root,
    )

    print("[content-import] ok")
    print(f"  source: {_to_repo_relative(input_path, root)}")
    print(f"  cards: {len(normalized_cards)}")
    print(f"  outputs: {len(outputs)}")
    print(f"  report: {_to_repo_relative(report_path, root)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
