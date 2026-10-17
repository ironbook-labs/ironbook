#![cfg(feature = "integration-tests")]

// These tests intentionally live behind a feature because they require PostgreSQL.
// Run with:
//   DATABASE_URL=postgres://postgres:postgres@127.0.0.1:5432/ironbook_test \
//   cargo test --features integration-tests
//
// The preferred setup is to run them against a disposable PostgreSQL database/CI service.

mod common;

use argon2::{
    Argon2,
    password_hash::{PasswordHasher, SaltString, rand_core::OsRng},
};
use chrono::{Duration, Utc};
use common::{init_db, test_state};
use ironbook_api::{db, errors::AppError, services};
use sqlx::PgPool;

async fn reset(pool: &PgPool) {
    sqlx::query("TRUNCATE TABLE sessions, users, clients RESTART IDENTITY CASCADE")
        .execute(pool)
        .await
        .expect("truncate test tables");
}

#[sqlx::test(migrations = false)]
async fn common_lookup_functions_trim_inputs(pool: PgPool) {
    let mut state = test_state();
    state.db = pool.clone();
    init_db(&pool).await;
    reset(&pool).await;

    sqlx::query("INSERT INTO users (username, email, password_hash) VALUES ($1, $2, $3)")
        .bind("alice")
        .bind("alice@example.com")
        .bind("hash")
        .execute(&pool)
        .await
        .unwrap();

    assert_eq!(
        db::common::get_user_id_by_username(&state, "  alice  ")
            .await
            .unwrap(),
        Some(1)
    );
    assert_eq!(
        db::common::get_user_id_by_email(&state, " alice@example.com ")
            .await
            .unwrap(),
        Some(1)
    );
    assert_eq!(
        db::common::get_username_by_id(&state, &1).await.unwrap(),
        Some("alice".into())
    );
    assert_eq!(
        db::common::get_password_hash_by_user_id(&state, &1)
            .await
            .unwrap(),
        Some("hash".into())
    );
    assert_eq!(
        db::common::get_user_id_by_username(&state, "missing")
            .await
            .unwrap(),
        None
    );
}

#[sqlx::test(migrations = false)]
async fn api_token_verification_distinguishes_existing_and_missing_tokens(pool: PgPool) {
    let mut state = test_state();
    state.db = pool.clone();
    init_db(&pool).await;
    reset(&pool).await;

    sqlx::query("INSERT INTO clients (name, owner_email, api_token) VALUES ($1, $2, $3)")
        .bind("client")
        .bind("owner@example.com")
        .bind("abcdefghijklmnopqrstuvwx123456")
        .execute(&pool)
        .await
        .unwrap();

    assert!(
        db::common::verify_api_token(&state, "abcdefghijklmnopqrstuvwx123456")
            .await
            .unwrap()
    );
    assert!(
        !db::common::verify_api_token(&state, "missing-token")
            .await
            .unwrap()
    );
}

#[sqlx::test(migrations = false)]
async fn auth_register_creates_user_and_session(pool: PgPool) {
    let mut state = test_state();
    state.db = pool.clone();
    init_db(&pool).await;
    reset(&pool).await;

    let user_id = db::auth::register(
        &state,
        services::auth::RegisterRequest {
            email: "new@example.com".into(),
            username: "new-user".into(),
            password: "hash".into(),
        },
        &"abcdefghijklmnopqrstuvwxyz123456".to_string(),
    )
    .await
    .unwrap();

    assert_eq!(user_id, 1);

    let session_token: String =
        sqlx::query_scalar("SELECT token_hash FROM sessions WHERE user_id = $1")
            .bind(user_id as i64)
            .fetch_one(&pool)
            .await
            .unwrap();
    assert_eq!(session_token, "abcdefghijklmnopqrstuvwxyz123456");

    let expires_at: chrono::DateTime<Utc> =
        sqlx::query_scalar("SELECT expires_at FROM sessions WHERE user_id = $1")
            .bind(user_id as i64)
            .fetch_one(&pool)
            .await
            .unwrap();
    let now = Utc::now();
    assert!(expires_at >= now + Duration::days(364));
    assert!(expires_at <= now + Duration::days(366));
}

#[sqlx::test(migrations = false)]
async fn auth_login_creates_a_new_session_and_returns_its_token(pool: PgPool) {
    let mut state = test_state();
    state.db = pool.clone();
    init_db(&pool).await;
    reset(&pool).await;

    sqlx::query("INSERT INTO users (username, email, password_hash) VALUES ($1, $2, $3)")
        .bind("alice")
        .bind("alice@example.com")
        .bind("hash")
        .execute(&pool)
        .await
        .unwrap();

    let token = db::auth::login(
        &state,
        services::auth::LoginRequest {
            email: "alice@example.com".into(),
            password: "hash".into(),
        },
        &"zyxwvutsrqponmlkjihgfedcba654321".to_string(),
    )
    .await
    .unwrap();

    assert_eq!(token, "zyxwvutsrqponmlkjihgfedcba654321");
}

#[sqlx::test(migrations = false)]
async fn system_first_start_and_api_token_storage_work(pool: PgPool) {
    let mut state = test_state();
    state.db = pool.clone();
    init_db(&pool).await;
    reset(&pool).await;

    assert!(db::system::is_first_start(&state).await.unwrap());

    let data = services::system::ApiTokenRequest {
        name: "client-one".into(),
        owner_email: "owner@example.com".into(),
    };

    assert!(
        db::system::store_api_token(
            &state,
            data,
            &"abcdefghijklmnopqrstuvwxyz123456".to_string()
        )
        .await
        .unwrap()
    );

    assert!(!db::system::is_first_start(&state).await.unwrap());
}

#[sqlx::test(migrations = false)]
async fn user_service_searches_by_email_and_username(pool: PgPool) {
    let mut state = test_state();
    state.db = pool.clone();
    init_db(&pool).await;
    reset(&pool).await;

    sqlx::query("INSERT INTO users (username, email, password_hash) VALUES ($1, $2, $3)")
        .bind("alice")
        .bind("alice@example.com")
        .bind("hash")
        .execute(&pool)
        .await
        .unwrap();

    let by_email = services::users::search(
        &state,
        services::users::SearchFilter {
            email: Some("alice@example.com".into()),
            username: None,
        },
    )
    .await
    .unwrap();
    assert_eq!(by_email.id, 1);
    assert_eq!(by_email.username, "alice");

    let by_username = services::users::search(
        &state,
        services::users::SearchFilter {
            email: None,
            username: Some("  alice  ".into()),
        },
    )
    .await
    .unwrap();
    assert_eq!(by_username.id, 1);
    assert_eq!(by_username.username, "alice");

    let no_filter = services::users::search(
        &state,
        services::users::SearchFilter {
            email: None,
            username: None,
        },
    )
    .await
    .unwrap_err();
    assert!(matches!(no_filter, AppError::InvalidCredentials));
}

#[sqlx::test(migrations = false)]
async fn user_service_get_by_id_returns_user_or_invalid_credentials(pool: PgPool) {
    let mut state = test_state();
    state.db = pool.clone();
    init_db(&pool).await;
    reset(&pool).await;

    sqlx::query("INSERT INTO users (username, email, password_hash) VALUES ($1, $2, $3)")
        .bind("alice")
        .bind("alice@example.com")
        .bind("hash")
        .execute(&pool)
        .await
        .unwrap();

    let user = services::users::get_user_by_id(&state, 1).await.unwrap();
    assert_eq!(user.id, 1);
    assert_eq!(user.username, "alice");

    let missing = services::users::get_user_by_id(&state, 999)
        .await
        .unwrap_err();
    assert!(matches!(missing, AppError::InvalidCredentials));
}

#[sqlx::test(migrations = false)]
async fn auth_service_rejects_invalid_token_and_duplicates(pool: PgPool) {
    let mut state = test_state();
    state.db = pool.clone();
    init_db(&pool).await;
    reset(&pool).await;

    let request = || services::auth::RegisterRequest {
        email: "new@example.com".into(),
        username: "new-user".into(),
        password: "hash".into(),
    };

    let invalid = services::auth::register(&state, "bad-token", request())
        .await
        .unwrap_err();
    assert!(matches!(invalid, AppError::InvalidApiToken));

    sqlx::query("INSERT INTO clients (name, owner_email, api_token) VALUES ($1, $2, $3)")
        .bind("client")
        .bind("owner@example.com")
        .bind("abcdefghijklmnopqrstuvwxyz123456")
        .execute(&pool)
        .await
        .unwrap();

    services::auth::register(&state, "abcdefghijklmnopqrstuvwxyz123456", request())
        .await
        .unwrap();

    let duplicate_username = services::auth::register(
        &state,
        "abcdefghijklmnopqrstuvwxyz123456",
        services::auth::RegisterRequest {
            email: "other@example.com".into(),
            username: "new-user".into(),
            password: "hash".into(),
        },
    )
    .await
    .unwrap_err();
    assert!(matches!(
        duplicate_username,
        AppError::UsernameAlreadyExists
    ));

    let duplicate_email = services::auth::register(
        &state,
        "abcdefghijklmnopqrstuvwxyz123456",
        services::auth::RegisterRequest {
            email: "new@example.com".into(),
            username: "other-user".into(),
            password: "hash".into(),
        },
    )
    .await
    .unwrap_err();
    assert!(matches!(duplicate_email, AppError::EmailAlreadyExists));
}

#[sqlx::test(migrations = false)]
async fn login_service_covers_authentication_failures_and_success(pool: PgPool) {
    let mut state = test_state();
    state.db = pool.clone();
    init_db(&pool).await;
    reset(&pool).await;

    sqlx::query("INSERT INTO clients (name, owner_email, api_token) VALUES ($1, $2, $3)")
        .bind("client")
        .bind("owner@example.com")
        .bind("abcdefghijklmnopqrstuvwxyz123456")
        .execute(&pool)
        .await
        .unwrap();

    let bad_api_token = services::auth::login(
        &state,
        "bad-token",
        services::auth::LoginRequest {
            email: "alice@example.com".into(),
            password: "hash".into(),
        },
    )
    .await
    .unwrap_err();
    assert!(matches!(bad_api_token, AppError::InvalidApiToken));

    let missing_user = services::auth::login(
        &state,
        "abcdefghijklmnopqrstuvwxyz123456",
        services::auth::LoginRequest {
            email: "missing@example.com".into(),
            password: "hash".into(),
        },
    )
    .await
    .unwrap_err();
    assert!(matches!(missing_user, AppError::InvalidCredentials));

    let salt = SaltString::generate(&mut OsRng);
    let argon2 = Argon2::default();
    let valid_password_hash = argon2.hash_password(b"hash", &salt).unwrap().to_string();

    sqlx::query("INSERT INTO users (username, email, password_hash) VALUES ($1, $2, $3)")
        .bind("alice")
        .bind("alice@example.com")
        .bind(valid_password_hash)
        .execute(&pool)
        .await
        .unwrap();

    let bad_password = services::auth::login(
        &state,
        "abcdefghijklmnopqrstuvwxyz123456",
        services::auth::LoginRequest {
            email: "alice@example.com".into(),
            password: "wrong".into(),
        },
    )
    .await
    .unwrap_err();
    assert!(matches!(bad_password, AppError::InvalidCredentials));

    let success = services::auth::login(
        &state,
        "abcdefghijklmnopqrstuvwxyz123456",
        services::auth::LoginRequest {
            email: "alice@example.com".into(),
            password: "hash".into(),
        },
    )
    .await
    .unwrap();

    assert_eq!(success.token.len(), 32);
    assert!(success.token.chars().all(|c| c.is_ascii_alphanumeric()));
}

#[sqlx::test(migrations = false)]
async fn generate_api_token_allows_bootstrap_without_auth(pool: PgPool) {
    let mut state = test_state();
    state.db = pool.clone();
    init_db(&pool).await;
    reset(&pool).await;

    let response = services::system::generate_api_token(
        &state,
        None,
        services::system::ApiTokenRequest {
            name: "bootstrap".into(),
            owner_email: "owner@example.com".into(),
        },
    )
    .await
    .unwrap();

    assert_eq!(response.token.len(), 32);
    assert!(response.token.chars().all(|c| c.is_ascii_alphanumeric()));
    assert!(!db::system::is_first_start(&state).await.unwrap());
}

#[sqlx::test(migrations = false)]
async fn generate_api_token_enforces_validation_and_existing_token_auth(pool: PgPool) {
    let mut state = test_state();
    state.db = pool.clone();
    init_db(&pool).await;
    reset(&pool).await;

    let invalid_name = services::system::generate_api_token(
        &state,
        None,
        services::system::ApiTokenRequest {
            name: "   ".into(),
            owner_email: "owner@example.com".into(),
        },
    )
    .await
    .unwrap_err();
    assert!(matches!(invalid_name, AppError::InvalidName));

    let invalid_owner = services::system::generate_api_token(
        &state,
        None,
        services::system::ApiTokenRequest {
            name: "good-name".into(),
            owner_email: "   ".into(),
        },
    )
    .await
    .unwrap_err();
    assert!(matches!(invalid_owner, AppError::InvalidOwnerEmail));

    services::system::generate_api_token(
        &state,
        None,
        services::system::ApiTokenRequest {
            name: "first".into(),
            owner_email: "owner@example.com".into(),
        },
    )
    .await
    .unwrap();

    let invalid_api = services::system::generate_api_token(
        &state,
        Some("bad-token"),
        services::system::ApiTokenRequest {
            name: "second".into(),
            owner_email: "other@example.com".into(),
        },
    )
    .await
    .unwrap_err();
    assert!(matches!(invalid_api, AppError::InvalidApiToken));
}
