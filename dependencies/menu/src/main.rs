// SPDX-FileCopyrightText: 2026 Freshly Baked Cake
//
// SPDX-License-Identifier: MIT

use axum::{
    Router, ServiceExt,
    extract::{Path, Query, Request},
    http::StatusCode,
    response::{IntoResponse, Redirect},
    routing::get,
};
use std::{collections::HashMap, env};
use tower_http::normalize_path::NormalizePathLayer;
use tower_layer::Layer;

async fn get_redirect(default_location: &str, go: &str) -> Redirect {
    Redirect::temporary(&("".to_string() + default_location + go))
}

async fn get_redirect_base(go: &str) -> Redirect {
    get_redirect("/_/create?path=", go).await
}

async fn get_redirect_search(go: &str) -> Redirect {
    get_redirect("https://kagi.com/search?q=", go).await
}

async fn handle_root() -> String {
    "Hello, world!".to_string()
}

async fn handle_base(Path(go): Path<String>) -> Redirect {
    get_redirect_base(&go).await
}

async fn handle_search(Query(params): Query<HashMap<String, String>>) -> Redirect {
    if let Some(go) = params.get("q") {
        get_redirect_search(&go).await
    } else {
        Redirect::temporary("/")
    }
}

async fn handle_404() -> impl IntoResponse {
    (StatusCode::NOT_FOUND, "Not Found")
}

#[tokio::main]
async fn main() {
    let router = Router::new()
        .route("/", get(handle_root))
        .route("/_/search", get(handle_search))
        .route("/_/{*route}", get(handle_404))
        .route("/{*go}", get(handle_base));
    let app = NormalizePathLayer::trim_trailing_slash().layer(router);

    let listener = tokio::net::TcpListener::bind(
        env::var("BIND_ADDR").unwrap_or_else(|_| "0.0.0.0:3000".to_string()),
    )
    .await
    .unwrap();
    axum::serve(listener, ServiceExt::<Request>::into_make_service(app))
        .await
        .unwrap();
}
