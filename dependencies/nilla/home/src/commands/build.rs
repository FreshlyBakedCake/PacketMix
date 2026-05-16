use log::{debug, error, info};

use crate::{get_home_specifier_and_system, util::nix};

pub async fn build_cmd(cli: &home_cli_def::Cli, args: &home_cli_def::commands::build::BuildArgs) {
    debug!("Resolving project {}", cli.project);
    let Ok(project) = crate::util::project::resolve(&cli.project).await else {
        return error!("Could not find project {}", cli.project);
    };

    let entry = project.clone().get_entry();
    let mut path = project.get_path();

    debug!("Resolved project {path:?}");

    path.push("nilla.nix");

    match path.try_exists() {
        Ok(false) | Err(_) => return error!("File not found"),
        _ => {}
    }

    let (specifier, system) = match get_home_specifier_and_system(
        entry,
        &args.specifier.clone().unwrap_or("".to_owned()),
    )
    .await
    {
        Ok((specifier, system)) => (specifier, system),
        Err(e) => return error!("{:?}", e),
    };

    let attribute = format!("homes.\"{specifier}\".result.\"{system}\".activationPackage");

    info!("Building home {specifier}");
    let out = nix::build(
        &path,
        &attribute,
        nix::BuildOpts {
            link: true,
            report: true,
            system: Some(system.as_str()),
        },
    )
    .await;

    if let Err(e) = out {
        return error!("{:?}", e);
    };
}
