// SPDX-FileCopyrightText: 2026 Freshly Baked Cake
//
// SPDX-License-Identifier: MIT

use axum::{
    http::{HeaderMap, StatusCode},
    response::{ErrorResponse, IntoResponse},
};
use std::collections::HashMap;
use tower_sessions::Session;
use uuid::Uuid;

const TOKEN_KEY: &str = "token";

struct NotAuthenticated;
impl IntoResponse for NotAuthenticated {
    fn into_response(self) -> axum::response::Response {
        return (StatusCode::UNAUTHORIZED, "Access over Tailscale only").into_response();
    }
}

struct MissingToken;
impl IntoResponse for MissingToken {
    fn into_response(self) -> axum::response::Response {
        return (
            StatusCode::FORBIDDEN,
            "There's no session here - try going back and trying again?",
        )
            .into_response();
    }
}

struct InvalidToken;
impl IntoResponse for InvalidToken {
    fn into_response(self) -> axum::response::Response {
        return (
            StatusCode::FORBIDDEN,
            "This session is invalid - possible CSRF?",
        )
            .into_response();
    }
}

pub(crate) fn ensure_authenticated<'a>(
    headers: &'a HeaderMap,
    #[cfg(debug_assertions)] params: &'a HashMap<String, String>,
) -> Result<&'a str, ErrorResponse> {
    if let Some(user) = headers
        .get("X-Webauth-Login")
        .and_then(|header| header.to_str().ok())
    {
        return Ok(user);
    }

    #[cfg(debug_assertions)]
    {
        use crate::DEVELOPMENT;

        if *DEVELOPMENT.get().unwrap() {
            if let Some(user) = params.get("dev_auth_as") {
                return Ok(user);
            }
        }
    }

    Err(NotAuthenticated {}.into())
}

pub(crate) async fn get_token(session: &Session) -> String {
    let maybe_token = session.get(TOKEN_KEY).await.unwrap();
    if let Some(token) = maybe_token {
        token
    } else {
        let new_token = Uuid::new_v4().to_string();
        session.insert(TOKEN_KEY, &new_token).await.unwrap();
        new_token
    }
}

pub(crate) async fn ensure_token<'a>(
    session: &Session,
    params: &'a HashMap<String, String>,
) -> Result<(), ErrorResponse> {
    let maybe_token: Option<String> = session.get(TOKEN_KEY).await.unwrap();

    let Some(token) = maybe_token else {
        return Err(MissingToken {}.into());
    };

    if token == "" {
        return Err(MissingToken {}.into());
    }

    if params.get("token").is_some_and(|val| *val == token) {
        return Ok(());
    }

    Err(InvalidToken {}.into())
}
