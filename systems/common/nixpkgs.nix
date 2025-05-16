{ pkgs, ... }: {
  nix = {
    channel.enable = false;
    nixPath = [ "nixpkgs=/etc/nix/nixpkgs" ];
    # Inspired by this blog post from piegamesde: https://piegames.de/dumps/pinning-nixos-with-npins-revisited/
    # I've used /etc/nix as /etc/nixos would conflict with our packetmix.nix auto-upgrading...
    # Also, it feels like something adjacent to nix.conf so I think it fits better
  };

  environment.etc."nix/nixpkgs".source = builtins.storePath pkgs.path;
}
