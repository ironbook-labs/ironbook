post_register() {
    local api_token="${1:-}"
    local email="${2:-$DEFAULT_EMAIL}"
    local username="${3:-$DEFAULT_USERNAME}"
    local password="${4:-$DEFAULT_PASSWORD}"

    echo "gRPC ${GRPC_ADDR} auth.AuthService/Register"
    grpcurl -plaintext -d "{
        \"email\": \"${email}\",
        \"username\": \"${username}\",
        \"password\": \"${password}\",
        \"api_token\": \"${api_token}\"
    }" "${GRPC_ADDR}" auth.AuthService/Register
    echo ""
}

post_login() {
    local api_token="${1:-}"
    local email="${2:-$DEFAULT_EMAIL}"
    local password="${4:-$DEFAULT_PASSWORD}"

    echo "gRPC ${GRPC_ADDR} auth.AuthService/Login"
    grpcurl -plaintext -d "{
        \"email\": \"${email}\",
        \"password\": \"${password}\",
        \"api_token\": \"${api_token}\"
    }" "${GRPC_ADDR}" auth.AuthService/Login
    echo ""
}
