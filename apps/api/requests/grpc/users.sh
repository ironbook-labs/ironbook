grpc_get_user_by_id() {
    local id="${1:-$DEFAULT_ID}"

    echo "gRPC ${GRPC_ADDR} users.UsersService/GetById"
    grpcurl -plaintext -d "{\"id\": ${id}}" "${GRPC_ADDR}" users.UsersService/GetById
    echo ""
}

grpc_search_user_by_email() {
    local email="${1:-$DEFAULT_EMAIL}"

    echo "gRPC ${GRPC_ADDR} users.UsersService/Search (email)"
    grpcurl -plaintext -d "{\"email\": \"${email}\"}" "${GRPC_ADDR}" users.UsersService/Search
    echo ""
}

grpc_search_user_by_username() {
    local username="${1:-$DEFAULT_USERNAME}"

    echo "gRPC ${GRPC_ADDR} users.UsersService/Search (username)"
    grpcurl -plaintext -d "{\"username\": \"${username}\"}" "${GRPC_ADDR}" users.UsersService/Search
    echo ""
}
