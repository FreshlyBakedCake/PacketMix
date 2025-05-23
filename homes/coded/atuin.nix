{
  programs.atuin = {
    enable = true;
    daemon.enable = true;
    enableBashIntegration = true;
    settings = {
      search_mode_shell_up_key_binding = "fulltext";
      workspaces = true;
      enter_accept = true;

      common_subcommands = [
        "cargo"
        "git"
        "go"
        "ip"
        "jj"
        "nix"
        "nilla"
        "npm"
        "pnpm"
        "systemctl"
        "tmux"
      ];
    };
  };
}
