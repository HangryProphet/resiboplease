"""Generate the single Public City Gallery API assignment PDF.

Pillow is used so this remains a project tool rather than an app dependency.
"""

from __future__ import annotations

import json
import textwrap
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs" / "submission"
PDF_PATH = OUT / "Resibo_Please_Public_City_Gallery_API_Submission.pdf"
PAGE = (1654, 2339)
MARGIN = 105
NAVY = "#102638"
DARK = "#07131f"
PAPER = "#fff5dc"
CREAM = "#f3dfae"
RED = "#b8424e"
TEAL = "#2f7d7a"
GOLD = "#e4b64f"
INK = "#172332"
MUTED = "#5f6d76"


def font(name: str, size: int) -> ImageFont.FreeTypeFont:
    paths = {
        "regular": Path(r"C:\Windows\Fonts\arial.ttf"),
        "bold": Path(r"C:\Windows\Fonts\arialbd.ttf"),
        "mono": Path(r"C:\Windows\Fonts\consola.ttf"),
        "mono_bold": Path(r"C:\Windows\Fonts\consolab.ttf"),
    }
    return ImageFont.truetype(str(paths[name]), size)


F_TITLE = font("bold", 62)
F_H1 = font("bold", 42)
F_H2 = font("bold", 29)
F_BODY = font("regular", 24)
F_BODY_B = font("bold", 24)
F_SMALL = font("regular", 20)
F_SMALL_B = font("bold", 20)
F_MONO = font("mono", 18)
F_MONO_SMALL = font("mono", 16)


def page(title: str, subtitle: str = "") -> tuple[Image.Image, ImageDraw.ImageDraw, int]:
    image = Image.new("RGB", PAGE, PAPER)
    draw = ImageDraw.Draw(image)
    draw.rectangle((0, 0, PAGE[0], 155), fill=NAVY)
    draw.rectangle((0, 155, PAGE[0], 168), fill=GOLD)
    draw.text((MARGIN, 42), title, font=F_H1, fill="#fff0c9")
    if subtitle:
        draw.text((MARGIN, 190), subtitle, font=F_SMALL_B, fill=RED)
        y = 235
    else:
        y = 205
    return image, draw, y


def footer(draw: ImageDraw.ImageDraw, number: int) -> None:
    draw.line((MARGIN, 2260, PAGE[0] - MARGIN, 2260), fill="#c6b78f", width=2)
    draw.text(
        (MARGIN, 2280),
        "Resibo, Please — Public City Gallery API",
        font=F_SMALL,
        fill=MUTED,
    )
    label = f"Page {number}"
    width = draw.textlength(label, font=F_SMALL)
    draw.text((PAGE[0] - MARGIN - width, 2280), label, font=F_SMALL, fill=MUTED)


def wrap(draw: ImageDraw.ImageDraw, text: str, width: int, used_font=F_BODY) -> list[str]:
    words = text.split()
    lines: list[str] = []
    current = ""
    for word in words:
        candidate = f"{current} {word}".strip()
        if draw.textlength(candidate, font=used_font) <= width:
            current = candidate
        else:
            if current:
                lines.append(current)
            current = word
    if current:
        lines.append(current)
    return lines


def paragraph(
    draw: ImageDraw.ImageDraw,
    text: str,
    y: int,
    *,
    x: int = MARGIN,
    width: int | None = None,
    used_font=F_BODY,
    fill=INK,
    spacing: int = 34,
) -> int:
    width = width or PAGE[0] - 2 * MARGIN
    for line in wrap(draw, text, width, used_font):
        draw.text((x, y), line, font=used_font, fill=fill)
        y += spacing
    return y + 10


def heading(draw: ImageDraw.ImageDraw, text: str, y: int) -> int:
    draw.rounded_rectangle(
        (MARGIN, y, PAGE[0] - MARGIN, y + 58), radius=10, fill=NAVY
    )
    draw.text((MARGIN + 18, y + 12), text, font=F_H2, fill="#fff0c9")
    return y + 76


def bullet(draw: ImageDraw.ImageDraw, text: str, y: int, level: int = 0) -> int:
    x = MARGIN + 24 + level * 35
    draw.ellipse((x, y + 9, x + 12, y + 21), fill=RED)
    return paragraph(
        draw,
        text,
        y,
        x=x + 28,
        width=PAGE[0] - MARGIN - (x + 28),
        used_font=F_BODY,
    )


def fit_image(draw: ImageDraw.ImageDraw, source: Path, box: tuple[int, int, int, int]) -> None:
    image = Image.open(source).convert("RGB")
    x1, y1, x2, y2 = box
    scale = min((x2 - x1) / image.width, (y2 - y1) / image.height)
    resized = image.resize(
        (int(image.width * scale), int(image.height * scale)), Image.Resampling.LANCZOS
    )
    x = x1 + (x2 - x1 - resized.width) // 2
    y = y1 + (y2 - y1 - resized.height) // 2
    draw.rounded_rectangle((x - 8, y - 8, x + resized.width + 8, y + resized.height + 8), radius=14, fill=DARK)
    draw._image.paste(resized, (x, y))


def source_lines(path: Path, ranges: list[tuple[int, int]]) -> list[str]:
    source = path.read_text(encoding="utf-8").splitlines()
    result: list[str] = []
    for index, (start, end) in enumerate(ranges):
        if index:
            result.append("      ...")
        for number in range(start, min(end, len(source)) + 1):
            result.append(f"{number:4}  {source[number - 1]}")
    return result


def code_block(
    draw: ImageDraw.ImageDraw,
    lines: list[str],
    y: int,
    *,
    height: int,
    used_font=F_MONO,
) -> int:
    draw.rounded_rectangle(
        (MARGIN, y, PAGE[0] - MARGIN, y + height), radius=12, fill="#0b1925"
    )
    line_height = used_font.size + 8
    max_lines = (height - 30) // line_height
    for index, line in enumerate(lines[:max_lines]):
        color = "#ffd778" if "http." in line or "json" in line else "#d8e5ea"
        draw.text((MARGIN + 18, y + 15 + index * line_height), line, font=used_font, fill=color)
    return y + height + 18


def render_code_screenshot() -> Path:
    image = Image.new("RGB", (1800, 1900), "#08131f")
    draw = ImageDraw.Draw(image)
    draw.rectangle((0, 0, 1800, 145), fill=NAVY)
    draw.text((55, 35), "API REQUEST IMPLEMENTATION", font=font("bold", 44), fill="#fff0c9")
    draw.text(
        (55, 170),
        "lib/data/gallery/city_gallery_api_service.dart",
        font=font("bold", 24),
        fill=GOLD,
    )
    lines = source_lines(
        ROOT / "lib" / "data" / "gallery" / "city_gallery_api_service.dart",
        [(76, 107), (123, 159), (188, 194)],
    )
    y = 215
    local_font = font("mono", 18)
    for line in lines:
        color = "#ffd778" if "http." in line or "json" in line else "#d8e5ea"
        draw.text((40, y), line, font=local_font, fill=color)
        y += 23
    destination = OUT / "api_request_implementation.png"
    image.save(destination)
    return destination


def render_json_screenshot() -> Path:
    rows = json.loads((OUT / "json_response_pretty.json").read_text(encoding="utf-8"))
    text = "[CityGalleryApi] GET JSON response:\n" + json.dumps(rows, indent=2)
    image = Image.new("RGB", (1800, 2000), "#08131f")
    draw = ImageDraw.Draw(image)
    draw.rectangle((0, 0, 1800, 145), fill=NAVY)
    draw.text((55, 35), "JSON RESPONSE SAMPLE", font=font("bold", 44), fill="#fff0c9")
    draw.text((55, 170), "Debug output from local API capture fixture", font=font("bold", 24), fill=GOLD)
    y = 220
    local_font = font("mono", 18)
    for raw in text.splitlines():
        chunks = textwrap.wrap(raw, width=148, replace_whitespace=False) or [""]
        for line in chunks:
            draw.text((42, y), line, font=local_font, fill="#d8e5ea")
            y += 23
            if y > 1960:
                break
        if y > 1960:
            break
    destination = OUT / "json_response_sample.png"
    image.save(destination)
    return destination


def build_pdf() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    code_image = render_code_screenshot()
    json_image = render_json_screenshot()
    pages: list[Image.Image] = []

    # Page 1 — requirements and delivery summary.
    image = Image.new("RGB", PAGE, DARK)
    draw = ImageDraw.Draw(image)
    draw.rectangle((0, 0, PAGE[0], 240), fill=NAVY)
    draw.rectangle((0, 240, PAGE[0], 257), fill=GOLD)
    draw.text((MARGIN, 62), "RESIBO, PLEASE", font=F_TITLE, fill="#fff0c9")
    draw.text((MARGIN, 305), "Public City Gallery API", font=font("bold", 52), fill=GOLD)
    draw.text((MARGIN, 375), "Implementation & Submission Evidence", font=F_H1, fill="white")
    y = 485
    draw.rounded_rectangle((MARGIN, y, PAGE[0] - MARGIN, 1900), radius=18, fill=CREAM)
    y += 40
    draw.text((MARGIN + 35, y), "SUBMISSION REQUIREMENTS", font=F_H1, fill=INK)
    y += 75
    requirements = [
        "1. Updated project source code.",
        "2. Screenshots showing: API request implementation; retrieved data displayed in the application; JSON response sample.",
        "3. Brief documentation including: API name; endpoint(s); request method(s); features added through API integration.",
    ]
    for item in requirements:
        y = paragraph(draw, item, y, x=MARGIN + 45, width=PAGE[0] - 2 * MARGIN - 90, used_font=F_BODY_B, spacing=38)
        y += 18
    y += 25
    draw.text((MARGIN + 35, y), "EXPECTED OUTPUT DELIVERED", font=F_H1, fill=RED)
    y += 70
    delivered = [
        "Publish → Retrieve → Browse → View using Supabase REST.",
        "Explicit HTTP GET, HTTP POST, jsonDecode, and jsonEncode.",
        "Sanitized public payload, RLS SQL, safe states, Retry, and offline cache.",
        "One PDF containing requirements, documentation, screenshots, code, and verification.",
    ]
    for item in delivered:
        y = bullet(draw, item, y)
    draw.text((MARGIN, 2050), "Prepared August 18, 2026", font=F_BODY_B, fill="#fff0c9")
    draw.text((MARGIN, 2100), "Fictional civic simulation — no real election guidance", font=F_SMALL, fill="#aabac4")
    pages.append(image)

    # Page 2 — brief API documentation.
    image, draw, y = page("Brief API Documentation", "School API integration requirement")
    y = heading(draw, "API Name & Purpose", y)
    y = paragraph(draw, "Supabase REST API (PostgREST). It stores and retrieves sanitized fictional city snapshots for the Resibo, Please Visit Cities gallery.", y)
    y = heading(draw, "Endpoints & Request Methods", y)
    y = bullet(draw, "GET {SUPABASE_URL}/rest/v1/city_snapshots — retrieves up to 50 published cities ordered newest first.", y)
    y = bullet(draw, "POST {SUPABASE_URL}/rest/v1/city_snapshots — publishes one completed sanitized city and requests the inserted row.", y)
    y = heading(draw, "Data Format", y)
    y = paragraph(draw, "JSON with city name, term number, starting pressure, top issue, selected candidate and party, final condition, outcome summary, major issues, major events, created date, and server ID.", y)
    y = heading(draw, "Features Added", y)
    for text in [
        "Term Report publish confirmation with Publishing, Published, and Failed/Retry states.",
        "Visit Cities loading, successful, empty, no-internet, invalid-response, and server-failure states.",
        "Newest-first city cards, public detail page, Retry, and last-successful-response cache.",
        "Debug-only JSON response logging; no raw exceptions shown to players.",
    ]:
        y = bullet(draw, text, y)
    y = heading(draw, "Security Boundary", y)
    y = paragraph(draw, "The app accepts only a normal publishable/anon key through --dart-define. It never includes a service-role key, database password, entire save, world seed, hidden candidate stats, investigation history, or personal information.", y)
    footer(draw, 2)
    pages.append(image)

    # Page 3 — direct request code screenshot.
    image, draw, y = page("Screenshot 1 — API Request Implementation", "Actual source: GET, POST, JSON encoding and decoding")
    fit_image(draw, code_image, (MARGIN, y, PAGE[0] - MARGIN, 2155))
    footer(draw, 3)
    pages.append(image)

    # Page 4 — retrieved data in real app.
    image, draw, y = page("Screenshot 2 — Retrieved Data in Application", "Compiled Flutter Web UI using the production HTTP service")
    fit_image(draw, OUT / "retrieved_cities_in_app.png", (MARGIN, y, PAGE[0] - MARGIN, 2075))
    paragraph(draw, "Capture fixture note: no Supabase credentials are committed. For this proof image the same production service retrieved three rows from a local Supabase-compatible REST fixture.", 2090, used_font=F_SMALL, spacing=26)
    footer(draw, 4)
    pages.append(image)

    # Page 5 — JSON response.
    image, draw, y = page("Screenshot 3 — JSON Response Sample", "Debug output from GET /rest/v1/city_snapshots")
    fit_image(draw, json_image, (MARGIN, y, PAGE[0] - MARGIN, 2155))
    footer(draw, 5)
    pages.append(image)

    # Page 6 — sanitized model source.
    image, draw, y = page("Relevant Source Code — Sanitized Snapshot", "Dedicated model and completed-term builder")
    lines = source_lines(
        ROOT / "lib" / "domain" / "models" / "public_city_snapshot.dart",
        [(41, 58), (89, 137)],
    )
    y = code_block(draw, lines, y, height=1750, used_font=F_MONO_SMALL)
    y = paragraph(draw, "Privacy result: this builder has no field for seed, candidate capabilities, evidence views, private notes, or the save object, so POST cannot serialize them accidentally.", y, used_font=F_SMALL_B, spacing=28)
    footer(draw, 6)
    pages.append(image)

    # Page 7 — cache and UI states source.
    image, draw, y = page("Relevant Source Code — Cache & UI States", "Live retrieval, offline fallback, loading/error/empty/results")
    repository_lines = source_lines(
        ROOT / "lib" / "data" / "gallery" / "city_gallery_repository.dart",
        [(26, 49)],
    )
    y = code_block(draw, repository_lines, y, height=690, used_font=F_MONO_SMALL)
    screen_lines = source_lines(
        ROOT / "lib" / "features" / "gallery" / "visit_cities_screen.dart",
        [(92, 149)],
    )
    y = code_block(draw, screen_lines, y, height=1110, used_font=F_MONO_SMALL)
    footer(draw, 7)
    pages.append(image)

    # Page 8 — Supabase and verification.
    image, draw, y = page("Backend Setup & Verification", "Table/RLS contract and completed checks")
    y = heading(draw, "Supabase Table and RLS", y)
    sql_lines = source_lines(
        ROOT / "docs" / "SUPABASE_CITY_GALLERY.sql",
        [(6, 24), (34, 59)],
    )
    y = code_block(draw, sql_lines, y, height=1120, used_font=F_MONO_SMALL)
    y = heading(draw, "Configuration", y)
    y = paragraph(draw, "Run with --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co and --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLISHABLE_OR_ANON_KEY. The SQL grants anonymous/authenticated SELECT and INSERT only; there is no public UPDATE or DELETE policy.", y, used_font=F_SMALL_B, spacing=28)
    y = heading(draw, "Verification Completed", y)
    for check in [
        "flutter analyze — no issues found",
        "flutter test — all 97 tests passed",
        "Focused API tests cover valid GET/POST, JSON parsing, invalid response, safe server failure, loading, empty, Retry, cache, detail navigation, sanitized publish, and duplicate-tap blocking",
        "flutter build web — production verification performed after evidence capture",
    ]:
        y = bullet(draw, check, y)
    footer(draw, 8)
    pages.append(image)

    pages[0].save(
        PDF_PATH,
        "PDF",
        resolution=150.0,
        save_all=True,
        append_images=pages[1:],
        title="Resibo, Please — Public City Gallery API Submission",
        author="Resibo, Please Project",
        subject="API integration requirements, source code, screenshots, and documentation",
    )
    print(f"created {PDF_PATH} ({PDF_PATH.stat().st_size} bytes, {len(pages)} pages)")


if __name__ == "__main__":
    build_pdf()
