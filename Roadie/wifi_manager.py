# wifi_manager.py
import subprocess, json, shlex
from PySide6.QtCore import QObject, Signal, Slot, Property

def _run(cmd):
    try:
        r = subprocess.run(cmd, shell=True, check=False, text=True,
                           stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        return r.returncode, r.stdout.strip(), r.stderr.strip()
    except Exception as e:
        return 1, "", str(e)

class WifiManager(QObject):
    networksChanged = Signal()
    connectedChanged = Signal()
    message = Signal(str)

    def __init__(self, parent=None):
        super().__init__(parent)
        self._networks = []
        self._connected_ssid = ""
        self.refresh_status()

    # ---------- Public properties ----------
    def get_networks(self):
        return self._networks
    networks = Property('QVariantList', fget=get_networks, notify=networksChanged)

    def get_connected_ssid(self):
        return self._connected_ssid
    connectedSsid = Property(str, fget=get_connected_ssid, notify=connectedChanged)

    @Property(bool, notify=connectedChanged)
    def connected(self):
        return bool(self._connected_ssid)

    # ---------- Internal helpers ----------
    def refresh_status(self):
        # Find active wifi SSID
        # Try: nmcli -t -f ACTIVE,SSID dev wifi | grep ^yes
        rc, out, _ = _run("nmcli -t -f ACTIVE,SSID dev wifi")
        active = ""
        if rc == 0:
            for line in out.splitlines():
                parts = line.split(":")
                if len(parts) >= 2 and parts[0] == "yes":
                    active = parts[1]
                    break
        old = self._connected_ssid
        self._connected_ssid = active
        if old != self._connected_ssid:
            self.connectedChanged.emit()

    def parse_scan(self, text):
        nets = []
        for line in text.splitlines():
            # Format: SSID:SECURITY:SIGNAL
            parts = line.split(":")
            if len(parts) < 3:
                continue
            ssid = parts[0]
            security = parts[1] or "--"
            try:
                signal = int(parts[2])
            except:
                signal = 0
            # Collapse hidden/empty SSIDs into friendly label but keep actual
            nets.append({
                "ssid": ssid if ssid else "(hidden)",
                "rawSsid": ssid,
                "security": security,
                "locked": security != "--",
                "signal": signal
            })
        # Remove duplicates (keep strongest)
        by_ssid = {}
        for n in nets:
            key = (n["rawSsid"], n["locked"])
            if key not in by_ssid or n["signal"] > by_ssid[key]["signal"]:
                by_ssid[key] = n
        return sorted(by_ssid.values(), key=lambda x: -x["signal"])

    # ---------- Slots callable from QML ----------
    @Slot()
    def scan(self):
        # Rescan then list
        _run("nmcli device wifi rescan")
        rc, out, err = _run("nmcli -t -f SSID,SECURITY,SIGNAL dev wifi list")
        if rc != 0:
            self.message.emit(f"Scan failed: {err or out}")
            return
        self._networks = self.parse_scan(out)
        self.networksChanged.emit()
        self.refresh_status()

    @Slot(str, str)
    def connect(self, ssid, password):
        # open: nmcli dev wifi connect "SSID"
        # secured: nmcli dev wifi connect "SSID" password "pass"
        ssid_esc = ssid.replace('"', r'\"')
        if password:
            cmd = f'nmcli dev wifi connect "{ssid_esc}" password "{password}"'
        else:
            cmd = f'nmcli dev wifi connect "{ssid_esc}"'
        rc, out, err = _run(cmd)
        if rc == 0:
            self.message.emit(f"Connected to {ssid}")
        else:
            self.message.emit(f"Connect failed: {err or out}")
        self.refresh_status()
        self.scan()

    @Slot(str)
    def disconnect(self, ssid):
        # Try to bring down any connection profile with this SSID name
        ssid_esc = ssid.replace('"', r'\"')
        # First find exact connection names matching SSID
        rc, out, _ = _run("nmcli -t -f NAME,TYPE connection show --active")
        if rc == 0:
            for line in out.splitlines():
                name, ctype = (line.split(":") + [""])[:2]
                if ctype == "wifi" and name == ssid:
                    _run(f'nmcli connection down "{ssid_esc}"')
        # As a fallback, disconnect wifi device
        _run("nmcli radio wifi on")
        self.message.emit(f"Disconnected {ssid}")
        self.refresh_status()
        self.scan()
