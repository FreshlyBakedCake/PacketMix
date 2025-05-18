{ monorepo, ... }: {
  imports = [
    monorepo.inputs.lix-module.result.nixosModules.default
  ];
}
