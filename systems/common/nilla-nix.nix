{ monorepo, system, ... }: {
  environment.systemPackages = [
    monorepo.inputs.nilla-cli.result.packages.nilla-cli.result.${system}
    monorepo.inputs.nilla-home.result.packages.nilla-home.result.${system}
    monorepo.inputs.nilla-nixos.result.packages.nilla-nixos.result.${system}
  ];
}
