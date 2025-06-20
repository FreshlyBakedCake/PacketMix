# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  project,
  pkgs,
  lib,
  ...
}:
{
  nix = {
    channel.enable = false;
    nixPath = [ "/etc/nix/inputs" ];
    # Inspired by this blog post from piegamesde: https://piegames.de/dumps/pinning-nixos-with-npins-revisited/
    # I've used /etc/nix as /etc/nixos would conflict with our packetmix.nix auto-upgrading...
    # Also, it feels like something adjacent to nix.conf so I think it fits better
  };

  environment.etc = lib.mapAttrs' (name: value: {
    name = "nix/inputs/${name}";
    value.source =
      if
        (lib.strings.isStringLike value.result)
        && (lib.strings.hasPrefix builtins.storeDir (builtins.toString value.result)) # We convert to a string here to force paths out of any attrsets/etc.
      then
        builtins.storePath value.result
      else
        builtins.storePath value.src;
  }) project.inputs;
}
