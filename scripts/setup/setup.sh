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
    elif command -v doas >/dev/null 2>&1; then
        doas "$@"
    else
        echo "❌ Need root privileges but neither running as root nor is 'sudo' available."
        exit 1
    fi
}

# ==============================================================================
# Main
# ==============================================================================

echo ""
echo "========================================"
echo " IronBook Development Environment Setup"
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

echo ""
echo "🐳 Checking Docker..."
setup_docker

echo ""
echo "🔧 Setting up mise..."
setup_mise

echo ""
run_project_setup

echo ""
setup_git_hooks

echo ""
echo "======================================================"
echo " 🎉 Setup complete!"
echo "======================================================"
echo ""
echo "Don't forget to copy your Android signing keystore to:"
echo ""
echo "  $ANDROID_DIR/ironbook.keystore"
echo ""
echo "This is required to create a signed Android release."
echo ""
