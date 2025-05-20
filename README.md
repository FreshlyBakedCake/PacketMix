<!--
SPDX-FileCopyrightText: 2025 FreshlyBakedCake

SPDX-License-Identifier: MIT
-->

# PacketMix

# Principles

## Automatic updates

Your system should always be up-to-date. Therefore, we'll update your system
each day ready for you to reboot into.

## Uptime is an antipattern

Not everything can be updated out-from-under-your-feet and even when it can be
traces are often left behind (think: old environment variables, version
mismatches between running and new programs, missing kernel updates, etc.).

Therefore, `nilla nixos switch` (& `nixos-rebuild switch`) are officially
unsupported. Use them if you must, but report bugs only if you've tried
rebooting into your newly-updated system.

Our auto-updates will always require a reboot to finish installing.

## Opinionated

We build this because we want this. Any configuration that is no longer used
will be removed. We will ruthlessly set defaults (e.g. `--smart-case` for
`ripgrep`) to align with our preferences. If you disagree with our choices,
override our config or pull a module out of our tree and maintain it yourself.

<!-- ## Composition of configs

PacketMix is built with [Mixins](./docs/mixins.md) so you can pull in
pre-defined sets of configuration for different purposes. Want a gaming
machine? Install Steam and Itch off the bat. Choosing catppuccin as your theme?
Make sure all your apps start with configurations for it.

Mixins are additive, so by default you'll only start with the required
PacketMix base.

Of course, if you want more configurability - say you want to install Steam
without any other games launchers - you can break out into your own modules and
get the full power of nix alongside your PacketMix. -->
