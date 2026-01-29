// SPDX-FileCopyrightText: 2026 Freshly Baked Cake
//
// SPDX-License-Identifier: MIT

use axum::response::{Redirect, Result};
use percent_encoding::{NON_ALPHANUMERIC, utf8_percent_encode};
use regex::RegexBuilder;
use std::ops::DerefMut;

use crate::{CreationResult, DeletionResult, STATE};

struct Link {
    from: String,
    to: String,
    owner: String,
}

pub(crate) async fn get_redirect(go: &str) -> Option<Redirect> {
    let redirect = sqlx::query!(
        r#"SELECT "from", "to" FROM regex WHERE $1 ~* ('^(?:' || "from" || ')$') LIMIT 1"#,
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
        let re = RegexBuilder::new(&format!("^(?:{})$", record.from))
            .case_insensitive(true)
            .build()
            .unwrap();
        let to = re.replace(go, record.to);
        Some(Redirect::temporary(&to))
    } else {
        None
    }
}

pub(crate) async fn get_link_table(token: &str) -> Result<String> {
    let links_query = sqlx::query_as!(
        Link,
        r#"SELECT "from", "to", "owner" FROM regex ORDER BY regex."from" ASC"#,
    )
    .fetch_all(
        STATE
            .get()
            .expect("Server must be initialized before processing connections")
            .sqlx_connection
            .lock()
            .await
            .deref_mut(),
    )
    .await;

    let Ok(links) = links_query else {
        return Err("Failed to query database".into());
    };

    let mut rows = vec![];

    for link in links {
        let from = html_escape::encode_text(&link.from);
        let from_url = utf8_percent_encode(&link.from, NON_ALPHANUMERIC);
        let to = html_escape::encode_text(&link.to);
        let to_url = utf8_percent_encode(&link.to, NON_ALPHANUMERIC);
        let owner = html_escape::encode_text(&link.owner);

        rows.push(format!(
                r#"<tr>
                    <td><code>{from}</code></td>
                    <td><code>{to}</code></td>
                    <td>{owner}</td>
                    <td>(<a href="/_/create?from={from_url}&to={to_url}&current={to_url}&format=regex">edit</a>) (<a href="/_/delete/do?from={from_url}&current={to_url}&token={token}&format=regex">delete</a>)</td>
                </tr>"#,
            ));
    }

    let link_table = rows.join("\n");

    Ok(link_table)
}

pub(crate) async fn create(
    from: &str,
    to: &str,
    owner: &str,
    current: Option<&String>,
) -> CreationResult {
    println!("Attempting to make go/{} -> {}", from, to);

    let create_call = sqlx::query!(
        r#"
        WITH insertion AS (
            INSERT INTO regex ("from", "to", "owner")
                VALUES ($1, $2, $3)
                ON CONFLICT ("from")
                DO UPDATE SET "to" = EXCLUDED.to, "owner" = EXCLUDED.owner WHERE regex.to = $4
                RETURNING regex.from
        )
        SELECT regex.to FROM regex
        WHERE regex.from NOT IN (SELECT insertion.from FROM insertion) AND regex.from = $1
        "#, // Insert our URL, return a row with the same from that weren't updated (i.e. a conflict)
        from.to_lowercase(),
        to,
        owner,
        current,
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
        CreationResult::Success
    } else if let Ok(Some(conflict)) = create_call {
        CreationResult::Conflict(conflict.to)
    } else {
        CreationResult::Failure
    }
}

pub(crate) async fn delete(from: &str, current: &str) -> DeletionResult {
    println!("Attempting to delete go/{} -> {}", from, current);

    let delete_call = sqlx::query!(
        r#"DELETE FROM regex WHERE regex.from = $1 AND regex.to = $2"#,
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

    let Ok(delete_result) = &delete_call else {
        return DeletionResult::Failure;
    };

    if delete_result.rows_affected() > 0 {
        DeletionResult::Success
    } else {
        DeletionResult::NotFound
    }
}
