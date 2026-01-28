// SPDX-FileCopyrightText: 2026 Freshly Baked Cake
//
// SPDX-License-Identifier: MIT
use axum::{http::HeaderMap, response::Html, response::Result};
use percent_encoding::{NON_ALPHANUMERIC, utf8_percent_encode};
use regex::Captures;
use std::collections::HashMap;
#[cfg(debug_assertions)]
use std::fs;
use tower_sessions::Session;

use crate::{auth::get_token, clean_host, direct, ensure_authenticated};

/// include_str, but if DEVELOPMENT then the string is dynamically fetched for easy reloading
/// to support this, the string is *always* owned.
#[cfg(debug_assertions)]
macro_rules! include_String_dynamic {
    ($file:expr $(,)?) => {
        if (*crate::DEVELOPMENT.get().unwrap()) {
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

#[derive(Clone)]
enum AnyString<'a> {
    Owned(String),
    Ref(&'a str),
}

#[derive(Clone)]
pub(crate) enum StaticPageType {
    Create,
    CreateConflict,
    CreateFailure,
    CreateSuccess,
    DeleteFailure,
    DeleteSuccess,
    Index,
}

pub(crate) async fn handle_static_page<'a>(
    page_type: StaticPageType,
    session: Session,
    params: &'a HashMap<String, String>,
    headers: &'a HeaderMap,
) -> Result<Html<String>> {
    let auth_required = match page_type {
        _ => true,
    };

    let html = match page_type {
        StaticPageType::Create => include_String_dynamic!("./html/create.html"),
        StaticPageType::CreateConflict => include_String_dynamic!("./html/create/conflict.html"),
        StaticPageType::CreateFailure => include_String_dynamic!("./html/create/failure.html"),
        StaticPageType::CreateSuccess => include_String_dynamic!("./html/create/success.html"),
        StaticPageType::DeleteFailure => include_String_dynamic!("./html/delete/failure.html"),
        StaticPageType::DeleteSuccess => include_String_dynamic!("./html/delete/success.html"),
        StaticPageType::Index => include_String_dynamic!("./html/index.html"),
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

    let mut replacements: HashMap<&str, Box<dyn 'a + Send + Fn() -> Option<AnyString<'a>>>> =
        HashMap::new();
    replacements.insert(
        "host",
        Box::new(|| {
            Some(AnyString::Ref(clean_host(
                headers
                    .get("host")
                    .and_then(|header| Some(header.to_str().unwrap_or_else(|_| "go")))
                    .unwrap_or_else(|| "go"),
            )))
        }),
    );
    replacements.insert(
        "from",
        Box::new(|| {
            params
                .get("from")
                .and_then(|from| Some(AnyString::Ref(from.as_str())))
        }),
    );
    replacements.insert(
        "to",
        Box::new(|| {
            params
                .get("to")
                .and_then(|to| Some(AnyString::Ref(to.as_str())))
        }),
    );
    replacements.insert(
        "current",
        Box::new(|| {
            params
                .get("current")
                .and_then(|current| Some(AnyString::Ref(current.as_str())))
        }),
    );
    replacements.insert(
        "username",
        Box::new(move || username.and_then(|name| Some(AnyString::Ref(name)))),
    );

    let token = get_token(&session).await;
    if matches!(page_type, StaticPageType::Index) {
        let link_table = direct::get_link_table(&token).await?;

        replacements.insert(
            "links",
            Box::new(move || Some(AnyString::Owned(link_table.clone()))),
        );
    }

    replacements.insert(
        "token",
        Box::new(move || Some(AnyString::Owned(token.clone()))),
    );

    let result = template_html(html, replacements);
    Ok(Html(result))
}

fn template_html<'a>(
    html: String,
    replacements: HashMap<&str, Box<dyn 'a + Send + Fn() -> Option<AnyString<'a>>>>,
) -> String {
    let re = regex_static::static_regex!(r"\{([a-z_]+)(?::([a-z_]+))?\}");
    re.replace_all(&html, |captures: &Captures| {
        let replacement_name = &captures[1];
        let replacement = replacements
            .get(replacement_name)
            .and_then(|maybe_replacement| maybe_replacement())
            .unwrap_or_else(|| AnyString::Ref(""))
            .clone();
        let replacement_owned = match replacement {
            AnyString::Owned(owned) => owned,
            AnyString::Ref(str) => str.to_string(),
        };

        match captures.get(2).and_then(|m| Some(m.as_str())) {
            Some("dangerous_raw") => replacement_owned,
            Some("attribute") => {
                html_escape::encode_quoted_attribute(&replacement_owned).to_string()
            }
            Some("url") => utf8_percent_encode(&replacement_owned, NON_ALPHANUMERIC).to_string(),
            None => html_escape::encode_text(&replacement_owned).to_string(),
            Some(_) => "UNKNOWN_MATCH_TYPE".to_string(),
        }
    })
    .to_string()
}
