#!/usr/bin/env bash

cmd_exists() {
    local command="$1"

    if ! command -v "$command" >/dev/null 2>&1; then
        return 1
    fi
}

require_version() {
    local version="${1:-}"

    if [[ -z "$version" ]]; then
        echo "❌ Version is required."
        cmd_help
        return 1
    fi

    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+([.-][0-9A-Za-z.-]+)?$ ]]; then
        echo "❌ Invalid version: $version"
        echo "Expected something like: 0.1.0, 0.1.0-alpha, or 1.2.3-beta.1"
        return 1
    fi
}
