use sqlx::query_scalar;
use sqlx::{Postgres, Transaction};

use crate::errors::AppError;
use crate::services::system;
use crate::state::AppState;

pub async fn is_first_start(state: &AppState) -> Result<bool, AppError> {
    let count = query_scalar!(
        r#"
        SELECT COUNT(*) FROM clients
        "#
    )
    .fetch_one(&state.db)
    .await?;

    Ok(count.unwrap_or(0) == 0)
}

pub async fn store_api_token(
    state: &AppState,
    data: system::ApiTokenRequest,
    api_token: &String,
) -> Result<bool, AppError> {
    let mut tx: Transaction<'_, Postgres> = state.db.begin().await?;

    // Insert the client into the database
    sqlx::query!(
        r#"
        INSERT INTO clients (name, owner_email, api_token)
        VALUES ($1, $2, $3)
        "#,
        data.name,
        data.owner_email,
        api_token,
    )
    .execute(&mut *tx)
    .await?;

    // Commit the transaction to finalize the insertions
    tx.commit().await?;

    Ok(true)
}
