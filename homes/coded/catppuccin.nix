{ monorepo, ... }: {
  imports = [ monorepo.inputs.catppuccin.result.homeModules.catppuccin ];
  config.catppuccin = {
    flavor = "macchiato";
    accent = "blue";
    enable = true;
  };
}
