{ monorepo, pkgs, lib, ... }: {
  nix = {
    channel.enable = false;
    nixPath = [ "/etc/nix/inputs" ];
    # Inspired by this blog post from piegamesde: https://piegames.de/dumps/pinning-nixos-with-npins-revisited/
    # I've used /etc/nix as /etc/nixos would conflict with our packetmix.nix auto-upgrading...
    # Also, it feels like something adjacent to nix.conf so I think it fits better
  };

  environment.etc = lib.mapAttrs' (name: value: {
    name = "nix/inputs/${name}";
    value.source = if (lib.strings.isStringLike value.result) && (lib.strings.hasStorePathPrefix (builtins.toString value.result))
                   then builtins.storePath value.result
                   else builtins.storePath value.src;
  }) monorepo.inputs;
}
