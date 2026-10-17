use axum::body::to_bytes;
use axum::response::IntoResponse;
use ironbook_api::errors::AppError;
use serde_json::Value;
use tonic::Code;

#[test]
fn error_codes_are_stable() {
    let cases = [
        (AppError::InvalidApiToken, 1001),
        (AppError::UsernameAlreadyExists, 1002),
        (AppError::EmailAlreadyExists, 1003),
        (AppError::InvalidCredentials, 1004),
        (AppError::InvalidName, 1005),
        (AppError::InvalidOwnerEmail, 1006),
    ];

    for (error, expected) in cases {
        assert_eq!(error.code(), expected);
    }

    let db_error = AppError::DatabaseError(sqlx::Error::RowNotFound);
    assert_eq!(db_error.code(), 5000);

    let internal_error = AppError::Internal(anyhow::anyhow!("boom"));
    assert_eq!(internal_error.code(), 5001);
}

#[test]
fn http_status_mapping_is_correct() {
    use axum::http::StatusCode;

    assert_eq!(
        AppError::InvalidApiToken.http_status(),
        StatusCode::UNAUTHORIZED
    );
    assert_eq!(
        AppError::InvalidCredentials.http_status(),
        StatusCode::UNAUTHORIZED
    );
    assert_eq!(
        AppError::UsernameAlreadyExists.http_status(),
        StatusCode::CONFLICT
    );
    assert_eq!(
        AppError::EmailAlreadyExists.http_status(),
        StatusCode::CONFLICT
    );
    assert_eq!(AppError::InvalidName.http_status(), StatusCode::BAD_REQUEST);
    assert_eq!(
        AppError::InvalidOwnerEmail.http_status(),
        StatusCode::BAD_REQUEST
    );
    assert_eq!(
        AppError::DatabaseError(sqlx::Error::RowNotFound).http_status(),
        StatusCode::INTERNAL_SERVER_ERROR
    );
    assert_eq!(
        AppError::Internal(anyhow::anyhow!("boom")).http_status(),
        StatusCode::INTERNAL_SERVER_ERROR
    );
}

#[test]
fn grpc_status_mapping_is_correct() {
    assert_eq!(
        AppError::InvalidApiToken.to_grpc_status().code(),
        Code::Unauthenticated
    );
    assert_eq!(
        AppError::InvalidCredentials.to_grpc_status().code(),
        Code::Unauthenticated
    );
    assert_eq!(
        AppError::UsernameAlreadyExists.to_grpc_status().code(),
        Code::AlreadyExists
    );
    assert_eq!(
        AppError::EmailAlreadyExists.to_grpc_status().code(),
        Code::AlreadyExists
    );
    assert_eq!(
        AppError::InvalidName.to_grpc_status().code(),
        Code::InvalidArgument
    );
    assert_eq!(
        AppError::InvalidOwnerEmail.to_grpc_status().code(),
        Code::InvalidArgument
    );
    assert_eq!(
        AppError::DatabaseError(sqlx::Error::RowNotFound)
            .to_grpc_status()
            .code(),
        Code::Internal
    );
    assert_eq!(
        AppError::Internal(anyhow::anyhow!("boom"))
            .to_grpc_status()
            .code(),
        Code::Internal
    );
}

#[tokio::test]
async fn into_response_contains_machine_readable_error_body() {
    let response = AppError::InvalidName.into_response();
    assert_eq!(response.status(), axum::http::StatusCode::BAD_REQUEST);

    let body = to_bytes(response.into_body(), usize::MAX)
        .await
        .expect("read response body");
    let json: Value = serde_json::from_slice(&body).expect("valid JSON error body");

    assert_eq!(json["error"], "Invalid name");
    assert_eq!(json["code"], 1005);
}

#[test]
fn grpc_status_message_contains_error_code_and_text() {
    let status = AppError::InvalidApiToken.to_grpc_status();
    assert_eq!(status.code(), Code::Unauthenticated);
    assert!(status.message().contains("[code: 1001]"));
    assert!(status.message().contains("API token does not exist"));
}
