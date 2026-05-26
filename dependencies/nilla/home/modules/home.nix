# SPDX-FileCopyrightText: 2025 Nilla Home contributors
#
# SPDX-License-Identifier: Apache-2.0

{
  lib,
  config,
  homesDir,
}:
let
  homes-type = import ./homes-type.nix { inherit lib config; };
in
{
  options.homes = lib.options.create {
    description = "Home-Manager homes to create.";
    default.value = { };
    type = homes-type;
  };
}
