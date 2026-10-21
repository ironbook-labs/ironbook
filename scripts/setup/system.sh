#!/usr/bin/env bash

# ==============================================================================
# Linux Distribution
# ==============================================================================

get_linux_distro() {
    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release
        echo "${ID:-unknown}"
        return
    fi

    if command -v lsb_release >/dev/null 2>&1; then
        lsb_release -si | tr '[:upper:]' '[:lower:]'
        return
    fi

    echo "unknown"
}

DISTRO="$(get_linux_distro)"

# ==============================================================================
# System Package Installation
# ==============================================================================

install_system_packages() {
    case "$DISTRO" in
        arch|cachyos|manjaro)
            echo "📦 Installing system dependencies with pacman..."

            local packages=()

            if [ "$NO_MINGW" -eq 0 ]; then
                if ! cmd_exists x86_64-w64-mingw32-gcc; then
                    packages+=(mingw-w64-gcc)
                fi
            fi

            if [ "$NO_DOCKER" -eq 0 ]; then
                if ! cmd_exists docker; then
                    packages+=(docker)
                fi

                if ! docker compose version >/dev/null 2>&1; then
                    packages+=(docker-compose)
                fi
            fi

            if [ "$NO_CURL" -eq 0 ]; then
                if ! cmd_exists curl; then
                    packages+=(curl)
                fi
            fi

            if [ "$NO_GIT" -eq 0 ]; then
                if ! cmd_exists git; then
                    packages+=(git)
                fi
            fi

            if [[ "${#packages[@]}" -gt 0 ]]; then
                run_as_root pacman -S --needed --noconfirm "${packages[@]}"
            fi
            ;;

        ubuntu|linuxmint|pop|debian)
            echo "📦 Installing system dependencies with apt..."

            run_as_root apt-get update

            local packages=()

            if [ "$NO_MINGW" -eq 0 ]; then
                if ! cmd_exists x86_64-w64-mingw32-gcc; then
                    packages+=(gcc-mingw-w64-x86-64)
                fi
            fi

            if [ "$NO_DOCKER" -eq 0 ]; then
                if ! cmd_exists docker; then
                    packages+=(docker.io)
                fi

                if ! docker compose version >/dev/null 2>&1; then
                    packages+=(docker-compose-v2)
                fi
            fi

            if [ "$NO_CURL" -eq 0 ]; then
                if ! cmd_exists curl; then
                    packages+=(curl)
                fi
            fi

            if [ "$NO_GIT" -eq 0 ]; then
                if ! cmd_exists git; then
                    packages+=(git)
                fi
            fi

            if [[ "${#packages[@]}" -gt 0 ]]; then
                run_as_root apt-get install -y "${packages[@]}"
            fi
            ;;

        fedora)
            echo "📦 Installing system dependencies with dnf..."

            local packages=()

            if [ "$NO_MINGW" -eq 0 ]; then
                if ! cmd_exists x86_64-w64-mingw32-gcc; then
                    packages+=(mingw64-gcc)
                fi
            fi

            if [ "$NO_DOCKER" -eq 0 ]; then
                if ! cmd_exists docker; then
                    packages+=(docker)
                fi

                if ! docker compose version >/dev/null 2>&1; then
                    packages+=(docker-compose)
                fi
            fi

            if [ "$NO_CURL" -eq 0 ]; then
                if ! cmd_exists curl; then
                    packages+=(curl)
                fi
            fi

            if [ "$NO_GIT" -eq 0 ]; then
                if ! cmd_exists git; then
                    packages+=(git)
                fi
            fi

            if [[ "${#packages[@]}" -gt 0 ]]; then
                run_as_root dnf install -y "${packages[@]}"
            fi
            ;;

        opensuse-tumbleweed|opensuse-leap)
            echo "📦 Installing system dependencies with zypper..."

            local packages=()

            if [ "$NO_MINGW" -eq 0 ]; then
                if ! cmd_exists x86_64-w64-mingw32-gcc; then
                    packages+=(mingw64-cross-gcc)
                fi
            fi

            if [ "$NO_DOCKER" -eq 0 ]; then
                if ! cmd_exists docker; then
                    packages+=(docker)
                fi

                if ! docker compose version >/dev/null 2>&1; then
                    packages+=(docker-compose)
                fi
            fi

            if [ "$NO_CURL" -eq 0 ]; then
                if ! cmd_exists curl; then
                    packages+=(curl)
                fi
            fi

            if [ "$NO_GIT" -eq 0 ]; then
                if ! cmd_exists git; then
                    packages+=(git)
                fi
            fi

            if [[ "${#packages[@]}" -gt 0 ]]; then
                run_as_root zypper install -y "${packages[@]}"
            fi
            ;;

        *)
            echo "❌ Unsupported Linux distribution: $DISTRO"
            echo ""
            echo "Please install these dependencies manually:"
            echo "  - MinGW-w64"
            echo "  - Docker"
            echo "  - Docker Compose"
            echo "  - curl"
            echo "  - git"
            exit 1
            ;;
    esac
}

# ==============================================================================
# System Dependency Verification
# ==============================================================================

check_system_commands() {
    local missing=0

    if [ "$NO_MINGW" -eq 0 ]; then
        if ! cmd_exists x86_64-w64-mingw32-gcc; then
            echo "❌ Required command not found: x86_64-w64-mingw32-gcc"
            missing=1
        fi
    else
        echo "Received --no-mingw, skipping checking for it."
    fi

    if [ "$NO_DOCKER" -eq 0 ]; then
        if ! cmd_exists docker; then
            echo "❌ Required command not found: docker"
            missing=1
        fi

        if ! docker compose version >/dev/null 2>&1; then
            echo "❌ Docker Compose is not available."
            missing=1
        fi
    else
        echo "Received --no-docker, skipping checking for it."
    fi

    if [ "$NO_CURL" -eq 0 ]; then
        if ! cmd_exists curl; then
            echo "❌ Required command not found: curl"
            missing=1
        fi
    else
        echo "Received --no-curl, skipping checking for it."
    fi

    if [ "$NO_GIT" -eq 0 ]; then
        if ! cmd_exists git; then
            echo "❌ Required command not found: git"
            missing=1
            fi
    else
        echo "Received --no-git, skipping checking for it."
    fi

    if [[ "$missing" -eq 1 ]]; then
        echo "⚠ Some system dependencies are missing."
        install_system_packages
    else
        echo "✔ System dependencies already installed."
    fi
}
