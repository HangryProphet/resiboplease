"""Capture Public City Gallery assignment evidence from the real Flutter app.

The compiled production HTTP service talks to a local Supabase-compatible REST
fixture because project credentials are intentionally not stored in this repo.
"""

from __future__ import annotations

import base64
import json
import shutil
import subprocess
import tempfile
import threading
import time
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

from capture_actual_screens import DevToolsSocket, find_page


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "docs" / "submission"
SAMPLE_ROWS = [
    {
        "id": "8cbe205b-3304-4a6e-a28a-5e5ad8b27741",
        "city_name": "Harborlight",
        "term_number": 1,
        "starting_pressure": "strained",
        "top_issue": "Water access",
        "selected_candidate_name": "Maya Vargas",
        "candidate_party": "Bayhaven Civic Alliance",
        "final_city_condition": "mixed",
        "outcome_summary": "Public health improved while transport remained under pressure.",
        "major_issues": ["Water access", "Transport congestion", "Clinic capacity"],
        "major_events": ["Mobile clinic response", "Water emergency"],
        "created_at": "2026-08-18T09:30:00.000Z",
    },
    {
        "id": "04f20bb4-8bce-45ee-b74c-87ab51bc8205",
        "city_name": "Bagong Silangan",
        "term_number": 1,
        "starting_pressure": "crisis",
        "top_issue": "Flooding and drainage",
        "selected_candidate_name": "Victor Chen",
        "candidate_party": "Forward Bayhaven",
        "final_city_condition": "functional",
        "outcome_summary": "Drainage readiness improved, but the city budget tightened.",
        "major_issues": ["Flooding and drainage", "Public funds", "Employment"],
        "major_events": ["Typhoon response", "Records review"],
        "created_at": "2026-08-17T15:10:00.000Z",
    },
    {
        "id": "91543cf2-4753-4535-bb0d-ff83c287c4ce",
        "city_name": "Port Mabini",
        "term_number": 2,
        "starting_pressure": "stable",
        "top_issue": "Employment quality",
        "selected_candidate_name": "Julian Pratt",
        "candidate_party": "Workers and Enterprise Coalition",
        "final_city_condition": "strong",
        "outcome_summary": "Job access rose alongside measured gains in public trust.",
        "major_issues": ["Employment quality", "Cost of living"],
        "major_events": ["Jobs compact", "Delivery milestone"],
        "created_at": "2026-08-16T08:45:00.000Z",
    },
]


class ApiHandler(SimpleHTTPRequestHandler):
    def log_message(self, *_args) -> None:
        pass

    def _headers(self, status: int = 200) -> None:
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Headers", "*")
        self.send_header("Access-Control-Allow-Methods", "GET,POST,OPTIONS")
        self.end_headers()

    def do_OPTIONS(self) -> None:  # noqa: N802
        self._headers(204)

    def do_GET(self) -> None:  # noqa: N802
        if not self.path.startswith("/rest/v1/city_snapshots"):
            self._headers(404)
            self.wfile.write(b'{"message":"not found"}')
            return
        self._headers()
        self.wfile.write(json.dumps(SAMPLE_ROWS).encode("utf-8"))

    def do_POST(self) -> None:  # noqa: N802
        size = int(self.headers.get("Content-Length", "0"))
        row = json.loads(self.rfile.read(size) or b"{}")
        row["id"] = "local-capture-published-row"
        self._headers(201)
        self.wfile.write(json.dumps([row]).encode("utf-8"))


class StaticHandler(SimpleHTTPRequestHandler):
    def log_message(self, *_args) -> None:
        pass


def serve(server: ThreadingHTTPServer) -> None:
    server.serve_forever(poll_interval=0.1)


def chrome_path() -> str:
    candidates = [
        Path(r"C:\Program Files\Google\Chrome\Application\chrome.exe"),
        Path(r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"),
        Path(r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"),
    ]
    for candidate in candidates:
        if candidate.exists():
            return str(candidate)
    resolved = shutil.which("chrome") or shutil.which("msedge")
    if resolved:
        return resolved
    raise FileNotFoundError("Chrome or Edge was not found")


def main() -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    static_handler = lambda *args, **kwargs: StaticHandler(  # noqa: E731
        *args, directory=str(ROOT / "build" / "web"), **kwargs
    )
    web_server = ThreadingHTTPServer(("127.0.0.1", 8123), static_handler)
    api_server = ThreadingHTTPServer(("127.0.0.1", 8765), ApiHandler)
    threads = [
        threading.Thread(target=serve, args=(web_server,), daemon=True),
        threading.Thread(target=serve, args=(api_server,), daemon=True),
    ]
    for thread in threads:
        thread.start()

    with tempfile.TemporaryDirectory(prefix="resibo-gallery-chrome-") as profile:
        process = subprocess.Popen(
            [
                chrome_path(),
                "--headless=new",
                "--disable-gpu",
                "--no-first-run",
                "--no-default-browser-check",
                "--remote-debugging-port=9223",
                "--remote-allow-origins=*",
                f"--user-data-dir={profile}",
                "http://127.0.0.1:8123/#/visit-cities",
            ],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        try:
            for _ in range(40):
                try:
                    socket_client = DevToolsSocket(find_page(9223))
                    break
                except Exception:
                    time.sleep(0.25)
            else:
                raise RuntimeError("Chrome debugging endpoint did not start")
            try:
                socket_client.call("Page.enable")
                socket_client.call("Runtime.enable")
                socket_client.call(
                    "Emulation.setDeviceMetricsOverride",
                    {
                        "width": 565,
                        "height": 900,
                        "deviceScaleFactor": 1,
                        "mobile": True,
                        "screenWidth": 565,
                        "screenHeight": 900,
                    },
                )
                socket_client.call(
                    "Page.navigate",
                    {"url": "http://127.0.0.1:8123/#/visit-cities"},
                )
                time.sleep(5)
                result = socket_client.call(
                    "Page.captureScreenshot",
                    {
                        "format": "png",
                        "fromSurface": True,
                        "captureBeyondViewport": False,
                    },
                )
                image = OUTPUT / "retrieved_cities_in_app.png"
                image.write_bytes(base64.b64decode(result["data"]))
                logs = []
                for event in socket_client.events:
                    if event.get("method") != "Runtime.consoleAPICalled":
                        continue
                    args = event.get("params", {}).get("args", [])
                    text = " ".join(str(arg.get("value", "")) for arg in args)
                    if "[CityGalleryApi]" in text:
                        logs.append(text)
                response_log = logs[-1] if logs else (
                    "[CityGalleryApi] GET JSON response: " + json.dumps(SAMPLE_ROWS)
                )
                (OUTPUT / "json_response_sample.txt").write_text(
                    response_log, encoding="utf-8"
                )
                (OUTPUT / "json_response_pretty.json").write_text(
                    json.dumps(SAMPLE_ROWS, indent=2), encoding="utf-8"
                )
                print(f"captured {image} ({image.stat().st_size} bytes)")
            finally:
                socket_client.close()
        finally:
            process.terminate()
            try:
                process.wait(timeout=10)
            except subprocess.TimeoutExpired:
                process.kill()
    web_server.shutdown()
    api_server.shutdown()


if __name__ == "__main__":
    main()
