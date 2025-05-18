{ monorepo, ... }: {
  imports = [
    monorepo.inputs.impermanence.result.nixosModules.impermanence
    ./locale.nix
    ./ssh.nix
  ];
}
