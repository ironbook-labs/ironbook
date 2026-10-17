get_health() {
    to_get="${BASE_URL}/health"
    echo "GET ${to_get}"
    curl -s -X GET $to_get
    echo ""
}
