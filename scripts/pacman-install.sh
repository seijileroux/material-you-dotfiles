#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper function for y/n prompts (Enter defaults to yes)
ask_yes_no() {
    local prompt="$1"
    local response
    read -r -p "$(echo -e "${BLUE}${prompt} [Y/n]:${NC} ")" response
    response=${response,,} # tolower
    if [[ -z "$response" ]] || [[ "$response" =~ ^(y|yes)$ ]]; then
        return 0 # yes
    else
        return 1 # no
    fi
}

# Helper function for selecting AUR helper
select_aur_helper() {
    echo -e "${BLUE}Select AUR helper:${NC}"
    echo "  1) yay"
    echo "  2) paru"
    read -r -p "$(echo -e "${BLUE}Enter choice [1/2] (default: 1):${NC} ")" choice

    case "$choice" in
        2)
            AUR_HELPER="paru"
            ;;
        *)
            AUR_HELPER="yay"
            ;;
    esac

    # Check if the selected AUR helper is installed
    if ! command -v "$AUR_HELPER" &> /dev/null; then
        echo -e "${RED}Error: $AUR_HELPER is not installed. Please install it first.${NC}"
        exit 1
    fi

    echo -e "${GREEN}Using $AUR_HELPER as AUR helper${NC}"
}

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Arch Linux Package Installation Script  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Ask what to install
INSTALL_SYSTEM=false
INSTALL_APPLICATIONS=false
INSTALL_RICE=false

if ask_yes_no "Install SYSTEM packages? (kernel, bootloader, drivers, base system)"; then
    INSTALL_SYSTEM=true
fi

if ask_yes_no "Install APPLICATION packages? (Firefox, VSCode, GIMP, LaTeX, etc.)"; then
    INSTALL_APPLICATIONS=true
fi

if ask_yes_no "Install RICE packages? (Hyprland, Waybar, themes, terminal tools)"; then
    INSTALL_RICE=true
fi

# Check if at least one category is selected
if [ "$INSTALL_SYSTEM" = false ] && [ "$INSTALL_APPLICATIONS" = false ] && [ "$INSTALL_RICE" = false ]; then
    echo -e "${YELLOW}No package categories selected. Exiting.${NC}"
    exit 0
fi

# Ask about AUR packages
INSTALL_AUR=false
if ask_yes_no "Install AUR packages?"; then
    INSTALL_AUR=true
    select_aur_helper

    # Ask about AUR categories
    INSTALL_AUR_SYSTEM=false
    INSTALL_AUR_RICE=false
    INSTALL_AUR_APPS=false

    if ask_yes_no "  Install IMPORTANT AUR packages? (informant, hyprwayland-scanner, clipse, etc.)"; then
        INSTALL_AUR_SYSTEM=true
    fi

    if ask_yes_no "  Install RICE AUR packages? (icons, wlogout, wayfreeze, etc.)"; then
        INSTALL_AUR_RICE=true
    fi

    if ask_yes_no "  Install APPLICATION AUR packages? (vesktop, feishin, localsend, pinta)"; then
        INSTALL_AUR_APPS=true
    fi
fi

echo ""
echo -e "${GREEN}Starting installation...${NC}"
echo ""

# ==================== PACKAGE DEFINITIONS ====================

SYSTEM_PACKAGES=(
    # Bootloader and filesystem
    grub
    grub-btrfs
    efibootmgr
    btrfs-progs
    exfatprogs
    lvm2
    memtest86+
    memtest86+-efi
    plymouth
    timeshift

    # Kernel and base system
    base
    base-devel
    linux
    linux-firmware
    linux-headers
    dkms
    amd-ucode

    # Package management
    pacman-contrib
    archlinux-contrib
    archlinux-xdg-menu
    reflector

    # Display manager
    ly

    # Audio system
    pipewire
    pipewire-alsa
    pipewire-jack
    pipewire-pulse
    gst-plugin-pipewire
    libpulse
    wireplumber

    # Network essentials
    bluez
    bluez-utils
    dnsmasq
    iwd
    openssh
    network-manager-applet
    wireless_tools
    wpa_supplicant

    # System utilities
    cronie
    man-db
    polkit-gnome
    power-profiles-daemon
    smartmontools
    uwsm
    zram-generator

    # X11/Wayland essentials
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
    xdg-utils
    xorg-server
    xorg-xhost
    xorg-xinit
)

APPLICATION_PACKAGES=(
    # Web browser
    firefox

    # Development
    code
    git
    npm
    nodejs-lts-jod
    meson
    ninja
    luarocks

    # Container platform
    docker
    docker-compose

    # Creative applications
    gimp
    kdenlive
    lmms
    obs-studio

    # Media players and viewers
    mpv
    vlc
    vlc-plugins-all
    imv
    zathura
    zathura-pdf-mupdf

    # File management
    dolphin
    ark
    gnome-disk-utility

    # Office suite
    libreoffice-still

    # Utilities
    calcurse
    gnome-settings-daemon
    kde-cli-tools
    prismlauncher
    qbittorrent
    syncthing
    tailscale

    # LaTeX (full installation)
    texlive-basic
    texlive-bibtexextra
    texlive-binextra
    texlive-context
    texlive-fontsextra
    texlive-fontsrecommended
    texlive-fontutils
    texlive-formatsextra
    texlive-games
    texlive-humanities
    texlive-latex
    texlive-latexextra
    texlive-latexrecommended
    texlive-luatex
    texlive-mathscience
    texlive-metapost
    texlive-music
    texlive-pictures
    texlive-plaingeneric
    texlive-pstricks
    texlive-publishers
    texlive-xetex
)

RICE_PACKAGES=(
    # Hyprland ecosystem
    hyprland
    hyprgraphics
    hyprlang
    hyprlock
    hyprpicker
    hyprsunset
    hyprutils
    nwg-dock-hyprland
    nwg-drawer

    # Wayland utilities
    grim
    slurp
    swww
    satty
    wtype

    # Notification and system bars
    swaync
    waybar

    # Application launchers and menus
    rofi
    rofi-calc
    rofi-emoji

    # Terminal emulator
    kitty

    # Shell and terminal utilities
    zsh
    tmux
    bat
    btop
    cava
    cliphist
    cowsay
    cmatrix
    duf
    fastfetch
    fd
    figlet
    fzf
    htop
    iotop
    jq
    lolcat
    lsd
    nano
    ncdu
    neovim
    pv
    the_silver_searcher
    thefuck
    tree
    vi
    vim
    yazi
    zoxide

    # System tools for rice
    brightnessctl
    imagemagick
    inotify-tools
    libnotify
    socat
    strace
    unzip
    unrar
    wget
    zip

    # Themes and appearance
    adw-gtk-theme
    gtk3-demos
    gtk4-demos
    qt5-wayland
    qt5ct
    qt6-wayland
    qt6ct
    xsettingsd

    # Fonts
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    noto-fonts-extra
    ttf-jetbrains-mono-nerd

    # Input methods (for multilingual support)
    fcitx5
    fcitx5-chinese-addons
    fcitx5-configtool
    fcitx5-gtk
    fcitx5-mozc
    fcitx5-qt

    # Graphics libraries
    glfw
    mesa-utils
)

# AUR package categories
AUR_SYSTEM_PACKAGES=(
    # Important system utilities
    informant
    hyprwayland-scanner-git
    clipse
    libwireplumber-4.0-compat
    pwvucontrol
)

AUR_RICE_PACKAGES=(
    # Rice-related packages
    clipse-gui
    gslapper
    numix-circle-icon-theme-git
    numix-icon-theme-git
    wayfreeze-git
    wlogout
    matugen-bin
    maplemono-nf-cn
)

AUR_APP_PACKAGES=(
    # Applications
    vencord
    vesktop
    feishin
    localsend
    pinta
)

# ==================== INSTALLATION ====================

# Build the final package list
FINAL_PACKAGES=()

if [ "$INSTALL_SYSTEM" = true ]; then
    echo -e "${BLUE}[+] Including SYSTEM packages...${NC}"
    FINAL_PACKAGES+=("${SYSTEM_PACKAGES[@]}")
fi

if [ "$INSTALL_APPLICATIONS" = true ]; then
    echo -e "${BLUE}[+] Including APPLICATION packages...${NC}"
    FINAL_PACKAGES+=("${APPLICATION_PACKAGES[@]}")
fi

if [ "$INSTALL_RICE" = true ]; then
    echo -e "${BLUE}[+] Including RICE packages...${NC}"
    FINAL_PACKAGES+=("${RICE_PACKAGES[@]}")
fi

# Install official packages
if [ ${#FINAL_PACKAGES[@]} -gt 0 ]; then
    echo ""
    echo -e "${GREEN}Installing ${#FINAL_PACKAGES[@]} official packages...${NC}"
    sudo pacman -Syu --needed --noconfirm "${FINAL_PACKAGES[@]}"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Official packages installed successfully${NC}"
    else
        echo -e "${RED}✗ Some packages failed to install${NC}"
    fi
else
    echo -e "${YELLOW}No official packages selected.${NC}"
fi

# Install AUR packages
if [ "$INSTALL_AUR" = true ]; then
    AUR_FINAL_PACKAGES=()

    if [ "$INSTALL_AUR_SYSTEM" = true ]; then
        echo -e "${BLUE}[+] Including IMPORTANT AUR packages...${NC}"
        AUR_FINAL_PACKAGES+=("${AUR_SYSTEM_PACKAGES[@]}")
    fi

    if [ "$INSTALL_AUR_RICE" = true ]; then
        echo -e "${BLUE}[+] Including RICE AUR packages...${NC}"
        AUR_FINAL_PACKAGES+=("${AUR_RICE_PACKAGES[@]}")
    fi

    if [ "$INSTALL_AUR_APPS" = true ]; then
        echo -e "${BLUE}[+] Including APPLICATION AUR packages...${NC}"
        AUR_FINAL_PACKAGES+=("${AUR_APP_PACKAGES[@]}")
    fi

    if [ ${#AUR_FINAL_PACKAGES[@]} -gt 0 ]; then
        echo ""
        echo -e "${GREEN}Installing ${#AUR_FINAL_PACKAGES[@]} AUR packages using $AUR_HELPER...${NC}"
        "$AUR_HELPER" -S --needed --noconfirm "${AUR_FINAL_PACKAGES[@]}"

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ AUR packages installed successfully${NC}"
        else
            echo -e "${RED}✗ Some AUR packages failed to install${NC}"
        fi
    else
        echo -e "${YELLOW}No AUR packages selected.${NC}"
    fi
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║        Installation Complete!              ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
