// SPDX-FileCopyrightText: 2026 Freshly Baked Cake
//
// SPDX-License-Identifier: MIT
use axum::{
    Router, ServiceExt,
    body::Body,
    extract::{Path, Query, Request},
    http::{HeaderMap, Response, StatusCode},
    response::{ErrorResponse, Html, IntoResponse, Redirect, Result},
    routing::get,
};
use include_dir::{Dir, include_dir};
use percent_encoding::{NON_ALPHANUMERIC, utf8_percent_encode};
use sqlx::{Connection, PgConnection};

#[cfg(debug_assertions)]
use std::fs;

use std::{collections::HashMap, env, ops::DerefMut, sync::OnceLock};
use tokio::{
    sync::Mutex,
    time::{Duration, sleep},
};
use tower_http::{self, normalize_path::NormalizePathLayer};
use tower_layer::Layer;
use tower_serve_static;

static PUBLIC_DIR: Dir<'static> = include_dir!("src/html/public");

#[cfg(debug_assertions)]
static DEVELOPMENT: OnceLock<bool> = OnceLock::new();

fn template_html<'a>(
    mut html: String,
    replacements: HashMap<&str, Box<dyn 'a + FnOnce() -> Option<&'a str>>>,
) -> String {
    for (text, maybe_replacement) in replacements {
        let replacement = maybe_replacement().unwrap_or_else(|| "");
        html = html.replace(
            &("{".to_owned() + text + "}"),
            &html_escape::encode_text(replacement),
        );
        html = html.replace(
            &("{".to_owned() + text + ":attribute}"),
            &html_escape::encode_quoted_attribute(replacement),
        );
        html = html.replace(
            &("{".to_owned() + text + ":url}"),
            &utf8_percent_encode(replacement, NON_ALPHANUMERIC).to_string(),
        );
    }

    html
}

/// include_str, but if DEVELOPMENT then the string is dynamically fetched for easy reloading
/// to support this, the string is *always* owned.
#[cfg(debug_assertions)]
macro_rules! include_String_dynamic {
    ($file:expr $(,)?) => {
        if (*DEVELOPMENT.get().unwrap()) {
            fs::read_to_string("src/".to_string() + $file)
                .expect(format!("Unable to read file {}", $file).as_str())
        } else {
            include_str!($file).to_owned()
        }
    };
}
#[cfg(not(debug_assertions))]
macro_rules! include_String_dynamic {
    ($file:expr $(,)?) => {
        include_str!($file).to_owned()
    };
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
    get_redirect("/_/create?from=", go).await
}

async fn get_redirect_search(go: &str) -> Redirect {
    get_redirect("https://kagi.com/search?q=", go).await
}

async fn handle_root(
    headers: HeaderMap,
    #[cfg(debug_assertions)] Query(params): Query<HashMap<String, String>>,
) -> Result<String> {
    ensure_authenticated(
        &headers,
        #[cfg(debug_assertions)]
        &params,
    )?;
    Ok("Hello, world!".to_string())
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

#[derive(Clone)]
enum StaticPageType {
    Create,
    CreateSuccess,
    CreateConflict,
    CreateFailure,
    DeleteSuccess,
    DeleteFailure,
}

async fn handle_static_page<'a>(
    page_type: StaticPageType,
    params: &'a HashMap<String, String>,
    headers: &'a HeaderMap,
) -> Result<Html<String>> {
    let auth_required = match page_type {
        _ => true,
    };

    let html = match page_type {
        StaticPageType::Create => include_String_dynamic!("./html/create.html"),
        StaticPageType::CreateSuccess => include_String_dynamic!("./html/create/success.html"),
        StaticPageType::CreateConflict => include_String_dynamic!("./html/create/conflict.html"),
        StaticPageType::CreateFailure => include_String_dynamic!("./html/create/failure.html"),
        StaticPageType::DeleteSuccess => include_String_dynamic!("./html/delete/success.html"),
        StaticPageType::DeleteFailure => include_String_dynamic!("./html/delete/failure.html"),
    };

    let username = if auth_required {
        Some(ensure_authenticated(
            headers,
            #[cfg(debug_assertions)]
            params,
        )?)
    } else {
        None
    };

    let mut replacements: HashMap<&str, Box<dyn 'a + FnOnce() -> Option<&'a str>>> = HashMap::new();
    replacements.insert(
        "host",
        Box::new(|| {
            Some(clean_host(
                headers
                    .get("host")
                    .and_then(|header| Some(header.to_str().unwrap_or_else(|_| "go")))
                    .unwrap_or_else(|| "go"),
            ))
        }),
    );
    replacements.insert(
        "from",
        Box::new(|| params.get("from").and_then(|from| Some(from.as_str()))),
    );
    replacements.insert(
        "to",
        Box::new(|| params.get("to").and_then(|to| Some(to.as_str()))),
    );
    replacements.insert(
        "current",
        Box::new(|| {
            params
                .get("current")
                .and_then(|current| Some(current.as_str()))
        }),
    );
    replacements.insert("username", Box::new(move || username));

    let result = template_html(html, replacements);
    Ok(Html(result))
}

async fn handle_create_page(
    Query(params): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Result<Html<String>> {
    handle_static_page(StaticPageType::Create, &params, &headers).await
}
async fn handle_create_success_page(
    Query(params): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Result<Html<String>> {
    handle_static_page(StaticPageType::CreateSuccess, &params, &headers).await
}
async fn handle_create_conflict_page(
    Query(params): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Result<Html<String>> {
    handle_static_page(StaticPageType::CreateConflict, &params, &headers).await
}
async fn handle_create_failure_page(
    Query(params): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Result<impl IntoResponse> {
    handle_static_page(StaticPageType::CreateFailure, &params, &headers)
        .await
        .and_then(|html| Ok((StatusCode::INTERNAL_SERVER_ERROR, html)))
}
async fn handle_delete_success_page(
    Query(params): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Result<Html<String>> {
    handle_static_page(StaticPageType::DeleteSuccess, &params, &headers).await
}
async fn handle_delete_failure_page(
    Query(params): Query<HashMap<String, String>>,
    headers: HeaderMap,
) -> Result<Html<String>> {
    handle_static_page(StaticPageType::DeleteFailure, &params, &headers).await
}

struct NotAuthenticated;
impl IntoResponse for NotAuthenticated {
    fn into_response(self) -> axum::response::Response {
        return (StatusCode::UNAUTHORIZED, "Access over Tailscale only").into_response();
    }
}

fn ensure_authenticated<'a>(
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
        if *DEVELOPMENT.get().unwrap() {
            if let Some(user) = params.get("dev_auth_as") {
                return Ok(user);
            }
        }
    }

    Err(NotAuthenticated {}.into())
}

#[axum::debug_handler]
async fn handle_create_do(
    headers: HeaderMap,
    Query(params): Query<HashMap<String, String>>,
) -> Result<Response<Body>> {
    let owner = ensure_authenticated(
        &headers,
        #[cfg(debug_assertions)]
        &params,
    )?;

    let from = params.get("from").ok_or("Missing from query")?;
    let to = params.get("to").ok_or("Missing to query")?;

    println!("Attempting to make go/{} -> {}", from, to);

    let create_call = sqlx::query!(
        r#"
        WITH insertion AS (
            INSERT INTO direct ("from", "to", "owner")
                VALUES ($1, $2, $3)
                ON CONFLICT ("from")
                DO UPDATE SET "to" = EXCLUDED.to, "owner" = EXCLUDED.owner WHERE direct.to = $4
                RETURNING direct.from
        )
        SELECT direct.to FROM direct
        WHERE direct.from NOT IN (SELECT insertion.from FROM insertion) AND direct.from = $1
        "#, // Insert our URL, return a row with the same from that weren't updated (i.e. a conflict)
        from.to_lowercase(),
        to,
        owner,
        params.get("current"),
    )
    .fetch_optional(
        STATE
            .get()
            .expect("Server must be initialized before processing connections")
            .sqlx_connection
            .lock()
            .await
            .deref_mut(),
    )
    .await;

    if let Ok(None) = &create_call {
        Ok(Redirect::to(&format!(
            "/_/create/success?from={}&to={}",
            utf8_percent_encode(&from, NON_ALPHANUMERIC).to_string(),
            utf8_percent_encode(&to, NON_ALPHANUMERIC).to_string(),
        ))
        .into_response())
    } else if let Ok(Some(conflict)) = create_call {
        Ok(Redirect::to(&format!(
            "/_/create/conflict?from={}&to={}&current={}",
            utf8_percent_encode(&from, NON_ALPHANUMERIC).to_string(),
            utf8_percent_encode(&to, NON_ALPHANUMERIC).to_string(),
            utf8_percent_encode(&conflict.to, NON_ALPHANUMERIC).to_string(),
        ))
        .into_response())
    } else {
        Ok(Redirect::to(&format!(
            "/_/create/failure?from={}&to={}",
            utf8_percent_encode(&from, NON_ALPHANUMERIC).to_string(),
            utf8_percent_encode(&to, NON_ALPHANUMERIC).to_string(),
        ))
        .into_response())
    }
}

#[axum::debug_handler]
async fn handle_delete_do(
    headers: HeaderMap,
    Query(params): Query<HashMap<String, String>>,
) -> Result<Response<Body>> {
    ensure_authenticated(
        &headers,
        #[cfg(debug_assertions)]
        &params,
    )?;

    let from = params.get("from").ok_or("Missing from query")?;
    let current = params.get("current").ok_or("Missing current query")?;

    println!("Attempting to delete go/{} -> {}", from, current);

    let delete_call = sqlx::query!(
        r#"DELETE FROM direct WHERE direct.from = $1 AND direct.to = $2"#,
        from.to_lowercase(),
        current,
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

    if let Ok(delete_result) = &delete_call
        && delete_result.rows_affected() > 0
    {
        Ok(Redirect::to(&format!(
            "/_/delete/success?from={}&current={}",
            utf8_percent_encode(&from, NON_ALPHANUMERIC).to_string(),
            utf8_percent_encode(&current, NON_ALPHANUMERIC).to_string(),
        ))
        .into_response())
    } else {
        Ok(Redirect::to(&format!(
            "/_/delete/failure?from={}&to={}",
            utf8_percent_encode(&from, NON_ALPHANUMERIC).to_string(),
            utf8_percent_encode(&current, NON_ALPHANUMERIC).to_string(),
        ))
        .into_response())
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
        .route("/", get(handle_root))
        .route("/_/create", get(handle_create_page))
        .route("/_/create/success", get(handle_create_success_page))
        .route("/_/create/conflict", get(handle_create_conflict_page))
        .route("/_/create/failure", get(handle_create_failure_page))
        .route("/_/create/do", get(handle_create_do))
        .route("/_/delete/do", get(handle_delete_do))
        .route("/_/delete/success", get(handle_delete_success_page))
        .route("/_/delete/failure", get(handle_delete_failure_page))
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
