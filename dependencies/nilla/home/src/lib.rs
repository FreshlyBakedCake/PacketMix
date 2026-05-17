use anyhow::{Result, bail};
use regex::Regex;
use util::nix::{self, FixedOutputStoreEntry};

pub mod commands;
pub mod util;

pub struct HomeSpecifier {
    username: String,
    hostname: String,
    system: String,
}

/**
* specifier is in the format user@hostname:architecture where the @hostname and :architecture pieces are optional
*/
pub async fn parse_home_specifier(unparsed_specifier: &str) -> Result<HomeSpecifier> {
    let re = Regex::new(
        r"^$|^(?<username>[a-z][-a-z0-9]*)(?:@(?<hostname>[-A-Za-z0-9]+))?(?::(?<system>[-_A-Za-z0-9]+))?$",
    ).unwrap();
    let Some(captures) = re.captures(unparsed_specifier) else {
        bail!(
            "'{unparsed_specifier}' isn't a valid home specifier. Please match the format {{USERNAME}}[@HOSTNAME][:SYSTEM]"
        );
    };

    let system = match captures.name("system").map(|m| m.as_str().to_owned()) {
        Some(system) => system,
        None => nix::get_system().await?,
    };

    Ok(HomeSpecifier {
        username: captures
            .name("username")
            .map(|m| m.as_str().to_owned())
            .unwrap_or_else(|| whoami::username()),
        hostname: captures
            .name("hostname")
            .map(|m| m.as_str().to_owned())
            .unwrap_or_else(|| gethostname::gethostname().into_string().unwrap()),
        system,
    })
}

pub async fn get_home_specifier_and_system(
    entry: FixedOutputStoreEntry,
    unparsed_specifier: &str,
) -> Result<(String, String)> {
    let maybe_specifier = parse_home_specifier(unparsed_specifier).await;

    let specifier = match maybe_specifier {
        Ok(specifier) => specifier,
        Err(e) => return Err(e),
    };
    // We do the parse/return first as if the specifier is invalid we *shouldn't* use it - it could leak unescaped quotes into our attributes, say

    let HomeSpecifier {
        username,
        hostname,
        system,
    } = specifier;

    if !unparsed_specifier.is_empty() {
        // We always use what the user actually said first - that way you can override our detection
        match nix::exists_in_project(
            "nilla.nix",
            entry.clone(),
            &format!("homes.\"{unparsed_specifier}\""),
        )
        .await
        {
            Ok(true) => return Ok((unparsed_specifier.to_owned(), system)),
            Err(e) => return Err(e),
            Ok(false) => {}
        }
    }

    let possible_specifiers = vec![
        format!("{username}@{hostname}:{system}"),
        format!("{username}@{hostname}"),
        format!("{username}:{system}"),
        format!("{username}"),
    ];

    for possible_specifier in possible_specifiers {
        match nix::exists_in_project(
            "nilla.nix",
            entry.clone(),
            &format!("homes.\"{possible_specifier}\""),
        )
        .await
        {
            Ok(true) => return Ok((possible_specifier, system)),
            Err(e) => return Err(e),
            Ok(false) => continue,
        }
    }

    bail!("I couldn't find homes.\"{username}@{hostname}:{system}\"")
}
