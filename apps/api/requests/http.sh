#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
HTTP_DIR="$SCRIPT_DIR/http"
source "$HTTP_DIR/system.sh"
source "$HTTP_DIR/users.sh"
source "$HTTP_DIR/auth.sh"
source "$HTTP_DIR/generate_api_token.sh"

# Base URL (can be overridden via environment variable, e.g., BASE_URL=http://api.example.com ./abc.sh root)
BASE_URL="${BASE_URL:-http://127.0.0.1:8000}"
DEFAULT_EMAIL="test@testmail.com"
DEFAULT_USERNAME="test"
DEFAULT_PASSWORD=testtest
DEFAULT_ID=0

get_root() {
    echo "GET ${BASE_URL}/"
    curl -s -X GET "${BASE_URL}/"
    echo ""
}

# Dispatcher to handle command line arguments
if [ $# -eq 0 ]; then
    echo "Usage: $0 {get_root|get_health|get_user_by_id|get_search_user_by_email|get_search_user_by_username|post_register|post_login|post_generate_api_token} [arguments...]"
    exit 1
fi

# Grab the first argument as the function name
ENDPOINT="$1"
shift # Remove the function name from the arguments list, leaving the rest

# Check if the provided function exists and run it with the remaining arguments
if declare -f "$ENDPOINT" > /dev/null; then
    "$ENDPOINT" "$@"
else
    echo "Error: Function '$ENDPOINT' does not exist."
    exit 1
fi
