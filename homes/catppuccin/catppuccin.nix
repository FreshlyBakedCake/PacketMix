{ project, ... }: {
  imports = [ project.inputs.catppuccin.result.homeModules.catppuccin ];
  config.catppuccin.enable = true;
}
