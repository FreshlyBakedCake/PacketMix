// SPDX-FileCopyrightText: 2026 Freshly Baked Cake
//
// SPDX-License-Identifier: MIT

use axum::{
    Form, Router, ServiceExt,
    body::Body,
    extract::{Path, Query, Request},
    http::{HeaderMap, Response, StatusCode},
    response::{Html, IntoResponse, Redirect},
    routing::{get, post},
};
use serde::Deserialize;
use sqlx::{Connection, PgConnection};
use std::{collections::HashMap, env, ops::DerefMut, sync::OnceLock};
use tokio::{
    sync::Mutex,
    time::{Duration, sleep},
};
use tower_http::normalize_path::NormalizePathLayer;
use tower_layer::Layer;

fn template_html(html: &str, replacements: &HashMap<&str, Option<&str>>) -> String {
    let mut result = html.to_owned();
    for (&text, &maybe_replacement) in replacements {
        if let Some(replacement) = maybe_replacement {
            result = result.replace(&("{".to_owned() + text + "}"), replacement)
        }
    }

    result
}

#[derive(Debug)]
struct State {
    sqlx_connection: Mutex<PgConnection>,
}
static STATE: OnceLock<State> = OnceLock::new();

const ALLOWED_HOSTS: &'static [&'static str] = &[
    "go",
    "go.search.freshly.space",
    "menu.freshlybakedca.ke",
    "starry.sk",
];

fn clean_host(provided_host: &str) -> &str {
    if ALLOWED_HOSTS.contains(&provided_host) {
        return provided_host;
    }

    return "go";
}

async fn get_redirect(default_location: &str, go: &str) -> Redirect {
    let redirect = sqlx::query!(
        r#"SELECT ("to") FROM direct WHERE "from" = $1 LIMIT 1"#,
        go.to_lowercase()
    )
    .fetch_one(
        STATE
            .get()
            .expect("Server must be initialized before processing connections")
            .sqlx_connection
            .lock()
            .await
            .deref_mut(),
    )
    .await;

    if let Ok(record) = redirect {
        Redirect::temporary(&record.to)
    } else {
        Redirect::temporary(&("".to_string() + default_location + go))
    }
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

async fn handle_create_page(
    Query(params): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Html<String> {
    Html(template_html(
        include_str!("./html/create.html"),
        &HashMap::from([
            (
                "host",
                Some(clean_host(
                    headers
                        .get("host")
                        .and_then(|header| Some(header.to_str().unwrap_or_else(|_| "go")))
                        .unwrap_or_else(|| "go"),
                )),
            ),
            (
                "path",
                params.get("path").and_then(|path| Some(path.as_str())),
            ),
        ]),
    ))
}

#[derive(Deserialize)]
struct Create {
    from: String,
    to: String,
}

#[axum::debug_handler]
async fn handle_create_post(headers: HeaderMap, Form(create): Form<Create>) -> Response<Body> {
    let Some(Ok(owner)) = headers
        .get("X-Webauth-Login")
        .and_then(|header| Some(header.to_str()))
    else {
        return (StatusCode::UNAUTHORIZED, "Access over Tailscale only").into_response();
    };

    let create_call = sqlx::query!(
        r#"INSERT INTO direct ("from", "to", "owner") VALUES ($1, $2, $3)"#,
        create.from.to_lowercase(),
        create.to,
        owner,
    )
    .execute(
        STATE
            .get()
            .expect("Server must be initialized before processing connections")
            .sqlx_connection
            .lock()
            .await
            .deref_mut(),
    )
    .await;

    if create_call.is_ok() {
        Redirect::to(&format!("/_/created?path={}", create.from)).into_response()
    } else {
        Redirect::to(&format!("/_/createFailed?path={}", create.from)).into_response()
    }
}

async fn handle_404() -> impl IntoResponse {
    (StatusCode::NOT_FOUND, "Not Found")
}

#[tokio::main]
async fn main() {
    let mut connection = {
        let mut maybe_connection;
        let mut tries = 3;
        loop {
            // We can't use a for loop here as rust doesn't know it will run at least once...
            tries -= 1;
            maybe_connection = PgConnection::connect(
                env::var("DATABASE_URL")
                    .expect(
                        "Please ensure you set your database URL in the $DATABASE_URL environment variable",
                    )
                    .as_str(),
            )
            .await;

            if maybe_connection.is_ok() || tries == 0 {
                break;
            }

            sleep(Duration::from_secs(5)).await;
        }

        maybe_connection
            .expect("Failed to connect to database defined in $DATABASE_URL after 3 retries")
    };

    sqlx::migrate!()
        .run(&mut connection)
        .await
        .expect("Failed to run database migrations");

    STATE
        .set(State {
            sqlx_connection: Mutex::new(connection),
        })
        .expect("Consistency issue: failed to set STATE - was it already set?");

    let router = Router::new()
        .route("/", get(handle_root))
        .route("/_/create", get(handle_create_page))
        .route("/_/create", post(handle_create_post))
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
