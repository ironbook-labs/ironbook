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

# Default values of unpassed flags
NO_ENV_FILES=0
NO_SYSTEM_COMMANDS=0
NO_MINGW=0
NO_CURL=0
NO_GIT=0
NO_DOCKER=0
NO_DOCKER_SERVICES=0
NO_MISE=0
NO_MISE_INSTALL=0
NO_PROJECT_SETUP=0
NO_GIT_HOOKS=0
NO_PRE_COMMIT_TEST=0

# Parse the flags
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --no-env-files)
            NO_ENV_FILES=1
            ;;
        --no-system-commands)
            NO_SYSTEM_COMMANDS=1
            NO_MINGW=1
            NO_CURL=1
            NO_GIT=1
            NO_DOCKER=1
            NO_DOCKER_SERVICES=1
            ;;
        --no-mingw)
            NO_MINGW=1
            ;;
        --no-curl)
            NO_CURL=1
            ;;
        --no-git)
            NO_GIT=1
            ;;
        --no-docker)
            NO_DOCKER=1
            NO_DOCKER_SERVICES=1
            ;;
        --no-docker-services)
            NO_DOCKER_SERVICES=1
            ;;
        --no-mise)
            NO_MISE=1
            NO_MISE_INSTALL=1
            NO_PROJECT_SETUP=1
            NO_GIT_HOOKS=1
            NO_GIT_HOOKS_TEST=1
            ;;
        --no-mise-install)
            NO_MISE_INSTALL=1
            NO_GIT_HOOKS=1
            ;;
        --no-project-setup)
            NO_PROJECT_SETUP=1
            NO_GIT_HOOKS_TEST=1
            ;;
        --no-git-hooks)
            NO_GIT_HOOKS=1
            ;;
        --no-pre-commit-test)
            NO_PRE_COMMIT_TEST=1
            ;;
        *)
            echo "Unknown option: $1"
            cmd_help
            exit 1
            ;;
    esac
    shift
done

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

if [ "$NO_ENV_FILES" -eq 0 ]; then
    setup_environment_files
else
    echo "Received --no-env-files, skipping ENV file creation."
fi

if [ "$NO_SYSTEM_COMMANDS" -eq 0 ]; then
    echo ""
    echo "🔍 Checking system dependencies..."
    check_system_commands
else
    echo "Received --no-system-commands, skipping checking for dependencies."
fi

if [ "$NO_DOCKER" -eq 0 ]; then
    echo ""
    echo "🐳 Checking Docker..."
    setup_docker
else
    echo "Received --no-docker, skipping it's setup."
fi

if [ "$NO_MISE" -eq 0 ]; then
    echo ""
    echo "🔧 Setting up mise..."
    setup_mise
else
    echo "Received --no-mise, skipping it's setup."
fi

if [ "$NO_PROJECT_SETUP" -eq 0 ]; then
    echo ""
    run_project_setup
else
    echo "Received --no-project-setup, skipping running the mise setup tasks for the sub projects."
fi

if [ "$NO_GIT_HOOKS" -eq 0 ]; then
    echo ""
    setup_git_hooks
else
    echo "Received --no-git-hooks, skipping setting up git hooks via pre-commit."
fi

if [ "$NO_PRE_COMMIT_TEST" -eq 0 ]; then
    echo ""
    echo "Running pre-commit tests."
    mise exec -- pre-commit run --hook-stage pre-push --all-files
else
    echo "Received --no-pre-commit-test, skipping testing git hooks via pre-commit."
fi

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
