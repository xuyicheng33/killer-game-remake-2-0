#!/usr/bin/env python3
"""
Generate battle icons with deterministic brush/ink style.

Usage:
  python3 dev/tools/generate_battle_icons.py --output-dir content/art/ui/icons --size 64
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import random
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter


ICON_NAMES = [
    "intent_attack.png",
    "intent_block.png",
    "intent_mega_block.png",
    "status_block.png",
    "status_health.png",
]


def sha256_file(path: Path) -> str | None:
    if not path.exists():
        return None
    digest = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            digest.update(chunk)
    return digest.hexdigest()


def _jittered(points: list[tuple[float, float]], rng: random.Random, amount: float) -> list[tuple[float, float]]:
    out: list[tuple[float, float]] = []
    for x, y in points:
        out.append((x + rng.uniform(-amount, amount), y + rng.uniform(-amount, amount)))
    return out


def _brush_line(
    draw: ImageDraw.ImageDraw,
    rng: random.Random,
    points: list[tuple[float, float]],
    width: int,
    color: tuple[int, int, int, int],
    jitter: float = 1.8,
) -> None:
    points = _jittered(points, rng, jitter)
    for i in range(len(points) - 1):
        x1, y1 = points[i]
        x2, y2 = points[i + 1]
        w = max(1, int(width * (0.78 + 0.46 * rng.random())))
        draw.line([(x1, y1), (x2, y2)], fill=color, width=w)
        r = max(1, int(w * 0.34))
        draw.ellipse((x1 - r, y1 - r, x1 + r, y1 + r), fill=color)
        draw.ellipse((x2 - r, y2 - r, x2 + r, y2 + r), fill=color)


def _ink_splatter(
    draw: ImageDraw.ImageDraw,
    rng: random.Random,
    center: tuple[float, float],
    radius: float,
    count: int,
    color: tuple[int, int, int, int],
) -> None:
    cx, cy = center
    for _ in range(count):
        a = rng.uniform(0.0, math.tau)
        r = rng.uniform(radius * 0.2, radius)
        x = cx + math.cos(a) * r
        y = cy + math.sin(a) * r
        dot = rng.uniform(1.5, 5.0)
        draw.ellipse((x - dot, y - dot, x + dot, y + dot), fill=color)


def _new_canvas(big_size: int) -> tuple[Image.Image, ImageDraw.ImageDraw]:
    image = Image.new("RGBA", (big_size, big_size), (0, 0, 0, 0))
    return image, ImageDraw.Draw(image, "RGBA")


def _downsample(image: Image.Image, size: int) -> Image.Image:
    out = image.filter(ImageFilter.GaussianBlur(0.25))
    return out.resize((size, size), Image.Resampling.LANCZOS)


def render_intent_attack(size: int, seed: int) -> Image.Image:
    big = size * 4
    rng = random.Random(seed + 11)
    image, draw = _new_canvas(big)

    dark = (20, 18, 18, 220)
    red = (220, 50, 40, 240)
    white = (245, 235, 220, 210)

    _brush_line(draw, rng, [(40, 192), (116, 96), (208, 36)], 34, dark, 2.6)
    _brush_line(draw, rng, [(54, 210), (128, 124), (218, 60)], 24, red, 2.4)
    _brush_line(draw, rng, [(72, 180), (154, 92), (222, 42)], 12, white, 1.6)
    _brush_line(draw, rng, [(96, 218), (176, 130), (232, 84)], 8, (255, 255, 255, 180), 1.0)

    _ink_splatter(draw, rng, (70, 185), 44, 18, (10, 10, 10, 140))
    _ink_splatter(draw, rng, (180, 82), 52, 26, (80, 8, 8, 120))

    return _downsample(image, size)


def _shield_polygon(big: int, inset: float = 0.0) -> list[tuple[float, float]]:
    c = big / 2.0
    top = big * (0.16 + inset)
    left = big * (0.26 + inset * 0.7)
    right = big * (0.74 - inset * 0.7)
    mid = big * (0.49 + inset * 0.2)
    bottom = big * (0.87 - inset)
    return [
        (c, top),
        (right, big * (0.32 + inset * 0.4)),
        (big * (0.68 - inset * 0.3), big * (0.69 - inset * 0.2)),
        (c, bottom),
        (big * (0.32 + inset * 0.3), big * (0.69 - inset * 0.2)),
        (left, big * (0.32 + inset * 0.4)),
    ]


def render_intent_block(size: int, seed: int) -> Image.Image:
    big = size * 4
    rng = random.Random(seed + 29)
    image, draw = _new_canvas(big)

    outer = _shield_polygon(big, 0.0)
    inner = _shield_polygon(big, 0.08)
    draw.polygon(outer, fill=(20, 26, 34, 235))
    draw.polygon(inner, fill=(64, 122, 158, 232))
    draw.line(outer + [outer[0]], fill=(8, 8, 8, 220), width=10)
    draw.line(inner + [inner[0]], fill=(185, 220, 228, 180), width=7)

    _brush_line(draw, rng, [(70, 122), (126, 90), (184, 122)], 14, (205, 242, 255, 150), 1.8)
    _brush_line(draw, rng, [(88, 162), (128, 138), (170, 162)], 10, (230, 250, 255, 120), 1.5)
    _ink_splatter(draw, rng, (62, 66), 36, 14, (0, 0, 0, 95))

    return _downsample(image, size)


def render_intent_mega_block(size: int, seed: int) -> Image.Image:
    big = size * 4
    rng = random.Random(seed + 47)
    image, draw = _new_canvas(big)

    outer = _shield_polygon(big, -0.03)
    mid = _shield_polygon(big, 0.02)
    inner = _shield_polygon(big, 0.11)

    draw.polygon(outer, fill=(18, 18, 20, 240))
    draw.polygon(mid, fill=(68, 78, 104, 236))
    draw.polygon(inner, fill=(110, 146, 172, 236))

    draw.line(outer + [outer[0]], fill=(12, 12, 12, 230), width=12)
    draw.line(mid + [mid[0]], fill=(250, 206, 102, 210), width=8)
    draw.line(inner + [inner[0]], fill=(210, 232, 242, 180), width=5)

    draw.polygon([(128, 92), (164, 126), (128, 164), (92, 126)], fill=(252, 188, 90, 220))
    _brush_line(draw, rng, [(128, 52), (128, 82)], 10, (255, 230, 170, 190), 0.7)
    _brush_line(draw, rng, [(54, 132), (84, 128)], 8, (220, 188, 124, 160), 1.0)
    _brush_line(draw, rng, [(172, 128), (202, 132)], 8, (220, 188, 124, 160), 1.0)
    _ink_splatter(draw, rng, (194, 62), 34, 10, (10, 10, 10, 100))

    return _downsample(image, size)


def render_status_block(size: int, seed: int) -> Image.Image:
    big = size * 4
    rng = random.Random(seed + 71)
    image, draw = _new_canvas(big)

    base = _shield_polygon(big, 0.14)
    draw.polygon(base, fill=(54, 120, 150, 236))
    draw.line(base + [base[0]], fill=(14, 18, 20, 220), width=8)

    draw.rounded_rectangle((88, 110, 168, 148), radius=10, fill=(216, 238, 242, 205))
    _brush_line(draw, rng, [(84, 162), (128, 188), (172, 162)], 10, (188, 222, 232, 150), 1.2)

    return _downsample(image, size)


def render_status_health(size: int, seed: int) -> Image.Image:
    big = size * 4
    rng = random.Random(seed + 89)
    image, draw = _new_canvas(big)

    # Heart silhouette from two circles + lower diamond/triangle.
    draw.ellipse((58, 58, 136, 138), fill=(18, 14, 14, 240))
    draw.ellipse((120, 58, 198, 138), fill=(18, 14, 14, 240))
    draw.polygon([(50, 108), (206, 108), (128, 224)], fill=(18, 14, 14, 240))

    draw.ellipse((66, 66, 132, 132), fill=(176, 34, 42, 232))
    draw.ellipse((124, 66, 190, 132), fill=(176, 34, 42, 232))
    draw.polygon([(58, 114), (198, 114), (128, 212)], fill=(176, 34, 42, 232))

    _brush_line(draw, rng, [(94, 86), (124, 72), (154, 86)], 9, (245, 182, 186, 170), 1.0)
    _brush_line(draw, rng, [(88, 134), (128, 180), (168, 134)], 6, (230, 72, 78, 140), 1.3)
    _ink_splatter(draw, rng, (46, 52), 32, 8, (4, 4, 4, 90))

    return _downsample(image, size)


def build_icons(output_dir: Path, size: int, seed: int) -> dict[str, dict[str, str | None]]:
    output_dir.mkdir(parents=True, exist_ok=True)

    renderers = {
        "intent_attack.png": render_intent_attack,
        "intent_block.png": render_intent_block,
        "intent_mega_block.png": render_intent_mega_block,
        "status_block.png": render_status_block,
        "status_health.png": render_status_health,
    }

    old_hashes: dict[str, str | None] = {}
    for name in ICON_NAMES:
        old_hashes[name] = sha256_file(output_dir / name)

    for name, renderer in renderers.items():
        image = renderer(size, seed)
        image.save(output_dir / name, "PNG")

    new_hashes: dict[str, str | None] = {}
    for name in ICON_NAMES:
        new_hashes[name] = sha256_file(output_dir / name)

    return {"old_hashes": old_hashes, "new_hashes": new_hashes}


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate battle icons in a deterministic style.")
    parser.add_argument("--output-dir", default="content/art/ui/icons", help="Directory for icon PNG files.")
    parser.add_argument("--size", type=int, default=64, help="Output size (square).")
    parser.add_argument("--seed", type=int, default=20260216, help="Deterministic seed.")
    args = parser.parse_args()

    output_dir = Path(args.output_dir)
    report = build_icons(output_dir, args.size, args.seed)

    print(f"[icons] output_dir={output_dir} size={args.size} seed={args.seed}")
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
