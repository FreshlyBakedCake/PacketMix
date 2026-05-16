use clap::Args;
#[derive(Debug, Args)]
#[command(about = "Build a home")]
pub struct BuildArgs {
    #[arg(help = "Home specifier, in the format {username}[@hostname][:system]")]
    pub specifier: Option<String>,
}
