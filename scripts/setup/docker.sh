#!/usr/bin/env bash

# ==============================================================================
# Docker
# ==============================================================================

ensure_docker_installed() {
    if cmd_exists docker; then
        echo "✔ Docker is installed."
        return 0
    fi

    echo "❌ Docker is not installed."
    echo ""
    echo "Run setup again to install system dependencies."

    return 1
}

ensure_docker_service() {
    ensure_docker_installed

    if docker info >/dev/null 2>&1; then
        echo "✔ Docker daemon is running."
        return 0
    fi

    echo "⚠ Docker is installed but the daemon is not running."

    if cmd_exists systemctl; then
        echo "🚀 Attempting to start Docker..."

        if run_as_root systemctl enable --now docker; then
            if docker info >/dev/null 2>&1; then
                echo "✔ Docker daemon started."
                return 0
            fi
        fi
    fi

    run_as_root usermod -aG docker $USER
    echo ""
    echo "❌ Docker daemon could not be started."
    echo ""
    echo "Please start Docker manually and run setup again."
    echo "Or if the Docker was just installed by the setup, then please restart your system to let the group appending take place."

    return 1
}

ensure_docker_compose() {
    if docker compose version >/dev/null 2>&1; then
        echo "✔ Docker Compose is available."
        return 0
    fi

    echo "❌ Docker Compose is not available."
    echo ""
    echo "Expected command:"
    echo "  docker compose version"
    echo ""
    echo "Please install the Docker Compose plugin for your distribution."

    return 1
}

ensure_docker_user_access() {
    # Docker already works without sudo.
    if docker info >/dev/null 2>&1; then
        echo "✔ Current user can access Docker."
        return 0
    fi

    if ! getent group docker >/dev/null 2>&1; then
        echo "⚠ Docker group does not exist."
        return 0
    fi

    if id -nG "$USER" | tr ' ' '\n' | grep -qx "docker"; then
        echo "❌ Docker is still inaccessible even though $USER belongs to the docker group."
        echo ""
        echo "A new login session may be required."
        echo "Please log out and back in, then run:"
        echo ""
        echo "  ./ironbook setup"

        return 1
    fi

    echo "👤 Adding $USER to the docker group..."

    run_as_root usermod -aG docker "$USER"

    echo ""
    echo "✔ Added $USER to the docker group."
    echo ""
    echo "⚠ A new login session is required before Docker can be used."
    echo "  Please log out and back in, then run:"
    echo ""
    echo "    ./ironbook setup"
    echo ""

    # This is a successful setup step, but the current shell cannot
    # acquire the new group membership. Tell the caller to stop.
    return 2
}

# Starts all Docker Compose services and stops them again, so that their
# images are downloaded (and built) and the services are fully initialized.
setup_docker_services() {
    local compose_dir="$ROOT_DIR/infra/docker/compose"

    echo "🐳 Starting all Docker Compose services..."
    echo "   (this downloads and builds the service images)"

    if ! (cd "$compose_dir" && docker compose -f compose.yaml up -d); then
        echo "❌ Failed to start the Docker Compose services."
        return 1
    fi

    echo "✔ All Docker Compose services started."

    echo ""
    echo "🛑 Stopping the Docker Compose services..."

    if ! (cd "$compose_dir" && docker compose -f compose.yaml down); then
        echo "⚠ Could not stop the Docker Compose services."
        echo ""
        echo "Stop them manually with:"
        echo "  docker compose -f $compose_dir/compose.yaml down"
        return 1
    fi

    echo "✔ All Docker Compose services stopped."
    return 0
}

setup_docker() {
    ensure_docker_service
    ensure_docker_compose

    if ensure_docker_user_access; then
        setup_docker_services
        return $?
    fi

    local status=$?

    if [[ "$status" -eq 2 ]]; then
        # Docker group membership has just been changed. This is not
        # an installation failure, but setup cannot continue safely.
        return 0
    fi

    return "$status"
}
