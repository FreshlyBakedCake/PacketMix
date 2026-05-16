use clap::Args;

#[derive(Debug, Args)]
#[command(about = "Build, install, and switch into a home")]
pub struct SwitchArgs {
    #[arg(help = "Home specifier, in the format {username}[@hostname][:system]")]
    pub specifier: Option<String>,
}
