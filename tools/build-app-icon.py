#!/usr/bin/env python3
"""Draws the Be Irrational app icon options (1024 x 1024, no alpha, square; iOS rounds the corners).

    /usr/bin/python3 tools/build-app-icon.py            # writes the chosen icon into the asset catalog
    /usr/bin/python3 tools/build-app-icon.py --sketches # also writes every option to docs/icon-sketches/
"""
import math
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent.parent
SIZE = 1024
S = 2  # supersampling
N = SIZE * S

AMBER_TOP = (244, 196, 104)
AMBER_BOTTOM = (205, 128, 52)
INK = (52, 34, 22)
DOT_OFF = (236, 214, 176)
PAPER = (255, 252, 244)


def gradient(top, bottom):
    img = Image.new("RGB", (N, N))
    d = ImageDraw.Draw(img)
    for y in range(N):
        t = y / (N - 1)
        d.line([(0, y), (N, y)], fill=tuple(round(a + (b - a) * t) for a, b in zip(top, bottom)))
    return img


def font(size):
    for path in [
        "/System/Library/Fonts/SFNSRounded.ttf",
        "/System/Library/Fonts/Supplemental/Arial Rounded Bold.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
    ]:
        try:
            f = ImageFont.truetype(path, size)
        except OSError:
            continue
        try:
            f.set_variation_by_name("Heavy")
        except (OSError, ValueError):
            pass
        return f
    return ImageFont.load_default()


def shadow(base, shape_mask, offset=(0, 18 * S), blur=28 * S, opacity=90):
    sh = Image.new("L", (N, N), 0)
    sh.paste(shape_mask, offset)
    sh = sh.filter(ImageFilter.GaussianBlur(blur)).point(lambda v: v * opacity // 255)
    base.paste(Image.new("RGB", (N, N), (90, 45, 10)), (0, 0), sh)


def ring(draw, cx, cy, radius, dot, lit, on=INK, off=DOT_OFF, start=0):
    for i in range(12):
        a = math.radians(i * 30 - 90 + start)
        x, y = cx + radius * math.cos(a), cy + radius * math.sin(a)
        draw.ellipse([x - dot, y - dot, x + dot, y + dot], fill=on if i < lit else off)


def question(draw, cx, cy, size, fill):
    f = font(size)
    draw.text((cx, cy), "?", font=f, fill=fill, anchor="mm")


def option_ring():
    """A: the app's own progress ring of twelve dots, eight lit, a question mark inside."""
    img = gradient(AMBER_TOP, AMBER_BOTTOM)
    mask = Image.new("L", (N, N), 0)
    ImageDraw.Draw(mask).ellipse([212 * S, 212 * S, 812 * S, 812 * S], fill=255)
    shadow(img, mask)
    d = ImageDraw.Draw(img)
    d.ellipse([212 * S, 212 * S, 812 * S, 812 * S], fill=PAPER)
    ring(d, N / 2, N / 2, 226 * S, 44 * S, 8)
    question(d, N / 2, N / 2 + 6 * S, 300 * S, INK)
    return img


def option_bubble():
    """B: the 2011 thought bubble, flat: a white cloud with an amber question mark."""
    img = gradient(AMBER_TOP, AMBER_BOTTOM)
    mask = Image.new("L", (N, N), 0)
    m = ImageDraw.Draw(mask)
    for cx, cy, r in [(512, 420, 250), (330, 470, 170), (700, 470, 170), (420, 300, 160), (620, 300, 170),
                      (512, 560, 190)]:
        m.ellipse([(cx - r) * S, (cy - r) * S, (cx + r) * S, (cy + r) * S], fill=255)
    for cx, cy, r in [(330, 760, 62), (240, 870, 38)]:
        m.ellipse([(cx - r) * S, (cy - r) * S, (cx + r) * S, (cy + r) * S], fill=255)
    shadow(img, mask)
    img.paste(Image.new("RGB", (N, N), PAPER), (0, 0), mask)
    d = ImageDraw.Draw(img)
    question(d, 512 * S, 440 * S, 400 * S, (214, 132, 40))
    return img


def option_notepad():
    """C: the spiral notepad of the app, with the dot ring on the page."""
    img = gradient(AMBER_TOP, AMBER_BOTTOM)
    page = [222 * S, 190 * S, 802 * S, 850 * S]
    mask = Image.new("L", (N, N), 0)
    ImageDraw.Draw(mask).rounded_rectangle(page, radius=56 * S, fill=255)
    shadow(img, mask)
    d = ImageDraw.Draw(img)
    d.rounded_rectangle(page, radius=56 * S, fill=PAPER)
    for i in range(6):
        x = (292 + i * 88) * S
        d.rounded_rectangle([x - 14 * S, 150 * S, x + 14 * S, 240 * S], radius=14 * S, fill=INK)
    ring(d, N / 2, 540 * S, 190 * S, 38 * S, 8)
    question(d, N / 2, 545 * S, 250 * S, INK)
    return img


OPTIONS = {"a-ring": option_ring, "b-bubble": option_bubble, "c-notepad": option_notepad}
CHOSEN = "b-bubble"


def main():
    sketches = "--sketches" in sys.argv
    out_dir = ROOT / "docs/icon-sketches"
    images = {}
    for name, draw in OPTIONS.items():
        if not sketches and name != CHOSEN:
            continue
        images[name] = draw().resize((SIZE, SIZE), Image.LANCZOS)
    images[CHOSEN].save(ROOT / "BeIrrational/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png")
    if sketches:
        out_dir.mkdir(parents=True, exist_ok=True)
        sheet = Image.new("RGB", (len(images) * 540 + 20, 560), (240, 240, 240))
        for i, (name, image) in enumerate(images.items()):
            image.save(out_dir / f"{name}.png")
            m = Image.new("L", (SIZE, SIZE), 0)
            ImageDraw.Draw(m).rounded_rectangle([0, 0, SIZE, SIZE], radius=230, fill=255)
            sheet.paste(image.resize((512, 512)), (20 + i * 540, 24), m.resize((512, 512)))
        sheet.save(out_dir / "z-all-variants.png")


if __name__ == "__main__":
    main()
