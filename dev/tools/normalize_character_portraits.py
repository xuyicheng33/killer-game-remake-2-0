#!/usr/bin/env python3
"""
Normalize portrait canvases for battle display.

Steps:
1. Trim transparent border
2. Scale into safe area
3. Paste into unified RGBA square canvas
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image

PORTRAIT_NAMES = ["霜北刀.png", "离恨烟.png", "埋骨钱.png"]


def _trim_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    alpha = image.getchannel("A")
    bbox = alpha.getbbox()
    if bbox is None:
        return (0, 0, image.width, image.height)
    return bbox


def process_image(
    src_path: Path,
    dst_path: Path,
    canvas_size: int,
    margin_ratio: float,
    allow_upscale: bool,
) -> dict[str, object]:
    image = Image.open(src_path).convert("RGBA")
    src_w, src_h = image.size
    bbox = _trim_bbox(image)
    cropped = image.crop(bbox)
    crop_w, crop_h = cropped.size

    safe_w = max(1, int(round(canvas_size * (1.0 - margin_ratio * 2.0))))
    safe_h = max(1, int(round(canvas_size * (1.0 - margin_ratio * 2.0))))
    scale = min(safe_w / crop_w, safe_h / crop_h)
    if not allow_upscale:
        scale = min(scale, 1.0)
    out_w = max(1, int(round(crop_w * scale)))
    out_h = max(1, int(round(crop_h * scale)))

    resized = cropped.resize((out_w, out_h), Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    offset_x = (canvas_size - out_w) // 2
    offset_y = (canvas_size - out_h) // 2
    canvas.alpha_composite(resized, (offset_x, offset_y))
    dst_path.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(dst_path, "PNG")

    return {
        "source": str(src_path),
        "output": str(dst_path),
        "source_size": [src_w, src_h],
        "trim_bbox": [bbox[0], bbox[1], bbox[2], bbox[3]],
        "trimmed_size": [crop_w, crop_h],
        "scale": scale,
        "output_content_size": [out_w, out_h],
        "canvas_size": [canvas_size, canvas_size],
        "safe_area": [safe_w, safe_h],
        "offset": [offset_x, offset_y],
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Normalize portrait canvases.")
    parser.add_argument("--input-dir", default="content/art/characters")
    parser.add_argument("--output-dir", default="content/art/characters/processed")
    parser.add_argument("--canvas-size", type=int, default=2048)
    parser.add_argument("--margin-ratio", type=float, default=0.10)
    parser.add_argument("--allow-upscale", action="store_true")
    args = parser.parse_args()

    input_dir = Path(args.input_dir)
    output_dir = Path(args.output_dir)

    report: dict[str, object] = {
        "input_dir": str(input_dir),
        "output_dir": str(output_dir),
        "canvas_size": args.canvas_size,
        "margin_ratio": args.margin_ratio,
        "allow_upscale": args.allow_upscale,
        "portraits": [],
    }

    portraits: list[dict[str, object]] = []
    for name in PORTRAIT_NAMES:
        src = input_dir / name
        dst = output_dir / name
        portraits.append(
            process_image(
                src_path=src,
                dst_path=dst,
                canvas_size=args.canvas_size,
                margin_ratio=args.margin_ratio,
                allow_upscale=args.allow_upscale,
            )
        )
    report["portraits"] = portraits

    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
