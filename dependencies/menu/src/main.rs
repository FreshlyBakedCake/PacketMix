// SPDX-FileCopyrightText: 2026 Freshly Baked Cake
//
// SPDX-License-Identifier: MIT
mod auth;
mod direct;
mod regex;
mod static_html;

use axum::{
    Router, ServiceExt,
    extract::{Path, Query, Request},
    http::{HeaderMap, StatusCode},
    response::{IntoResponse, Redirect, Response, Result},
    routing::get,
};
use include_dir::{Dir, include_dir};
use percent_encoding::{NON_ALPHANUMERIC, utf8_percent_encode};
use phf::phf_map;
use sqlx::{Connection, PgConnection};
use tower_sessions::{MemoryStore, Session, SessionManagerLayer};

use std::{collections::HashMap, env, sync::OnceLock};
use tokio::{
    sync::Mutex,
    time::{Duration, sleep},
};
use tower_http::{self, normalize_path::NormalizePathLayer};
use tower_layer::Layer;
use tower_serve_static;

use crate::{
    auth::{ensure_authenticated, ensure_token},
    static_html::{StaticPageType, handle_static_page},
};

static PUBLIC_DIR: Dir<'static> = include_dir!("src/html/public");

#[cfg(debug_assertions)]
static DEVELOPMENT: OnceLock<bool> = OnceLock::new();

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

const SEARCH_ENGINES: phf::Map<&'static str, [&'static str; 3]> = phf_map! {
    "kagi" => [
        "Kagi",
        "https://kagi.com/search?q=",
        "https://kagi.com/api/autosuggest?q=",
    ],
    "google" => [
        "Google",
        "https://www.google.com/search?q=",
        "https://www.google.com/complete/search?q=",
    ],
    "udm14" => [
        "Google+UDM14",
        "https://www.google.com/search?udm=14&q=",
        "https://www.google.com/complete/search?q=",
    ],
    "ddg" => [
        "DuckDuckGo",
        "https://duckduckgo.com?q=",
        "https://duckduckgo.com/ac/?q=",
    ],
    "noai" => [
        "DuckDuckGo+NoAI",
        "https://noai.duckduckgo.com?q=",
        "https://noai.duckduckgo.com/ac/?q=",
    ]
};

fn clean_host(provided_host: &str) -> &str {
    if ALLOWED_HOSTS.contains(&provided_host) {
        return provided_host;
    }

    return "go";
}

async fn get_redirect(go: &str) -> Option<Redirect> {
    if let Some(redirect) = direct::get_redirect(go).await {
        return Some(redirect);
    }

    if let Some(redirect) = regex::get_redirect(go).await {
        return Some(redirect);
    }

    None
}

async fn get_redirect_base(go: &str) -> Redirect {
    get_redirect(go).await.unwrap_or_else(|| {
        Redirect::temporary(
            &("/_/create?format=direct&from=".to_string()
                + &utf8_percent_encode(go, NON_ALPHANUMERIC).to_string()),
        )
    })
}

struct InvalidSearchEngine {
    engine: String,
}
impl IntoResponse for InvalidSearchEngine {
    fn into_response(self) -> Response {
        return (
            StatusCode::NOT_FOUND,
            format!("Invalid Search Engine {}", self.engine),
        )
            .into_response();
    }
}

async fn handle_search_suggest(Query(params): Query<HashMap<String, String>>) -> Result<String> {
    if let Some(q) = params.get("q") {
        let Some(search_engine_metadata) = (match params.get("engine") {
            Some(e) => SEARCH_ENGINES.get(e),
            None => SEARCH_ENGINES.get("kagi"), // This is the default for historical reasons ...
        }) else {
            return Err(InvalidSearchEngine {
                engine: params
                    .get("engine")
                    .and_then(|e| Some(e.as_str()))
                    .unwrap_or("null")
                    .to_owned(),
            }
            .into());
        };

        Ok(reqwest::get(
            &(search_engine_metadata[2].to_owned()
                + &utf8_percent_encode(q, NON_ALPHANUMERIC).to_string()),
        )
        .await
        .map_err(|_e| StatusCode::INTERNAL_SERVER_ERROR)?
        .text()
        .await
        .map_err(|_e| StatusCode::INTERNAL_SERVER_ERROR)?)
    } else {
        Err(StatusCode::BAD_REQUEST.into())
    }
}

async fn get_redirect_search(go: &str, engine: Option<&str>) -> Result<Redirect> {
    get_redirect(go)
        .await
        .and_then(|r| Some(Ok(r)))
        .unwrap_or_else(|| {
            let Some(search_engine_metadata) = (match engine {
                Some(e) => SEARCH_ENGINES.get(e),
                None => SEARCH_ENGINES.get("kagi"), // This is the default for historical reasons ...
            }) else {
                return Err(InvalidSearchEngine {
                    engine: engine.unwrap_or("null").to_owned(),
                }
                .into());
            };

            Ok(Redirect::temporary(
                &(search_engine_metadata[1].to_owned()
                    + &utf8_percent_encode(go, NON_ALPHANUMERIC).to_string()),
            ))
        })
}

fn get_search_engines() -> String {
    let mut result = "".to_owned();
    for (engine, meta) in SEARCH_ENGINES.entries() {
        let engine_url = utf8_percent_encode(engine, NON_ALPHANUMERIC).to_string();
        let name_attr = html_escape::encode_quoted_attribute(meta[0]);
        let name_url = utf8_percent_encode(meta[0], NON_ALPHANUMERIC).to_string();

        result += format!(
            r#"<link rel="search" type="application/opensearchdescription+xml" title="Menu {name_attr}" href="/_/opensearch.xml?name={name_url}&engine={engine_url}" />"#
        ).as_str();
    }

    result
}

#[axum::debug_handler]
async fn handle_index(
    session: Session,
    headers: HeaderMap,
    Query(params): Query<HashMap<String, String>>,
) -> Result<Response> {
    handle_static_page(StaticPageType::Index, session, &params, &headers).await
}

async fn handle_base(Path(go): Path<String>) -> Redirect {
    get_redirect_base(&go).await
}

async fn handle_search(Query(params): Query<HashMap<String, String>>) -> Result<Redirect> {
    if let Some(go) = params.get("q") {
        get_redirect_search(&go, params.get("engine").and_then(|s| Some(s.as_str()))).await
    } else {
        Ok(Redirect::temporary("/"))
    }
}

enum CreationResult {
    Success,
    Conflict(String),
    Failure,
}

enum DeletionResult {
    Success,
    NotFound,
    Failure,
}

async fn handle_create_page(
    session: Session,
    Query(params): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Result<Response> {
    handle_static_page(StaticPageType::Create, session, &params, &headers).await
}
async fn handle_create_success_page(
    session: Session,
    Query(params): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Result<Response> {
    match params.get("format").and_then(|s| Some(s.as_str())) {
        Some("direct") => {
            handle_static_page(
                StaticPageType::CreateDirectSuccess,
                session,
                &params,
                &headers,
            )
            .await
        }
        Some("regex") => {
            handle_static_page(
                StaticPageType::CreateRegexSuccess,
                session,
                &params,
                &headers,
            )
            .await
        }
        _ => Err("Invalid format".into()),
    }
}
async fn handle_create_conflict_page(
    session: Session,
    Query(params): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Result<Response> {
    match params.get("format").and_then(|s| Some(s.as_str())) {
        Some("direct") => {
            handle_static_page(
                StaticPageType::CreateDirectConflict,
                session,
                &params,
                &headers,
            )
            .await
        }
        Some("regex") => {
            handle_static_page(
                StaticPageType::CreateRegexConflict,
                session,
                &params,
                &headers,
            )
            .await
        }
        _ => Err("Invalid format".into()),
    }
}
async fn handle_create_failure_page(
    session: Session,
    Query(params): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Result<impl IntoResponse> {
    handle_static_page(StaticPageType::CreateFailure, session, &params, &headers)
        .await
        .and_then(|html| Ok((StatusCode::INTERNAL_SERVER_ERROR, html)))
}
async fn handle_delete_success_page(
    session: Session,
    Query(params): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Result<Response> {
    match params.get("format").and_then(|s| Some(s.as_str())) {
        Some("direct") => {
            handle_static_page(
                StaticPageType::DeleteDirectSuccess,
                session,
                &params,
                &headers,
            )
            .await
        }
        Some("regex") => {
            handle_static_page(
                StaticPageType::DeleteRegexSuccess,
                session,
                &params,
                &headers,
            )
            .await
        }
        _ => Err("Invalid format".into()),
    }
}
async fn handle_delete_failure_page(
    session: Session,
    Query(params): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Result<Response> {
    handle_static_page(StaticPageType::DeleteFailure, session, &params, &headers).await
}
async fn handle_opensearch_xml_page(
    session: Session,
    Query(params): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Result<Response> {
    handle_static_page(StaticPageType::OpenSearch, session, &params, &headers).await
}

#[axum::debug_handler]
async fn handle_create_do(
    session: Session,
    headers: HeaderMap,
    Query(params): Query<HashMap<String, String>>,
) -> Result<Response> {
    ensure_token(&session, &params).await?;
    let owner = ensure_authenticated(
        &headers,
        #[cfg(debug_assertions)]
        &params,
    )?;

    let from = params.get("from").ok_or("Missing from query")?;
    let to = params.get("to").ok_or("Missing to query")?;
    let format = params.get("format").ok_or("Missing format query")?;

    let create_response = match format.as_str() {
        "direct" => direct::create(from, to, owner, params.get("current")).await,
        "regex" => regex::create(from, to, owner, params.get("current")).await,
        _ => return Err(format!("Invalid format {}", format).into_response().into()),
    };

    match create_response {
        CreationResult::Success => Ok(Redirect::to(&format!(
            "/_/create/success?from={}&to={}&format={}",
            utf8_percent_encode(&from, NON_ALPHANUMERIC).to_string(),
            utf8_percent_encode(&to, NON_ALPHANUMERIC).to_string(),
            utf8_percent_encode(&format, NON_ALPHANUMERIC).to_string(),
        ))
        .into_response()),
        CreationResult::Conflict(conflict) => Ok(Redirect::to(&format!(
            "/_/create/conflict?from={}&to={}&current={}&format={}",
            utf8_percent_encode(&from, NON_ALPHANUMERIC).to_string(),
            utf8_percent_encode(&to, NON_ALPHANUMERIC).to_string(),
            utf8_percent_encode(&conflict, NON_ALPHANUMERIC).to_string(),
            utf8_percent_encode(&format, NON_ALPHANUMERIC).to_string(),
        ))
        .into_response()),
        CreationResult::Failure => Ok(Redirect::to(&format!(
            "/_/create/failure?from={}&to={}&format={}",
            utf8_percent_encode(&from, NON_ALPHANUMERIC).to_string(),
            utf8_percent_encode(&to, NON_ALPHANUMERIC).to_string(),
            utf8_percent_encode(&format, NON_ALPHANUMERIC).to_string(),
        ))
        .into_response()),
    }
}

#[axum::debug_handler]
async fn handle_delete_do(
    session: Session,
    headers: HeaderMap,
    Query(params): Query<HashMap<String, String>>,
) -> Result<Response> {
    ensure_token(&session, &params).await?;
    ensure_authenticated(
        &headers,
        #[cfg(debug_assertions)]
        &params,
    )?;

    let from = params.get("from").ok_or("Missing from query")?;
    let current = params.get("current").ok_or("Missing current query")?;
    let format = params.get("format").ok_or("Missing format query")?;

    let delete_result = match format.as_str() {
        "direct" => direct::delete(from, current).await,
        "regex" => regex::delete(from, current).await,
        _ => return Err(format!("Invalid format {}", format).into_response().into()),
    };

    match delete_result {
        DeletionResult::Success => Ok(Redirect::to(&format!(
            "/_/delete/success?from={}&current={}&format={}",
            utf8_percent_encode(&from, NON_ALPHANUMERIC).to_string(),
            utf8_percent_encode(&current, NON_ALPHANUMERIC).to_string(),
            utf8_percent_encode(&format, NON_ALPHANUMERIC).to_string(),
        ))
        .into_response()),
        _ => Ok(Redirect::to(&format!(
            "/_/delete/failure?from={}&to={}&format={}",
            utf8_percent_encode(&from, NON_ALPHANUMERIC).to_string(),
            utf8_percent_encode(&current, NON_ALPHANUMERIC).to_string(),
            utf8_percent_encode(&format, NON_ALPHANUMERIC).to_string(),
        ))
        .into_response()),
    }
}

async fn handle_404() -> impl IntoResponse {
    (StatusCode::NOT_FOUND, "Not Found")
}

#[tokio::main]
async fn main() {
    #[cfg(debug_assertions)]
    {
        DEVELOPMENT
            .set(env::var("DEVELOPMENT").is_ok_and(|value| value == "true"))
            .unwrap();
    }
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

    let session_layer = {
        let session_store = MemoryStore::default();
        SessionManagerLayer::new(session_store).with_secure(false) // must be false for go:// support
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

    let mut router = Router::new();

    #[cfg(not(debug_assertions))]
    {
        router = router.nest_service("/_/public", tower_serve_static::ServeDir::new(&PUBLIC_DIR));
    }

    #[cfg(debug_assertions)]
    {
        if *DEVELOPMENT.get().unwrap() {
            router = router.nest_service(
                "/_/public",
                tower_http::services::ServeDir::new("src/html/public"),
            );
        } else {
            router =
                router.nest_service("/_/public", tower_serve_static::ServeDir::new(&PUBLIC_DIR));
        }
    }

    router = router
        .route("/", get(handle_index))
        .route("/_/create", get(handle_create_page))
        .route("/_/create/success", get(handle_create_success_page))
        .route("/_/create/conflict", get(handle_create_conflict_page))
        .route("/_/create/failure", get(handle_create_failure_page))
        .route("/_/create/do", get(handle_create_do))
        .route("/_/delete/do", get(handle_delete_do))
        .route("/_/delete/success", get(handle_delete_success_page))
        .route("/_/delete/failure", get(handle_delete_failure_page))
        .route("/_/search", get(handle_search))
        .route("/_/suggest", get(handle_search_suggest))
        .route("/_/opensearch.xml", get(handle_opensearch_xml_page))
        .route("/_/{*route}", get(handle_404))
        .route("/{*go}", get(handle_base));
    let app = NormalizePathLayer::trim_trailing_slash().layer(router.layer(session_layer));

    let listener = tokio::net::TcpListener::bind(
        env::var("BIND_ADDR").unwrap_or_else(|_| "0.0.0.0:3000".to_string()),
    )
    .await
    .unwrap();
    axum::serve(listener, ServiceExt::<Request>::into_make_service(app))
        .await
        .unwrap();
}
