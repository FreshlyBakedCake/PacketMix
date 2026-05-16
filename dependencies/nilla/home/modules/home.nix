
{ lib, config }:
let
  inherit (config) inputs;
  homes-type = import ./homes-type.nix { inherit lib config; };
in
{
  options.homes = lib.options.create {
    description = "Home-Manager homes to create.";
    default.value = { };
    type = homes-type;
  };

  config = {
    assertions = lib.attrs.mapToList
      (name: value: {
        assertion = !(builtins.isNull value.pkgs);
        message = "A Nixpkgs instance is required for the home-manager home \"${name}\", but none was provided and \"inputs.nixpkgs\" does not exist.";
      })
      config.homes;
  };
}
