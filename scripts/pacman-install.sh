#!/bin/bash
PACKAGES=(
    # Bootloader, fs, and greeter
    grub
    grub-btrfs
    timeshift
    efibootmgr
    btrfs-progs
    exfatprogs
    ly
    lvm2
    memtest86+
    memtest86+-efi
    plymouth

    # Kernel and arch
    pacman-contrib
    archlinux-contrib
    archlinux-xdg-menu
    linux
    linux-firmware
    linux-headers
    dkms

    # Applications
    firefox
    discord
    code
    gimp
    dolphin
    lmms
    prismlauncher
    gnome-disk-utility
    gnome-settings-daemon
    imv
    mpv
    kde-cli-tools
    obs-studio
    qbittorrent
    vlc
    vlc-plugins-all
    libreoffice-still

    # Programming
    npm
    nodejs-lts-jod
    git
    base
    base-devel
    meson
    ninja

    # Docker
    docker
    docker-compose
    nvidia-container-toolkit

    # Audio
    pipewire
    pipewire-alsa
    pipewire-jack
    pipewire-pulse
    gst-plugin-pipewire
    libpulse
    wireplumber

    # Hyprland-economy
    hyprgraphics
    hyprland
    hyprlang
    hyprlock
    hyprpicker
    hyprsunset
    hyprutils
    nwg-dock-hyprland
    nwg-drawer

    # Multilingual support
    fcitx5
    fcitx5-chinese-addons
    fcitx5-configtool
    fcitx5-gtk
    fcitx5-mozc
    fcitx5-qt

    # Terminal utilities
    kitty
    fastfetch
    nano
    vi
    vim
    neovim
    bat
    btop
    cava
    cliphist
    ripgrep
    duf
    swaync
    fd
    fzf
    cmatrix
    grim
    ark
    brightnessctl
    imagemagick
    inotify-tools
    iotop
    jq
    libnotify
    lsd
    man-db
    ncdu
    pv
    slurp
    smartmontools
    unzip
    zip
    zoxide
    zsh
    yazi
    wget
    tmux
    tree
    thefuck
    the_silver_searcher

    # Themes
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

    # NVIDIA and 3d rendering
    glfw
    libva-nvidia-driver
    mesa-utils
    nvidia-open-dkms

    # LaTeX
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

    # X Server
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
    xdg-utils
    xorg-server
    xorg-xhost
    xorg-xinit

    # Network
    bluez
    bluez-utils
    dnsmasq
    iwd
    openssh
    strace
    syncthing
    tailscale
    socat
    network-manager-applet
    wireless_tools
    wpa_supplicant

    # Rice
    swww
    rofi
    rofi-emoji
    waybar

    # System Services
    cronie
    polkit-gnome
    power-profiles-daemon
    reflector
    uwsm
    zram-generator

    # Steam
    steam
)

AUR_PACKAGES=(
    clipse
    gslapper
    hyprwayland-scanner-git
    informant
    libwireplumber-4.0-compat
    localsend
    maplemono-nf-cn
    matugen-bin
    numix-circle-icon-theme-git
    numix-icon-theme-git
    protonup-qt
    pwvucontrol
    rofi-bluetooth-git
    wayfreeze-git
    wlogout
    python-pywalfox
)

AUR_HELPER=yay # or paru

# pacman
echo "Installing official Pacman packages..."
sudo pacman -Syu --needed --noconfirm "${PACKAGES[@]}"

# aur
if command -v "$AUR_HELPER" &> /dev/null; then
    echo "Installing AUR packages using ${AUR_HELPER}..."
    "$AUR_HELPER" -S --needed --noconfirm "${AUR_PACKAGES[@]}"
else
    echo "Warning: AUR helper '${AUR_HELPER}' not found. Skipping AUR installation."
fi

echo "Installation complete."