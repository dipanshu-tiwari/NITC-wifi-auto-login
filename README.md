# 🌐 NITC WiFi Auto Login

A **cross-platform WiFi auto-login utility for National Institute of Technology, Calicut** that keeps you connected without the hassle of entering credentials every time.  
Supports **Linux (systemd)**, **macOS (launchd)**, and **Windows (Task Scheduler)**.

---

## ✨ Features
- 🔑 Securely stores your WiFi credentials (username & password).
- ⚡ Automatically logs you into captive portal / WiFi login pages.
- 🖥️ Cross-platform: **Linux, macOS, Windows**.
- 🛠️ Simple **setup** and **uninstall** scripts included.
- 📜 Lightweight — no bloat, pure bash + batch.

---

## 📦 Installation

### Linux & macOS
```bash
git clone https://github.com/yourusername/wifi-auto-login.git
cd wifi-auto-login
chmod +x setup.sh
./setup.sh
```

### Windows
Run **PowerShell as Administrator** and execute:
```batch
./setup.bat
```

---

## 🧩 Usage

### Linux
```bash
systemctl --user start wifi-auto-login.service
systemctl --user stop wifi-auto-login.service
systemctl --user status wifi-auto-login.service
```

### macOS
```bash
launchctl start gui/$(id -u)/com.username.wifi-auto-login
launchctl stop gui/$(id -u)/com.username.wifi-auto-login
```

### Windows
```powershell
schtasks /Run /TN "WiFiAutoLogin"
schtasks /End /TN "WiFiAutoLogin"
```

---

## ❌ Uninstallation

### Linux & macOS
```bash
chmod +x uninstall.sh
./uninstall.sh
```

### Windows
```powershell
.\uninstall.bat
```

---

## ⚠️ Disclaimer
This tool is intended for **personal use only**.  
Do not use it on networks where you do not have permission.

---

## 💡 Contributing
PRs are welcome! If you find bugs or want new features, open an issue.

---

## 📜 License
[MIT License](LICENSE)