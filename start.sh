#!/bin/bash

# Define packages in a vertical (multi-line) format for easier editing
PACKAGES="
apt-listchanges
ca-certificates
cifs-utils
curl
fzf
git
gnupg
htop
ipcalc
jq
ncdu
nfs-common
nmap
pkg-config
python3
rsync
samba-common-bin
smbclient
sudo
tldr
unattended-upgrades
wget
"

# Function to display colored status messages
status_msg() {
    echo -e "\033[1;34m► $1\033[0m"
}

# Function to display success messages
success_msg() {
    echo -e "\033[1;32m✓ $1\033[0m"
}

# Function to display error messages
error_msg() {
    echo -e "\033[1;31m✗ $1\033[0m"
}

# Check if running in LXC container
is_in_lxc() {
    grep -q container=lxc /proc/1/environ 2>/dev/null
    return $?
}

setup_prerequisites() {
    # Check if running in LXC container
    if is_in_lxc; then
        status_msg "Detected LXC container environment"
        status_msg "Installing system packages..."
        apt-get update -qq >/dev/null
        apt-get install -y ${PACKAGES//$'\n'/ } >/dev/null 2>&1
        success_msg "Package installation complete"
    elif [ "$(id -u)" -eq 0 ]; then
        status_msg "Installing system packages..."
        apt-get update -qq >/dev/null
        apt-get install -y ${PACKAGES//$'\n'/ } >/dev/null 2>&1
        success_msg "Package installation complete"
    else
        INSTALL_SCRIPT="/tmp/base_prerequisites.sh"
        cat > "$INSTALL_SCRIPT" <<EOF
#!/bin/bash
status_msg() {
    echo -e "\033[1;34m► \$1\033[0m"
}
success_msg() {
    echo -e "\033[1;32m✓ \$1\033[0m"
}
error_msg() {
    echo -e "\033[1;31m✗ \$1\033[0m"
}
status_msg "Installing system packages..."
apt-get update -qq >/dev/null
apt-get install -y ${PACKAGES//$'\n'/ } >/dev/null 2>&1
apt-get update -qq >/dev/null
success_msg "Package installation complete"

# If a non-root user is detected, add them to sudoers
if [ -n "\$SUDO_USER" ] && [ "\$SUDO_USER" != "root" ]; then
    status_msg "Configuring sudo access for \$SUDO_USER"
    echo "\$SUDO_USER ALL=(ALL) ALL" > /etc/sudoers.d/\$SUDO_USER
    chmod 0440 /etc/sudoers.d/\$SUDO_USER
    success_msg "Sudo access granted for \$SUDO_USER"
elif [ -n "\$USER" ] && [ "\$USER" != "root" ]; then
    status_msg "Configuring sudo access for \$USER"
    echo "\$USER ALL=(ALL) ALL" > /etc/sudoers.d/\$USER
    chmod 0440 /etc/sudoers.d/\$USER
    success_msg "Sudo access granted for \$USER"
fi
EOF
        chmod +x "$INSTALL_SCRIPT"

        if command -v sudo &>/dev/null; then
            status_msg "Requesting elevated privileges (enter your password)..."
            sudo bash "$INSTALL_SCRIPT"
        else
            status_msg "Root privileges required (enter root password)..."
            su -c "$INSTALL_SCRIPT" root
        fi

        rm -f "$INSTALL_SCRIPT"
    fi
}

# Main execution
status_msg "Initializing system configuration..."
setup_prerequisites

# Check if prerequisites were successfully installed
if ! command -v python3 &>/dev/null; then
    error_msg "Failed to install Python3. Exiting."
    exit 1
fi

# Check if repository already exists
REPO_DIR="deb-postinstall"
if [ -d "$REPO_DIR" ]; then
    status_msg "Repository already exists, updating instead of cloning..."
    cd "$REPO_DIR" && git pull >/dev/null 2>&1
    success_msg "Repository updated"
else
    status_msg "Cloning repository..."
    git clone https://github.com/clear-cmos/deb-postinst.git "$REPO_DIR" >/dev/null 2>&1
    cd "$REPO_DIR"
    success_msg "Repository cloned"
fi

chmod +x base.py
status_msg "Launching configuration utility..."
python3 ./base.py
success_msg "Setup completed successfully"
