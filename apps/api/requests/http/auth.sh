post_register() {
    local auth_token="${1:-}"
    local email="${2:-$DEFAULT_EMAIL}"
    local username="${3:-$DEFAULT_USERNAME}"
    local password="${4:-$DEFAULT_PASSWORD}"
    local to_post="${BASE_URL}/auth/register"

    echo "POST ${to_post}"
    curl -s -X POST "${to_post}" \
        -H "Content-Type: application/json" \
        -H "Authorization: ${auth_token}" \
        -d "{
            \"email\": \"${email}\",
            \"username\": \"${username}\",
            \"password\": \"${password}\"
        }"
    echo ""
}

post_login() {
    local auth_token="${1:-}"
    local email="${2:-$DEFAULT_EMAIL}"
    local password="${3:-$DEFAULT_PASSWORD}"
    local to_post="${BASE_URL}/auth/login"

    echo "POST ${to_post}"
    curl -s -X POST "${to_post}" \
        -H "Content-Type: application/json" \
        -H "Authorization: ${auth_token}" \
        -d "{
            \"email\": \"${email}\",
            \"password\": \"${password}\"
        }"
    echo ""
}
