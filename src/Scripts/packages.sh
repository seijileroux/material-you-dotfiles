#!/bin/sh

# installer.sh
# A wrapper script that integrates fzf with pacman and an AUR helper (paru) 
# for fuzzy package search, installation, and removal.
#
# NEW SYNTAX:
#   Search Repo packages to install:    ./installer.sh install
#   Search AUR packages to install:     ./installer.sh install aur
#   Search All packages to install:     ./installer.sh install any
#   Search installed packages to remove: ./installer.sh uninstall

# --- Configuration ---
# Set your preferred AUR helper here (paru or yay)
AUR_HELPER="yay"

# --- Argument Parsing and Initialization ---

# Check for mode argument
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "Usage: $0 <MODE> [SOURCE]"
    echo ""
    echo "Installer mode examples (uses $AUR_HELPER for AUR operations):"
    echo "  $0 install           (Search Repo only)"
    echo "  $0 install aur       (Search AUR only)"
    echo "  $0 install any       (Search All (Repo + AUR))"
    echo ""
    echo "Uninstaller mode example:"
    echo "  $0 uninstall         (Search installed packages to remove)"
    exit 1
fi

MODE=$1
SOURCE_ARG=$2 # Can be empty, 'aur', or 'any'
SOURCE=""

# Determine the action mode and source
if [ "$MODE" = "install" ]; then
    if [ -z "$SOURCE_ARG" ]; then
        SOURCE="repo"
    elif [ "$SOURCE_ARG" = "aur" ] || [ "$SOURCE_ARG" = "any" ]; then
        SOURCE="$SOURCE_ARG"
    else
        echo "Error: Invalid source for install mode. Must be 'aur', 'any', or empty." >&2
        exit 1
    fi
elif [ "$MODE" = "uninstall" ]; then
    if [ -n "$SOURCE_ARG" ]; then
        echo "Error: Uninstall mode does not take a source argument." >&2
        exit 1
    fi
    SOURCE="installed"
else
    echo "Error: Invalid mode. Must be 'install' or 'uninstall'." >&2
    exit 1
fi


# --- Function to check required tools ---
check_dependencies() {
    if ! command -v fzf >/dev/null 2>&1; then
        echo "Error: fzf is required but not installed. Please install it." >&2
        exit 1
    fi

    # Check for AUR helper if AUR operation is requested
    if [ "$SOURCE" = "aur" ] || [ "$SOURCE" = "any" ]; then
        if ! command -v "$AUR_HELPER" >/dev/null 2>&1; then
            echo "Error: AUR operation requested, but '$AUR_HELPER' is not installed." >&2
            echo "Please install '$AUR_HELPER' or choose 'install' (Repo only)." >&2
            exit 1
        fi
    fi
}

check_dependencies

# --- Logic setup variables ---
PKG_LIST_COMMAND=""
EXEC_COMMAND=""
PREVIEW_COMMAND=""
PROMPT_TEXT=""

# --- Main Logic ---

if [ "$MODE" = "install" ]; then
    EXEC_COMMAND="sudo pacman -Syu" # Default to pacman, will be overwritten for AUR helper
    
    if [ "$SOURCE" = "repo" ]; then
        # pacman -Slq lists all repository packages (names only)
        PKG_LIST_COMMAND="pacman -Slq"
        PREVIEW_COMMAND="pacman -Si {1}"
        PROMPT_TEXT="[INSTALL - REPO ONLY] > "

    elif [ "$SOURCE" = "any" ]; then
        # AUR helper (paru/yay) lists packages from repos and AUR.
        PKG_LIST_COMMAND="$AUR_HELPER -Slq"
        EXEC_COMMAND="$AUR_HELPER -Syu"
        PREVIEW_COMMAND="$AUR_HELPER -Si {1}"
        PROMPT_TEXT="[INSTALL - REPO + AUR] > "

    elif [ "$SOURCE" = "aur" ]; then
        # To get a list of AUR packages only, we use the non-quiet list command 
        # and filter for the 'aur' pseudo-repository name.
        echo "Generating AUR-only list via $AUR_HELPER..."
        # List all, filter by repo name 'aur', and print package name ($2)
        PKG_LIST_COMMAND="$AUR_HELPER -Sl | awk '\$1 == \"aur\" {print \$2}'"
        EXEC_COMMAND="$AUR_HELPER -Syu"
        PREVIEW_COMMAND="$AUR_HELPER -Si {1}"
        PROMPT_TEXT="[INSTALL - AUR ONLY] > "
    fi
    
    # Execute the fuzzy search and installation
    eval "$PKG_LIST_COMMAND" | \
    fzf --multi \
        --border=rounded \
        --prompt="$PROMPT_TEXT" \
        --pointer="" \
        --marker="" \
        --preview "$PREVIEW_COMMAND" | \
    xargs -ro $EXEC_COMMAND

elif [ "$MODE" = "uninstall" ]; then
    # Search all currently installed packages (repo and AUR)
    PKG_LIST_COMMAND="pacman -Qq"
    EXEC_COMMAND="sudo pacman -Rns" # Remove package, dependencies, and unneeded config files
    PREVIEW_COMMAND="pacman -Qi {1}"
    PROMPT_TEXT="[REMOVE - INSTALLED] > "

    echo "Mode: UNINSTALL (Searching ALL installed packages)"
    echo "Select packages to REMOVE (pacman -Rns)..."

    $PKG_LIST_COMMAND | \
    fzf --multi \
        --border=rounded \
        --prompt="$PROMPT_TEXT" \
        --pointer="" \
        --marker="" \
        --preview "$PREVIEW_COMMAND" | \
    xargs -ro $EXEC_COMMAND
fi

echo "Operation complete."