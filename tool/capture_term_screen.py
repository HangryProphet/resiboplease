"""Interactive companion for capture_actual_screens.py.

It drives the local ballot with Chrome input events so a real term screen can
be captured without adding debug behavior to the production Flutter app.
"""

from __future__ import annotations

import base64
import time
from pathlib import Path

from capture_actual_screens import DevToolsSocket, find_page


def click(client: DevToolsSocket, x: int, y: int) -> None:
    common = {"x": x, "y": y, "button": "left", "clickCount": 1}
    client.call("Input.dispatchMouseEvent", {"type": "mousePressed", **common})
    client.call("Input.dispatchMouseEvent", {"type": "mouseReleased", **common})


def capture(client: DevToolsSocket, destination: Path) -> None:
    result = client.call(
        "Page.captureScreenshot",
        {"format": "png", "fromSurface": True, "captureBeyondViewport": False},
    )
    destination.write_bytes(base64.b64decode(result["data"]))
    print(f"captured {destination.name} ({destination.stat().st_size} bytes)")


def main() -> None:
    output = Path(__file__).resolve().parents[1] / "docs" / "week1" / "actual_screens"
    output.mkdir(parents=True, exist_ok=True)
    client = DevToolsSocket(find_page(9223))
    try:
        client.call("Page.enable")
        client.call(
            "Emulation.setDeviceMetricsOverride",
            {
                "width": 390,
                "height": 844,
                "deviceScaleFactor": 1,
                "mobile": True,
                "screenWidth": 390,
                "screenHeight": 844,
            },
        )
        client.call("Page.navigate", {"url": "http://127.0.0.1:8123/#/vote"})
        time.sleep(1)
        client.call("Page.reload", {"ignoreCache": True})
        time.sleep(4)
        click(client, 210, 390)
        time.sleep(1)
        client.call(
            "Input.dispatchMouseEvent",
            {"type": "mouseWheel", "x": 210, "y": 730, "deltaX": 0, "deltaY": 720},
        )
        time.sleep(2)
        capture(client, output / "vote_scrolled_debug.png")
        click(client, 80, 220)
        time.sleep(1)
        client.call(
            "Input.dispatchMouseEvent",
            {"type": "mouseWheel", "x": 210, "y": 730, "deltaX": 0, "deltaY": 520},
        )
        time.sleep(2)
        capture(client, output / "vote_submit_debug.png")
        click(client, 195, 780)
        time.sleep(2)
        capture(client, output / "vote_confirm_debug.png")
        click(client, 255, 498)
        time.sleep(3)
        capture(client, output / "winner_reveal_debug.png")
        click(client, 195, 655)
        time.sleep(4)
        capture(client, output / "05_term_simulation.png")
    finally:
        client.close()


if __name__ == "__main__":
    main()
