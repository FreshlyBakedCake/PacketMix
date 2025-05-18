{ monorepo, ... }: {
  imports = [
    monorepo.inputs.impermanence.result.nixosModules.impermanence
  ];
}
