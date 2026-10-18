grpc_greet() {
    echo "gRPC ${GRPC_ADDR} system.SystemService/Greet"
    grpcurl -plaintext "${GRPC_ADDR}" system.SystemService/Greet
    echo ""
}

grpc_health_report() {
    echo "gRPC ${GRPC_ADDR} system.SystemService/HealthReport"
    grpcurl -plaintext "${GRPC_ADDR}" system.SystemService/HealthReport
    echo ""
}
