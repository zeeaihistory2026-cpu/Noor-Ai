"""Small adb UI helper for the explicitly authorized MuslimGo handset checks."""
import json
import re
import subprocess
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "build" / "audit" / "device"
OUT.mkdir(parents=True, exist_ok=True)
ADB = Path.home() / "AppData/Local/Android/sdk/platform-tools/adb.exe"
SERIAL = "8DW4X4DY9PXWDEEQ"


def adb(*args):
    return subprocess.run([str(ADB), "-s", SERIAL, *args], check=True,
                          capture_output=True, text=True, encoding="utf-8").stdout.strip()


PACKAGE = "com.noorai.com.audit"


def guard_foreground():
    state = adb("shell", "dumpsys", "activity", "activities")
    line = next((line for line in state.splitlines() if "topResumedActivity" in line or "mResumedActivity" in line), "")
    if f"{PACKAGE}/" not in line:
        raise RuntimeError("MuslimGo Test is not foreground. No input or screenshot was taken.")


def observed_nodes():
    guard_foreground()
    adb("shell", "uiautomator", "dump", "/data/local/tmp/muslimgo-audit.xml")
    xml = adb("shell", "cat", "/data/local/tmp/muslimgo-audit.xml")
    nodes = list(ET.fromstring(xml).iter("node"))
    if not any(n.get("package") == PACKAGE and
               (n.get("text") or n.get("content-desc")) for n in nodes):
        raise RuntimeError("MuslimGo Test has no visible content. No snapshot or input was taken.")
    if any(marker in xml for marker in ("Use strong password?", "Generated password")):
        raise RuntimeError("Autofill UI is visible. No snapshot or input was taken.")
    guard_foreground()
    return xml, nodes


def snapshot(name):
    if not re.fullmatch(r"[a-zA-Z0-9_-]+", name):
        raise ValueError("Snapshot name must contain letters, numbers, hyphens or underscores only")
    xml, nodes = observed_nodes()
    rows = [{"text": n.get("text"), "label": n.get("content-desc"),
             "bounds": n.get("bounds"), "clickable": n.get("clickable"),
             "class": n.get("class")} for n in nodes
            if n.get("package") == PACKAGE and (n.get("text") or n.get("content-desc"))]
    (OUT / f"{name}.xml").write_text(xml, encoding="utf8")
    guard_foreground()
    adb("shell", "screencap", "-p", "/data/local/tmp/muslimgo-audit.png")
    adb("pull", "/data/local/tmp/muslimgo-audit.png", str(OUT / f"{name}.png"))
    (OUT / f"{name}.json").write_text(json.dumps(rows, indent=2), encoding="utf8")
    print(re.sub(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}', '<account email>', json.dumps(rows, ensure_ascii=False, indent=2)))


def tap(label):
    _, nodes = observed_nodes()
    matches = [n for n in nodes if n.get("package") == PACKAGE and label in (n.get("text"), n.get("content-desc"))]
    clickable = [n for n in matches if n.get("clickable") == "true"]
    if clickable:
        matches = clickable
    if len(matches) != 1:
        raise RuntimeError(f"Expected one observed target {label!r}; found {len(matches)}")
    x1, y1, x2, y2 = map(int, re.findall(r"\d+", matches[0].get("bounds")))
    guard_foreground()
    print(adb("shell", "input", "tap", str((x1+x2)//2), str((y1+y2)//2)))


if __name__ == "__main__":
    if sys.argv[1] == "snapshot":
        snapshot(sys.argv[2])
    elif sys.argv[1] == "tap":
        tap(sys.argv[2])
    else:
        raise SystemExit("Use snapshot NAME or tap EXACT_OBSERVED_LABEL")
