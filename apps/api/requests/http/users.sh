get_user_by_id() {
    id="${1:-$DEFAULT_ID}"
    to_get="${BASE_URL}/users/${id}"
    echo "GET ${to_get}"
    curl -s -X GET $to_get
    echo ""
}

get_search_user_by_email() {
    email="${1:-$DEFAULT_EMAIL}"
    to_get="${BASE_URL}/users/search?email=${email}"
    echo "GET ${to_get}"
    curl -s -X GET $to_get
    echo ""
}

get_search_user_by_username() {
    username="${1:-$DEFAULT_USERNAME}"
    to_get="${BASE_URL}/users/search?username=${username}"
    echo "GET ${to_get}"
    curl -s -X GET $to_get
    echo ""
}
