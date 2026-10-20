#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
GRPC_DIR="$SCRIPT_DIR/grpc"
source "$GRPC_DIR/system.sh"
source "$GRPC_DIR/users.sh"
source "$GRPC_DIR/auth.sh"
source "$GRPC_DIR/generate_api_token.sh"

# gRPC server address (can be overridden via environment variable, e.g., GRPC_ADDR=localhost:50051 ./grpc.sh grpc_greet)
GRPC_ADDR="${GRPC_ADDR:-localhost:50051}"
DEFAULT_EMAIL="test@testmail.com"
DEFAULT_USERNAME="test"
DEFAULT_PASSWORD=testtest
DEFAULT_ID=0

# Requires grpcurl (https://github.com/fullstorydev/grpcurl) on PATH.
if ! command -v grpcurl > /dev/null 2>&1; then
    echo "Error: grpcurl is not installed or not on PATH."
    echo "Install it from https://github.com/fullstorydev/grpcurl"
    exit 1
fi

# Dispatcher to handle command line arguments
if [ $# -eq 0 ]; then
    echo "Usage: $0 {get_greet|get_health_report|get_user_by_id|get_search_user_by_email|get_search_user_by_username|post_register|post_login|post_generate_api_token} [arguments...]"
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
