#!/usr/bin/env bash

cmd_help() {
    echo "Usage: ./ironbook.sh [command] [options]"
    echo ""
    echo "Commands:"
    echo "  get-tree                Generate directory structure."
    echo "  get-codebase            Generate the entire codebase in codebase.txt."
    echo "  update-version <ver>    Update project versions."
    echo "  build <ver> [options]   Build, package, and sign a release."
    echo "    --no-sign             Skip signing release files."
    echo "  help                    Show this help menu."
    echo "  setup [--minimal]       Sets up the project after being cloned."
    echo "    --minimal             Only the bare minimum: env files, system checks,"
    echo "                          and mise toolchains. Skips Docker, project"
    echo "                          dependencies, and git hooks."
}
