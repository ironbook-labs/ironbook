post_generate_api_token() {
    local auth_token="${1:-}"
    local name="${2:-FIRST}"
    local owner_email="${3:-$DEFAULT_EMAIL}"
    local to_post="${BASE_URL}/generate_api_token"

    echo "POST ${to_post}"
    curl -s -X POST "${to_post}" \
        -H "Content-Type: application/json" \
        -H "Authorization: ${auth_token}" \
        -d "{
            \"name\": \"${name}\",
            \"owner_email\": \"${owner_email}\"
        }"
    echo ""
}
