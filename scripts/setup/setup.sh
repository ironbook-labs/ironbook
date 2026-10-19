#!/usr/bin/env bash

# ==============================================================================
# Environment
# ==============================================================================

# mise installs to ~/.local/bin by default.
export PATH="$HOME/.local/bin:$PATH"

# ==============================================================================
# Load setup modules
# ==============================================================================

# shellcheck source=/dev/null
source "$SCRIPTS_DIR/setup/environment.sh"

# shellcheck source=/dev/null
source "$SCRIPTS_DIR/setup/system.sh"

# shellcheck source=/dev/null
source "$SCRIPTS_DIR/setup/docker.sh"

# shellcheck source=/dev/null
source "$SCRIPTS_DIR/setup/mise.sh"

# shellcheck source=/dev/null
source "$SCRIPTS_DIR/setup/project.sh"

# shellcheck source=/dev/null
source "$SCRIPTS_DIR/setup/git-hooks.sh"

# ==============================================================================
# Helpers
# ==============================================================================

run_as_root() {
    if [[ $EUID -eq 0 ]]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        echo "❌ Need root privileges but neither running as root nor is 'sudo' available."
        exit 1
    fi
}

# ==============================================================================
# Options
# ==============================================================================

# --minimal: only do the bare minimum (environment files, system dependency
# checks, mise toolchains). Docker, project dependencies (`mise run setup`),
# and git hooks are skipped and get set up on demand instead (issue #199).
SETUP_MINIMAL=0

for setup_arg in "$@"; do
    case "$setup_arg" in
        --minimal)
            SETUP_MINIMAL=1
            ;;
        -h|--help)
            echo "Usage: ./ironbook.sh setup [--minimal]"
            echo ""
            echo "  --minimal   Only do the bare minimum: environment files,"
            echo "              system dependency checks, and mise toolchains."
            echo "              Skips Docker, project dependencies, and git hooks."
            exit 0
            ;;
        *)
            echo "❌ Unknown setup option: '$setup_arg'"
            echo "Run './ironbook.sh setup --help' for usage."
            exit 1
            ;;
    esac
done

# ==============================================================================
# Main
# ==============================================================================

echo ""
echo "========================================"
if [[ "$SETUP_MINIMAL" -eq 1 ]]; then
    echo " IronBook Minimal Environment Setup"
else
    echo " IronBook Development Environment Setup"
fi
echo "========================================"
echo ""

echo "🐧 Detected Linux distribution: $DISTRO"

if [[ "$DISTRO" == "nixos" ]]; then
    echo "❌ NixOS is not currently supported."
    exit 1
fi

setup_environment_files

echo ""
echo "🔍 Checking system dependencies..."
check_system_commands

if [[ "$SETUP_MINIMAL" -eq 0 ]]; then
    echo ""
    echo "🐳 Checking Docker..."
    setup_docker
fi

echo ""
echo "🔧 Setting up mise..."
setup_mise

if [[ "$SETUP_MINIMAL" -eq 0 ]]; then
    echo ""
    run_project_setup

    echo ""
    setup_git_hooks
fi

echo ""
echo "======================================================"
if [[ "$SETUP_MINIMAL" -eq 1 ]]; then
    echo " 🎉 Minimal setup complete!"
else
    echo " 🎉 Setup complete!"
fi
echo "======================================================"
echo ""

if [[ "$SETUP_MINIMAL" -eq 1 ]]; then
    echo "Skipped: Docker, project dependencies, and git hooks."
    echo "Run './ironbook.sh setup' (without --minimal) for the full setup."
    echo ""
else
    echo "Don't forget to copy your Android signing keystore to:"
    echo ""
    echo "  $ANDROID_DIR/ironbook.keystore"
    echo ""
    echo "This is required to create a signed Android release."
    echo ""
fi
