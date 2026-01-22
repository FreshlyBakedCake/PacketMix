# SPDX-FileCopyrightText: 2026 Collabora Productivity Limited
#
# SPDX-License-Identifier: MIT

{ config, lib, ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks =
      let
        base = {
          user = "collabora";
          setEnv = {
            TERM = "xterm-256color";
          };
          identityFile = "~/.ssh/id_ed25519_sk_rk_tiny_yubikey_resident"; # TODO: make this work with different YubiKeys
          extraOptions = {
            WarnWeakCrypto = "no";
          };
        };

        headscale = {
          proxyCommand = "nc -X 5 -x localhost:1055 %h %p";
        };

        incus = name: {
          extraOptions = {
            RemoteCommand = "incus shell ${name}";
            RequestTTY = "yes";
            WarnWeakCrypto = "no";
          };
        };

        bee-vm = {
          proxyCommand = "ssh -o 'ForwardAgent yes' collabora-bee 'ssh-add ~/.ssh/collabora-build-key && nc %h %p'";
          identityFile = "~/.ssh/id_collabora_rsa"; # Does not accept -sk keys...
        };

        mac = {
          user = "releng";
        };

        mersenne = {
          hostname = "mersenne.hs.collaboradmins.com";
        };

        systems = {
          collabora-almalinux8 = base // bee-vm // { hostname = "10.0.3.153"; };
          collabora-almalinux8-a = incus "almalinux8-a" // base // headscale // mersenne;
          collabora-almalinux8-b = incus "almalinux8-b" // base // headscale // mersenne;
          collabora-almalinux8-c = incus "almalinux8-c" // base // headscale // mersenne;
          collabora-bee = base // headscale // { hostname = "bee.hs.collaboradmins.com"; };
          collabora-debian10android = base // bee-vm // { hostname = "10.0.3.163"; };
          collabora-eve = base // headscale // mac // { hostname = "eve.hs.collaboradmins.com"; };
          collabora-fermat = base // headscale // { hostname = "fermat.hs.collaboradmins.com"; };
          collabora-fox = base // headscale // mac // { hostname = "fox.hs.collaboradmins.com"; };
          collabora-mersenne = base // headscale // mersenne;
          collabora-prime = base // headscale // { hostname = "prime.hs.collaboradmins.com"; };
          collabora-ron = base // headscale // mac // { hostname = "ron.hs.collaboradmins.com"; };
          collabora-woz = base // headscale // mac // { hostname = "woz.hs.collaboradmins.com"; };
        };
      in
      systems
      // {
        bee = systems.collabora-bee;
        collabora-cpci = systems.collabora-prime;
        collabora-mac-mini-intel = systems.collabora-woz;
        collabora-mac-mini-m1 = systems.collabora-fox;
        collabora-mac-mini-m4-1 = systems.collabora-eve;
        collabora-mac-mini-m4-2 = systems.collabora-ron;
        cpci = systems.collabora-prime;
        eve = systems.collabora-eve;
        fermat = systems.collabora-fermat;
        fox = systems.collabora-fox;
        mersenne = systems.collabora-mersenne;
        prime = systems.collabora-prime;
        ron = systems.collabora-ron;
        woz = systems.collabora-woz;
      };
  };
}
