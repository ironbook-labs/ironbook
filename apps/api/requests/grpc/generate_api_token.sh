grpc_generate_api_token() {
    local api_token="${1:-}"
    local name="${2:-FIRST}"
    local owner_email="${3:-$DEFAULT_EMAIL}"

    echo "gRPC ${GRPC_ADDR} system.SystemService/GenerateApiToken"
    grpcurl -plaintext -d "{
        \"name\": \"${name}\",
        \"owner_email\": \"${owner_email}\",
        \"api_token\": \"${api_token}\"
    }" "${GRPC_ADDR}" system.SystemService/GenerateApiToken
    echo ""
}
