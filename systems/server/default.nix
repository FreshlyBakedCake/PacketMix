{ monorepo, ... }: {
  imports = [
    ./boot.nix
    monorepo.inputs.impermanence.result.nixosModules.impermanence
  ];
}
