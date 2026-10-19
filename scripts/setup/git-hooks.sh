#!/usr/bin/env bash

# ==============================================================================
# Git Hooks
# ==============================================================================

setup_git_hooks() {
    if ! cmd_exists mise exec -- pre-commit; then
        return 0
    fi

    echo "🔧 Installing pre-commit hooks..."
    mise exec -- pre-commit install

    # Warm up the hook environments now, so the first commit doesn't have to
    # download and set everything up.
    echo "🔧 Running pre-commit on all files..."
    if ! mise exec -- pre-commit run --all-files; then
        echo "❌ pre-commit run --all-files failed."
        return 1
    fi
}
