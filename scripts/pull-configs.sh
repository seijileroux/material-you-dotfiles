REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/src"
CONFIG_SOURCE="$HOME/.config"
CONFIG_TARGET="$REPO_DIR/.config"

RICE_CONFIGS=(
    # Main rice
    "hypr"
    "waybar"
    "dunst"
    "rofi"
    "wlogout"
    "nwg-dock-hyprland"

    # Theming
    "gtk-3.0"
    "gtk-4.0"
    "kdeglobals"
    "qt5ct"
    "qt6ct"
    "QtProject.conf"
    "matugen"
    "fontconfig"

    # Riced applications
    "GIMP/3.0/themes"
    "GIMP/3.0/theme.css"
    "fcitx5"
    "mozc"

    # File manager (Dolphin)
    "dolphinrc"
    "filetypesrc"
    "trashrc"
    "mimeapps.list"

    # Terminal
    "kitty"
    "fastfetch"
    "neofetch"
    "btop"
    "clipse"
)

for config in "${RICE_CONFIGS[@]}"; do
    if [ -e "$CONFIG_SOURCE/$config" ]; then
        if [ -d "$CONFIG_SOURCE/$config" ]; then
            mkdir -p "$CONFIG_TARGET/$config"
            rsync -a --delete "$CONFIG_SOURCE/$config/" "$CONFIG_TARGET/$config/" || {
                echo "  ✗ Failed to sync $config"
                continue
            }
        else
            cp "$CONFIG_SOURCE/$config" "$CONFIG_TARGET/$config" || {
                echo "  ✗ Failed to copy $config"
                continue
            }
        fi
        echo "  ✓ Copied $config"
        ((SYNCED_COUNT++))
    fi
done

echo "Part 2: Copying ~/.mozilla"
MOZILLA_SOURCE="$HOME/.mozilla"
MOZILLA_TARGET="$REPO_DIR/.mozilla"
RICE_CONFIGS=(
    "firefox/xvm2110c.default-release/chrome"
    "firefox/xvm2110c.default-release/user.js"
)
for config in "${RICE_CONFIGS[@]}"; do
    if [ -e "$MOZILLA_SOURCE/$config" ]; then
        if [ -d "$MOZILLA_SOURCE/$config" ]; then
            mkdir -p "$MOZILLA_TARGET/$config"
            rsync -a --delete "$MOZILLA_SOURCE/$config/" "$MOZILLA_TARGET/$config/" || {
                echo "  ✗ Failed to sync $config"
                continue
            }
        else
            cp "$MOZILLA_SOURCE/$config" "$MOZILLA_TARGET/$config" || {
                echo "  ✗ Failed to copy $config"
                continue
            }
        fi
        echo "  ✓ Copied $config"
        ((SYNCED_COUNT++))
    fi
done

echo "Part 3: Copying ~/.zshrc"
cp "$HOME/.zshrc" "$REPO_DIR/.zshrc"
cp -r "$HOME/Scripts" "$REPO_DIR/Scripts"