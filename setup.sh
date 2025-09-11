#!/bin/bash

# --------------------------------
# Cross-platform (Linux, MacOS)
# --------------------------------

# Detect OS
OS_TYPE="$(uname)"
echo "Detected OS: $OS_TYPE"

# ------------------------------
# Linux package installation
# ------------------------------
install_linux() {
    local REQUIRED_CMDS=("bash" "curl" "tee" "date")

    if command -v apt >/dev/null 2>&1; then
        PKG_MANAGER="apt"
        UPDATE_CMD="sudo apt update"
        INSTALL_CMD="sudo apt install -y"
    elif command -v dnf >/dev/null 2>&1; then
        PKG_MANAGER="dnf"
        UPDATE_CMD="sudo dnf check-update"
        INSTALL_CMD="sudo dnf install -y"
    elif command -v pacman >/dev/null 2>&1; then
        PKG_MANAGER="pacman"
        UPDATE_CMD="sudo pacman -Sy"
        INSTALL_CMD="sudo pacman -S --noconfirm"
    else
        echo "No supported package manager found. Install required packages manually."
        exit 1
    fi

    echo "Updating..."
    $UPDATE_CMD >/dev/null 2>&1

    for cmd in "${REQUIRED_CMDS[@]}"; do
        if ! command -v $cmd >/dev/null 2>&1; then
            echo "$cmd not found. Installing..."
            $INSTALL_CMD $cmd >/dev/null 2>&1
        else
            echo "$cmd is already installed."
        fi

        # Verify installation
        if ! command -v $cmd >/dev/null 2>&1; then
            echo "Couldn't install $cmd. Exiting..."
            exit 1
        fi
    done
}

# ------------------------------
# MacOS package installation
# ------------------------------
install_macos() {
    local REQUIRED_CMDS=("bash" "curl" "tee" "date")

    # Check Homebrew
    if ! command -v brew >/dev/null 2>&1; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    echo "Updating Homebrew..."
    brew update >/dev/null 2>&1

    for cmd in "${REQUIRED_CMDS[@]}"; do
        if ! command -v $cmd >/dev/null 2>&1; then
            echo "$cmd not found. Installing via Homebrew..."
            brew install $cmd >/dev/null 2>&1
        else
            echo "$cmd is already installed."
        fi

        # Verify installation
        if ! command -v $cmd >/dev/null 2>&1; then
            echo "Couldn't install $cmd. Exiting..."
            exit 1
        fi
    done
}

# Run installer based on OS
if [[ "$OS_TYPE" == "Linux" ]]; then
    install_linux
elif [[ "$OS_TYPE" == "Darwin" ]]; then
    install_macos
else
    echo "Unsupported OS: $OS_TYPE"
    exit 1
fi

# --------------
# Files setup
# --------------
NAME="wifi_auto_login"
BASE_DIR="$HOME/.$NAME"
CREDFILE="$BASE_DIR/creds.txt"
LOGFILE="$BASE_DIR/logs.txt"
LOGINFILE="$BASE_DIR/login.sh"

CURR_DIR="$(pwd)"

echo -n "Enter your user ID: "
read USERNAME

echo -n "Enter your password: "
read PASSWORD

echo "Entered User ID: $USERNAME"
echo "Entered Password: $PASSWORD"
echo -n "Do you want to continue? [Y | n]: "
read CONF

if [[ "$CONF" != "y" && "$CONF" != "Y" ]]; then
    exit 1
fi

mkdir -p "$BASE_DIR"

[ ! -f "$CREDFILE" ] && touch "$CREDFILE"
echo "USERNAME=\"$USERNAME\"" > $CREDFILE
echo "PASSWORD=\"$PASSWORD\"" >> $CREDFILE

[ ! -f "$LOGFILE" ] && touch "$LOGFILE"
if [ ! -f "$LOGINFILE" ]; then
    cp "$CURR_DIR/login.sh" "$LOGINFILE"
    chmod +x "$LOGINFILE"
fi

# ---------------------------
# Script automation setup
# ---------------------------
if [[ "$OS_TYPE" == "Linux" ]]; then
    
    # systemd setup for linux
    SYSTEMD_NAME="wifi-auto-login.service"
    SYSTEMD_FILE="$HOME/.config/systemd/user/$SYSTEMD_NAME"

    mkdir -p "$HOME/.config/systemd/user/"

    if [ ! -f "$SYSTEMD_FILE" ]; then
        cp "$CURR_DIR/wifi-auto-login.service" "$SYSTEMD_FILE"
    fi
    
    systemctl --user enable "$SYSTEMD_NAME" >/dev/null 2>&1
    systemctl --user start "$SYSTEMD_NAME" >/dev/null 2>&1

elif [[ "$OS_TYPE" == "Darwin" ]]; then

    # macOS launchd setup
    LAUNCHD_DIR="$HOME/Library/LaunchAgents"
    PLIST_DEST="$LAUNCHD_DIR/com.username.wifi-auto-login.plist"
    LOGIN_SCRIPT="$LOGINFILE"
    LOG_FILE="$LOGFILE"
    INTERVAL=10

    mkdir -p "$LAUNCHD_DIR"

    if [ ! -f "$PLIST_DEST" ]; then
        cp "$CURR_DIR/wifi-auto-login.plist" "$PLIST_DEST"
        chmod 644 "$PLIST_DEST"

        # Replace placeholders in plist
        sed -i "" "s|__LOGIN_SCRIPT__|$LOGIN_SCRIPT|g" "$PLIST_DEST"
        sed -i "" "s|__LOG_FILE__|$LOG_FILE|g" "$PLIST_DEST"
        sed -i "" "s|__INTERVAL__|$INTERVAL|g" "$PLIST_DEST"
    fi

    # Load and enable plist
    launchctl bootout gui/$(id -u) "$PLIST_DEST" 2>/dev/null
    launchctl bootstrap gui/$(id -u) "$PLIST_DEST"
    launchctl enable gui/$(id -u)/com.username.wifi-auto-login

fi

# ---------------------
# Script completion
# ---------------------
echo "Setup completed."
echo "Run these commands to interact with the script:"
if [[ "$OS_TYPE" == "Linux" ]]; then
    echo "start: systemctl --user start $SYSTEMD_NAME"
    echo "stop: systemctl --user stop $SYSTEMD_NAME"
    echo "status: systemctl --user status $SYSTEMD_NAME"
elif [[ "$OS_TYPE" == "Darwin" ]]; then
    echo "start: launchctl bootstrap gui/$(id -u) $PLIST_DEST"
    echo "stop: launchctl bootout gui/$(id -u) $PLIST_DEST"
fi