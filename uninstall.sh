#!/bin/bash

# -------------------------------------------------
# Cross-platform uninstall script (Linux, MacOS)
# -------------------------------------------------

# Detect OS
OS_TYPE="$(uname)"
echo "Detected OS: $OS_TYPE"

# Base directories & files
NAME="wifi_auto_login"
BASE_DIR="$HOME/.$NAME"

# Linux systemd variables
SYSTEMD_NAME="wifi-auto-login.service"
SYSTEMD_FILE="$HOME/.config/systemd/user/$SYSTEMD_NAME"

# macOS launchd variables
LAUNCHD_DIR="$HOME/Library/LaunchAgents"
PLIST_DEST="$LAUNCHD_DIR/com.username.wifi-auto-login.plist"

echo "Uninstalling $NAME..."

# ---------------------------
# Linux systemd uninstall
# ---------------------------
if [[ "$OS_TYPE" == "Linux" ]]; then
    if [ -f "$SYSTEMD_FILE" ]; then
        echo "Stopping systemd service..."
        systemctl --user stop "$SYSTEMD_NAME" 2>/dev/null
        echo "Disabling systemd service..."
        systemctl --user disable "$SYSTEMD_NAME" 2>/dev/null
        echo "Removing service file..."
        rm -f "$SYSTEMD_FILE"
    fi
fi

# ---------------------------
# macOS launchd uninstall
# ---------------------------
if [[ "$OS_TYPE" == "Darwin" ]]; then
    if [ -f "$PLIST_DEST" ]; then
        echo "Unloading launchd plist..."
        launchctl bootout gui/$(id -u) "$PLIST_DEST" 2>/dev/null || \
            launchctl unload "$PLIST_DEST" 2>/dev/null
        echo "Removing plist file..."
        rm -f "$PLIST_DEST"
    fi
fi

# ------------------------------------------
# Remove credentials, logs, login script
# ------------------------------------------
if [ -d "$BASE_DIR" ]; then
    echo "Removing credentials, logs, and login script..."
    rm -rf "$BASE_DIR"
fi

echo "Cleanup completed."
