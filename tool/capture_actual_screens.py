"""Capture real Flutter Web screens through Chrome's DevTools protocol.

Chrome must be running with a remote debugging port, for example:
  chrome.exe --remote-debugging-port=9223 --remote-allow-origins=* \
    --user-data-dir=<temporary-profile> http://127.0.0.1:8123/

This script uses only Python's standard library so it does not add project
dependencies. It talks to Chrome over a small RFC 6455 WebSocket client.
"""

from __future__ import annotations

import base64
import hashlib
import json
import os
import socket
import struct
import sys
import time
import urllib.parse
import urllib.request
from pathlib import Path


class DevToolsSocket:
    def __init__(self, url: str) -> None:
        parsed = urllib.parse.urlparse(url)
        self.socket = socket.create_connection((parsed.hostname, parsed.port), timeout=15)
        key = base64.b64encode(os.urandom(16)).decode("ascii")
        resource = parsed.path + (f"?{parsed.query}" if parsed.query else "")
        request = (
            f"GET {resource} HTTP/1.1\r\n"
            f"Host: {parsed.hostname}:{parsed.port}\r\n"
            "Upgrade: websocket\r\n"
            "Connection: Upgrade\r\n"
            f"Sec-WebSocket-Key: {key}\r\n"
            "Sec-WebSocket-Version: 13\r\n"
            "Origin: http://127.0.0.1\r\n\r\n"
        )
        self.socket.sendall(request.encode("ascii"))
        response = self._receive_http_headers()
        if " 101 " not in response.splitlines()[0]:
            raise RuntimeError(f"WebSocket upgrade failed: {response}")
        accept = base64.b64encode(
            hashlib.sha1((key + "258EAFA5-E914-47DA-95CA-C5AB0DC85B11").encode()).digest()
        ).decode("ascii")
        if f"sec-websocket-accept: {accept}".lower() not in response.lower():
            raise RuntimeError("Chrome returned an invalid WebSocket accept key")
        self._next_id = 1

    def _receive_http_headers(self) -> str:
        data = bytearray()
        while b"\r\n\r\n" not in data:
            data.extend(self.socket.recv(4096))
        return data.decode("latin-1")

    def _send_frame(self, payload: bytes, opcode: int = 1) -> None:
        mask = os.urandom(4)
        length = len(payload)
        header = bytearray([0x80 | opcode])
        if length < 126:
            header.append(0x80 | length)
        elif length <= 0xFFFF:
            header.append(0x80 | 126)
            header.extend(struct.pack("!H", length))
        else:
            header.append(0x80 | 127)
            header.extend(struct.pack("!Q", length))
        header.extend(mask)
        masked = bytes(byte ^ mask[index % 4] for index, byte in enumerate(payload))
        self.socket.sendall(header + masked)

    def _read_exact(self, length: int) -> bytes:
        chunks = bytearray()
        while len(chunks) < length:
            chunk = self.socket.recv(length - len(chunks))
            if not chunk:
                raise ConnectionError("Chrome closed the DevTools connection")
            chunks.extend(chunk)
        return bytes(chunks)

    def _receive_frame(self) -> tuple[int, bytes]:
        first, second = self._read_exact(2)
        opcode = first & 0x0F
        length = second & 0x7F
        if length == 126:
            length = struct.unpack("!H", self._read_exact(2))[0]
        elif length == 127:
            length = struct.unpack("!Q", self._read_exact(8))[0]
        mask = self._read_exact(4) if second & 0x80 else None
        payload = self._read_exact(length)
        if mask:
            payload = bytes(byte ^ mask[index % 4] for index, byte in enumerate(payload))
        return opcode, payload

    def call(self, method: str, params: dict | None = None) -> dict:
        message_id = self._next_id
        self._next_id += 1
        payload = json.dumps(
            {"id": message_id, "method": method, "params": params or {}},
            separators=(",", ":"),
        ).encode("utf-8")
        self._send_frame(payload)
        while True:
            opcode, response = self._receive_frame()
            if opcode == 9:
                self._send_frame(response, opcode=10)
                continue
            if opcode != 1:
                continue
            decoded = json.loads(response)
            if decoded.get("id") == message_id:
                if "error" in decoded:
                    raise RuntimeError(f"CDP {method} failed: {decoded['error']}")
                return decoded.get("result", {})

    def close(self) -> None:
        try:
            self._send_frame(b"", opcode=8)
        finally:
            self.socket.close()


def find_page(debug_port: int) -> str:
    with urllib.request.urlopen(f"http://127.0.0.1:{debug_port}/json/list", timeout=10) as response:
        targets = json.load(response)
    pages = [target for target in targets if target.get("type") == "page"]
    local = [target for target in pages if "127.0.0.1:8123" in target.get("url", "")]
    target = (local or pages)[0]
    return target["webSocketDebuggerUrl"]


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    output = root / "docs" / "week1" / "actual_screens"
    output.mkdir(parents=True, exist_ok=True)
    socket_client = DevToolsSocket(find_page(9223))
    try:
        socket_client.call("Page.enable")
        socket_client.call(
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
        captures = [
            ("01_main_menu", "http://127.0.0.1:8123/"),
            ("02_city_brief", "http://127.0.0.1:8123/#/city"),
            ("03_candidate_files", "http://127.0.0.1:8123/#/candidates"),
            ("04_election", "http://127.0.0.1:8123/#/vote"),
        ]
        for name, url in captures:
            socket_client.call("Page.navigate", {"url": url})
            time.sleep(4)
            result = socket_client.call(
                "Page.captureScreenshot",
                {
                    "format": "png",
                    "fromSurface": True,
                    "captureBeyondViewport": False,
                },
            )
            destination = output / f"{name}.png"
            destination.write_bytes(base64.b64decode(result["data"]))
            print(f"captured {destination.name} ({destination.stat().st_size} bytes)")
    finally:
        socket_client.close()


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        print(f"capture failed: {error}", file=sys.stderr)
        raise
