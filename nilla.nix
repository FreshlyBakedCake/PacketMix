# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

let
  pins = import ./npins;

  nilla = import pins.nilla;

  settings = config: {
    nixpkgs = {
      configuration.allowUnfree = true;
      overlays = [
        config.inputs.fenix.result.overlays.default
      ];
    };
    "nixos-24.11" = (settings config).nixpkgs;
    nixos-unstable = (settings config).nixpkgs;
  };

  name =
    let
      lib = result.config.lib;

      imported = import ./project.nix;

      args = builtins.functionArgs imported;
      argNames = builtins.attrNames args;
      nonDefaultArgNames = builtins.filter (name: !args.${name}) argNames;

      nullArgs = lib.attrs.generate nonDefaultArgNames (_: null);

      calledProject = imported nullArgs;

      project = if builtins.isFunction imported then calledProject else imported;
    in
    project.config.name;

  result = (nilla.create [ ]).extend {
    modules = [
      ./project.nix
      (
        { config, ... }:
        {
          config.inputs =
            config.lib.attrs.generate (builtins.filter (name: name != "__functor") (builtins.attrNames pins))
              (name: {
                src = pins.${name};
                settings = (settings config).${name} or config.lib.constants.undefined;
              });
        }
      )
      (
        { config, ... }:
        {
          options.name = config.lib.options.create {
            description = "The names of all included subprojects";
            type = config.lib.types.coerce config.lib.types.string (val: [ val ]) (
              config.lib.types.list.of config.lib.types.string
            );
          };
        }
      )
    ]
    ++ (
      if (builtins.readDir ./.) ? "dependencies" then
        let
          dependenciesDir = ./dependencies;
          dependencies = builtins.attrNames (builtins.readDir dependenciesDir);
          depedencyFiles = map (name: "${./dependencies}/${name}/project.nix") dependencies;
        in
        depedencyFiles
      else
        [ ]
    );

    args = {
      inherit nilla pins; # pins needs to be a static arg for us to import from it...
    };
  };

  aliases =
    let
      ## Get all attrs with a prefix, returning a new attrset without that prefix. For example:
      ## selectPrefixedAttrs "abcd" { abcdefg = "adcdefg"; abcd = "abcd"; different = "different"; fooabcd = "fooabcd"; }
      ## -> { efg = "abcdefg"; "" = "abcd"; }
      selectPrefixedAttrs =
        lib: prefix: attrs:
        let
          attrNames = builtins.attrNames attrs;
          validNames = builtins.filter (lib.strings.hasPrefix prefix) attrNames;
          unprefixedNames = map (lib.strings.removePrefix prefix) validNames;
        in
        lib.attrs.generate unprefixedNames (name: attrs.${prefix + name});
      aliased =
        config: old:
        old
        // (
          if (builtins.hasAttr name old) then
            {
              default = old.${name};
            }
          else
            { }
        )
        // selectPrefixedAttrs config.lib "${name}-" old;
    in
    {
      homes = aliased result.config result.config.homes;
      packages = aliased result.config result.config.packages;
      shells = aliased result.config result.config.shells;
      systems.nixos = aliased result.config result.config.systems.nixos;
    };
in
(result.config.lib.attrs.mergeRecursive aliases result.config)
// {
  extend = result.extend;
  unalias = result.config // {
    extend = result.extend;
  };
}
