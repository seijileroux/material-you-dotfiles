#!/bin/bash
# ============================================
# Python Environment Management Tools
# ============================================

# Auto-activate base environment on terminal load
if [[ -f ~/PyEnv/base/bin/activate ]]; then
    source ~/PyEnv/base/bin/activate
fi

# Function to create a new Python environment
make_py_env() {
    if [[ -z "$1" ]]; then
        echo "Usage: make_py_env <envname> [python_version]"
        echo "Example: make_py_env myproject 3.11"
        return 1
    fi

    local envname="$1"
    local python_version="$2"
    local env_path="$HOME/PyEnv/$envname"

    if [[ -d "$env_path" ]]; then
        echo "Environment '$envname' already exists at $env_path"
        return 1
    fi

    # Determine Python executable
    local python_cmd="python3"
    if [[ -n "$python_version" ]]; then
        python_cmd="python$python_version"
        # Check if specified Python version is available
        if ! command -v "$python_cmd" &> /dev/null; then
            echo "Python $python_version is not installed or not found in PATH"
            echo "Available Python versions:"
            ls /usr/bin/python* 2>/dev/null | grep -E 'python[0-9]+\.[0-9]+$' | sort
            return 1
        fi
    fi

    echo "Creating Python environment: $envname (using $python_cmd)"
    "$python_cmd" -m venv "$env_path"

    if [[ $? -eq 0 ]]; then
        echo "Environment '$envname' created successfully at $env_path"
        echo "Python version: $("$python_cmd" --version)"
        echo "Use 'pyenv activate $envname' to activate it"
    else
        echo "Failed to create environment '$envname'"
        return 1
    fi
}

# Function to activate a Python environment
activate_py_env() {
    if [[ -z "$1" ]]; then
        echo "Usage: pyenv activate <envname>"
        return 1
    fi

    local envname="$1"
    local env_path="$HOME/PyEnv/$envname"
    local activate_script="$env_path/bin/activate"

    if [[ ! -f "$activate_script" ]]; then
        echo "Environment '$envname' not found at $env_path"
        echo "Available environments:"
        ls -1 ~/PyEnv/ 2>/dev/null || echo "No environments found"
        return 1
    fi

    # Deactivate current environment if one is active
    if [[ -n "$VIRTUAL_ENV" ]]; then
        deactivate
    fi

    echo "Activating environment: $envname"
    source "$activate_script"
}

# Function to switch back to base environment
base_py_env() {
    # Deactivate current environment if one is active
    if [[ -n "$VIRTUAL_ENV" ]]; then
        deactivate
    fi

    local base_env="$HOME/PyEnv/base/bin/activate"
    if [[ -f "$base_env" ]]; then
        echo "Switching to base environment"
        source "$base_env"
    else
        echo "Base environment not found. Run the setup script first."
        return 1
    fi
}

# Function to list all Python environments
list_py_envs() {
    echo "Available Python environments:"
    if [[ -d ~/PyEnv ]]; then
        ls -1 ~/PyEnv/
    else
        echo "No PyEnv directory found"
    fi
}

# Function to clone a Python environment
clone_py_env() {
    if [[ -z "$1" || -z "$2" ]]; then
        echo "Usage: pyenv clone <source_env> <target_env> [python_version]"
        echo "Example: pyenv clone myproject newproj 3.11"
        return 1
    fi

    local source_env="$1"
    local target_env="$2"
    local python_version="$3"
    local source_path="$HOME/PyEnv/$source_env"
    local target_path="$HOME/PyEnv/$target_env"

    # Check if source environment exists
    if [[ ! -d "$source_path" ]]; then
        echo "Source environment '$source_env' not found at $source_path"
        echo "Available environments:"
        ls -1 ~/PyEnv/ 2>/dev/null || echo "No environments found"
        return 1
    fi

    # Check if target environment already exists
    if [[ -d "$target_path" ]]; then
        echo "Target environment '$target_env' already exists at $target_path"
        return 1
    fi

    echo "Cloning environment '$source_env' to '$target_env'..."

    # Determine Python executable
    local python_cmd="python3"
    if [[ -n "$python_version" ]]; then
        python_cmd="python$python_version"
        # Check if specified Python version is available
        if ! command -v "$python_cmd" &> /dev/null; then
            echo "Python $python_version is not installed or not found in PATH"
            echo "Available Python versions:"
            ls /usr/bin/python* 2>/dev/null | grep -E 'python[0-9]+\.[0-9]+$' | sort
            return 1
        fi
        echo "Creating clone with Python $python_version"
    fi

    # Create new environment
    "$python_cmd" -m venv "$target_path"

    if [[ $? -ne 0 ]]; then
        echo "Failed to create target environment"
        return 1
    fi

    # Get list of packages from source environment
    local source_pip="$source_path/bin/pip"
    local target_pip="$target_path/bin/pip"

    if [[ -f "$source_pip" ]]; then
        echo "Copying packages from '$source_env' to '$target_env'..."

        # Generate requirements from source
        local temp_req=$(mktemp)
        "$source_pip" freeze > "$temp_req"

        # Install packages in target
        "$target_pip" install -r "$temp_req"

        # Clean up temp file
        rm "$temp_req"

        if [[ $? -eq 0 ]]; then
            echo "Environment '$target_env' cloned successfully from '$source_env'"
            echo "Python version: $("$target_path/bin/python" --version)"
            echo "Use 'pyenv activate $target_env' to activate it"
        else
            echo "Environment created but some packages may have failed to install"
        fi
    else
        echo "Warning: Could not find pip in source environment"
        echo "Empty environment '$target_env' created"
    fi
}

# Function to delete a Python environment
delete_py_env() {
    if [[ -z "$1" ]]; then
        echo "Usage: pyenv delete <envname>"
        return 1
    fi

    local envname="$1"
    local env_path="$HOME/PyEnv/$envname"

    # Prevent deletion of base environment
    if [[ "$envname" == "base" ]]; then
        echo "Cannot delete the base environment!"
        return 1
    fi

    if [[ ! -d "$env_path" ]]; then
        echo "Environment '$envname' not found at $env_path"
        return 1
    fi

    # Check if trying to delete currently active environment
    if [[ -n "$VIRTUAL_ENV" && "$VIRTUAL_ENV" == "$env_path" ]]; then
        echo "Cannot delete currently active environment. Switch to another environment first."
        echo "Use 'pyenv base' to switch to base environment."
        return 1
    fi

    echo "Are you sure you want to delete environment '$envname'? (y/N)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        rm -rf "$env_path"
        echo "Environment '$envname' deleted successfully"
    else
        echo "Deletion cancelled"
    fi
}

# Function to show help/usage information
help_py_env() {
    echo "============================================"
    echo "Python Environment Management - Help"
    echo "============================================"
    echo ""
    echo "Available commands:"
    echo "  pyenv create <name> [version]   - Create new Python environment"
    echo "  pyenv activate <name>           - Activate specified environment"
    echo "  pyenv base                      - Switch to base environment"
    echo "  pyenv clone <src> <dst> [ver]   - Clone source env to target"
    echo "  pyenv delete <name>             - Delete specified environment"
    echo "  pyenv list                      - List all environments"
    echo "  pyenv help                      - Show this help message"
    echo ""
    echo "Examples:"
    echo "  pyenv create myproject          # Create with default Python"
    echo "  pyenv create myproject 3.11     # Create with Python 3.11"
    echo "  pyenv activate myproject        # Activate environment"
    echo "  pyenv base                      # Switch to base environment"
    echo "  pyenv clone myproject newproj   # Clone environment"
    echo "  pyenv delete myproject          # Delete environment"
    echo "  pyenv list                      # List all environments"
    echo ""
    echo "Python Version Support:"
    echo "- If no version specified, uses default Python 3"
    echo "- Version format: '3.11', '3.9', '3.12', etc."
    echo "- Must have the specified Python version installed"
    echo ""
    echo "Notes:"
    echo "- Base environment auto-activates on terminal startup"
    echo "- Cannot delete the base environment"
    echo "- Cannot delete currently active environment"
    echo "- All environments are stored in ~/PyEnv/"
}

# Main pyenv command router
pyenv() {
    local cmd="$1"
    shift

    case "$cmd" in
        create)
            make_py_env "$@"
            ;;
        activate)
            activate_py_env "$@"
            ;;
        base)
            base_py_env
            ;;
        clone)
            clone_py_env "$@"
            ;;
        delete)
            delete_py_env "$@"
            ;;
        list)
            list_py_envs
            ;;
        help|--help|-h)
            help_py_env
            ;;
        *)
            echo "Unknown command: $cmd"
            echo "Run 'pyenv help' for usage information"
            return 1
            ;;
    esac
}
