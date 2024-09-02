#!/bin/bash
# "Things To Do!" script for a fresh Fedora Workstation installation

# Check if the script is run with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo"
    exit 1
fi

# Set variables
ACTUAL_USER=$SUDO_USER
ACTUAL_HOME=$(eval echo ~$SUDO_USER)
LOG_FILE="/var/log/fedora_things_to_do.log"

# Function to generate timestamps
get_timestamp() {
    date +"%Y-%m-%d %H:%M:%S"
}

# Function to log messages
log_message() {
    local message="$1"
    echo "$(get_timestamp) - $message" | tee -a "$LOG_FILE"
}

# Function to handle errors
handle_error() {
    local exit_code=$?
    local message="$1"
    if [ $exit_code -ne 0 ]; then
        log_message "ERROR: $message"
        exit $exit_code
    fi
}

# Function to prompt for reboot
prompt_reboot() {
    sudo -u $ACTUAL_USER bash -c 'read -p "It is time to reboot the machine. Would you like to do it now? (y/n): " choice; [[ $choice == [yY] ]]'
    if [ $? -eq 0 ]; then
        log_message "Rebooting..."
        reboot
    else
        log_message "Reboot canceled."
    fi
}

# Function to backup configuration files
backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        cp "$file" "$file.bak"
        handle_error "Failed to backup $file"
        log_message "Backed up $file"
    fi
}

echo "";
echo "╔═════════════════════════════════════════════════════════════════════════════╗";
echo "║                                                                             ║";
echo "║   ░█▀▀░█▀▀░█▀▄░█▀█░█▀▄░█▀█░░░█░█░█▀█░█▀▄░█░█░█▀▀░▀█▀░█▀█░▀█▀░▀█▀░█▀█░█▀█░   ║";
echo "║   ░█▀▀░█▀▀░█░█░█░█░█▀▄░█▀█░░░█▄█░█░█░█▀▄░█▀▄░▀▀█░░█░░█▀█░░█░░░█░░█░█░█░█░   ║";
echo "║   ░▀░░░▀▀▀░▀▀░░▀▀▀░▀░▀░▀░▀░░░▀░▀░▀▀▀░▀░▀░▀░▀░▀▀▀░░▀░░▀░▀░░▀░░▀▀▀░▀▀▀░▀░▀░   ║";
echo "║   ░░░░░░░░░░░░▀█▀░█░█░▀█▀░█▀█░█▀▀░█▀▀░░░▀█▀░█▀█░░░█▀▄░█▀█░█░░░░░░░░░░░░░░   ║";
echo "║   ░░░░░░░░░░░░░█░░█▀█░░█░░█░█░█░█░▀▀█░░░░█░░█░█░░░█░█░█░█░▀░░░░░░░░░░░░░░   ║";
echo "║   ░░░░░░░░░░░░░▀░░▀░▀░▀▀▀░▀░▀░▀▀▀░▀▀▀░░░░▀░░▀▀▀░░░▀▀░░▀▀▀░▀░░░░░░░░░░░░░░   ║";
echo "║                                                                             ║";
echo "╚═════════════════════════════════════════════════════════════════════════════╝";
echo "";
echo "This script automates \"Things To Do!\" steps after a fresh Fedora Workstation installation"
echo "ver. 24.09"
echo ""
echo "Don't run this script if you didn't build it yourself or don't know what it does."
echo ""
read -p "Press Enter to continue or CTRL+C to cancel..."

# System Upgrade
log_message "Performing system upgrade... This may take a while..."
dnf upgrade -y > /dev/null 2>&1


# System Configuration
# Optimize DNF package manager for faster downloads and efficient updates
log_message "Configuring DNF Package Manager..."
backup_file "/etc/dnf/dnf.conf" > /dev/null 2>&1
echo "max_parallel_downloads=10" | tee -a /etc/dnf/dnf.conf > /dev/null
echo "fastestmirror=True" | tee -a /etc/dnf/dnf.conf > /dev/null
dnf -y install dnf-plugins-core > /dev/null 2>&1

# Enable RPM Fusion repositories to access additional software packages and codecs
log_message "Enabling RPM Fusion repositories..."
dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm > /dev/null 2>&1
dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm > /dev/null 2>&1
dnf group update core -y > /dev/null 2>&1

# Install multimedia codecs to enhance multimedia capabilities
log_message "Installing multimedia codecs..."
dnf swap ffmpeg-free ffmpeg --allowerasing -y > /dev/null 2>&1
dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin -y > /dev/null 2>&1
dnf update @sound-and-video -y > /dev/null 2>&1

# Install Hardware Accelerated Codecs for Intel integrated GPUs. This improves video playback and encoding performance on systems with Intel graphics.
log_message "Installing Intel Hardware Accelerated Codecs..."
dnf -y install intel-media-driver > /dev/null 2>&1

# Install virtualization tools to enable virtual machines and containerization
log_message "Installing virtualization tools..."
dnf install -y @virtualization > /dev/null 2>&1


# App Installation
# Install essential applications
log_message "Installing essential applications..."
dnf install -y fastfetch git wget curl gnome-tweaks > /dev/null 2>&1
log_message "Essential applications installed successfully."

# Install Internet & Communication applications
log_message "Installing Google Chrome..."
flatpak install -y flathub com.google.Chrome > /dev/null 2>&1
log_message "Google Chrome installed successfully."
log_message "Installing Brave..."
flatpak install -y flathub com.brave.Browser > /dev/null 2>&1
log_message "Brave installed successfully."

# Install Office Productivity applications
log_message "Installing OnlyOffice..."
flatpak install -y flathub org.onlyoffice.desktopeditors > /dev/null 2>&1
log_message "OnlyOffice installed successfully."
log_message "Installing Logseq..."
flatpak install -y flathub com.logseq.Logseq > /dev/null 2>&1
log_message "Logseq installed successfully."

# Install Coding and DevOps applications
log_message "Installing VSCodium..."
rpmkeys --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg > /dev/null 2>&1
printf "[gitlab.com_paulcarroty_vscodium_repo]
name=download.vscodium.com
baseurl=https://download.vscodium.com/rpms/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
metadata_expire=1h" | sudo tee -a /etc/yum.repos.d/vscodium.repo
dnf install -y codium > /dev/null 2>&1
log_message "VSCodium installed successfully."

# Install Media & Graphics applications
log_message "Installing Spotify..."
flatpak install -y flathub com.spotify.Client > /dev/null 2>&1
log_message "Spotify installed successfully."

# Install Gaming & Emulation applications
log_message "Installing Steam..."
flatpak install -y flathub com.valvesoftware.Steam > /dev/null 2>&1
log_message "Steam installed successfully."
log_message "Installing Heroic Games Launcher..."
flatpak install -y flathub com.heroicgameslauncher.hgl > /dev/null 2>&1
log_message "Heroic Games Launcher installed successfully."

# Install Remote Networking applications
log_message "Installing Proton VPN..."
flatpak install -y flathub com.protonvpn.www > /dev/null 2>&1
log_message "Proton VPN installed successfully."

# Install System Tools applications
log_message "Installing Flatseal..."
flatpak install -y flathub com.github.tchx84.Flatseal > /dev/null 2>&1
log_message "Flatseal installed successfully."


# Customization
# Install Microsoft Windows fonts (core)
log_message "Installing Microsoft Fonts (core)..."
dnf install -y curl cabextract xorg-x11-font-utils fontconfig > /dev/null 2>&1
rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm > /dev/null 2>&1
log_message "Microsoft Fonts (core) installed successfully."

# Install Google fonts collection
log_message "Installing Google Fonts..."
wget -O /tmp/google-fonts.zip https://github.com/google/fonts/archive/main.zip > /dev/null 2>&1
mkdir -p $ACTUAL_HOME/.local/share/fonts/google > /dev/null 2>&1
unzip /tmp/google-fonts.zip -d $ACTUAL_HOME/.local/share/fonts/google > /dev/null 2>&1
rm -f /tmp/google-fonts.zip > /dev/null 2>&1
fc-cache -fv > /dev/null 2>&1
log_message "Google Fonts installed successfully."


# Custom user-defined commands
# Custom user-defined commands
echo "Created with ❤️ for Open Source"


# Finish
echo "";
echo "╔═════════════════════════════════════════════════════════════════════════╗";
echo "║                                                                         ║";
echo "║   ░█░█░█▀▀░█░░░█▀▀░█▀█░█▄█░█▀▀░░░▀█▀░█▀█░░░█▀▀░█▀▀░█▀▄░█▀█░█▀▄░█▀█░█░   ║";
echo "║   ░█▄█░█▀▀░█░░░█░░░█░█░█░█░█▀▀░░░░█░░█░█░░░█▀▀░█▀▀░█░█░█░█░█▀▄░█▀█░▀░   ║";
echo "║   ░▀░▀░▀▀▀░▀▀▀░▀▀▀░▀▀▀░▀░▀░▀▀▀░░░░▀░░▀▀▀░░░▀░░░▀▀▀░▀▀░░▀▀▀░▀░▀░▀░▀░▀░   ║";
echo "║                                                                         ║";
echo "╚═════════════════════════════════════════════════════════════════════════╝";
echo "";
log_message "All steps completed. Enjoy!"

# Prompt for reboot
prompt_reboot
