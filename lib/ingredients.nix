# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ lib, config, ... }@nilla:
let
  nixpkgs = config.inputs.nixpkgs.result;
  this = nilla.config.lib.ingredients;
in
{
  config.lib.ingredients = {
    # Normalizes a potentially-shorthand module attrset to pull its config into a config attribute
    #
    # this: {moduleAttrset -> normalizedModuleAttrset}
    #
    # moduleAttrset: {normalizedModuleAttrset | shorthandModuleAttrset} the attrset to a module
    # normalizedModuleAttrset: a module attrset that has been normalized to have either config or options as a top-level option
    # shorthandModuleAttrset: a module attrset that has its config as shorthand properties (and contains no options)
    normalizeModule =
      moduleAttrset:
      if moduleAttrset ? config || moduleAttrset ? options then
        # module is already normalized
        moduleAttrset
      else
        {
          config = builtins.removeAttrs moduleAttrset [
            "disabledModules"
            "freeformType"
            "imports"
            # there can't be options at this point...
          ];
          disabledModules = moduleAttrset.disabledModules or [ ];
          freeformType = moduleAttrset.freeformType or null;
          imports = moduleAttrset.imports or [ ];
          options = { };
        };

    # Lets you wrap a module without worrying about if the module you're wrapping is a function or an attrset
    #
    # this: {wrapper -> path -> moduleToWrap -> outModule}
    #
    # wrapper: {moduleArgs -> normalizedModuleAttrset -> moduleAttrset} a function which takes an applied module and returns an unapplied module
    # path: {string} a "path" that'll appear as "virtual:packetmix/wrapped/${path}" in evaluation failures for this module
    # moduleToWrap: {moduleArgs -> moduleAttrset | moduleAttrset} the module for which the wrapper will wrap the moduleAttrset
    # outModule: {moduleArgs -> moduleAttrset} the wrapped module
    # moduleArgs: the standard arguments to a module, including standard arguments (lib, pkgs, etc.), extraArgs, etc.
    # moduleAttrset: {normalizedModuleAttrset | shorthandModuleAttrset} the attrset to a module
    # normalizedModuleAttrset: a module attrset that has been normalized to have either config or options as a top-level option
    # shorthandModuleAttrset: a module attrset that has its config as shorthand properties (and contains no options)
    wrapModule =
      wrapper: path: moduleToWrap:
      if builtins.isFunction moduleToWrap then
        let
          wrapped =
            args:
            let
              moduleArgs = builtins.intersectAttrs (nixpkgs.lib.functionArgs moduleToWrap) args;
              moduleAttrset = moduleToWrap moduleArgs;

              wrappedModule = this.wrapModule wrapper path moduleAttrset;
              wrapperArgs = builtins.intersectAttrs (nixpkgs.lib.functionArgs wrapper) args;
            in
            wrappedModule wrapperArgs;
        in
        nixpkgs.lib.setFunctionArgs wrapped (
          nixpkgs.lib.functionArgs moduleToWrap // nixpkgs.lib.functionArgs wrapper
        )
      else
        let
          wrapped =
            args:
            {
              _file = "virtual:packetmix/wrapped/${path}";
            }
            // (wrapper args (this.normalizeModule moduleToWrap));
        in
        nixpkgs.lib.setFunctionArgs wrapped (nixpkgs.lib.functionArgs wrapper);

    # Wraps a module so it is enabled by the config.ingredient.${name}.enable option
    #
    # Everything *except* the config, for example options, imports,
    # disabledModules, etc. *will always be applied* so they probably shouldn't have a
    # visible effect on the system
    #
    # this: {name -> subpath -> moduleToWrap -> outModule}
    #
    # name: {string} the name of the ingredient, used as the enable option and as "virtual:packetmix/wrapped/ingredient/${name}/${subpath}" in evaluation failures for this module
    # subpath: {string} a more specific name for the module - e.g. filename.nix - used as "virtual:packetmix/wrapped/ingredient/${name}/${subpath}" in evaluation failures for this module
    # moduleToWrap: {moduleArgs -> moduleAttrset | moduleAttrset} the module which should be enabled by config.ingredient.${name}.enable
    # outModule: {moduleArgs -> normalizedModuleAttrset} the wrapped module
    # moduleArgs: the standard arguments to a module, including standard arguments (lib, pkgs, etc.), extraArgs, etc.
    # moduleAttrset: {normalizedModuleAttrset | shorthandModuleAttrset} the attrset to a module
    # normalizedModuleAttrset: a module attrset that has been normalized to have either config or options as a top-level option
    # shorthandModuleAttrset: a module attrset that has its config as shorthand properties (and contains no options)
    mkIngredientModule =
      name: subpath:
      this.wrapModule (
        { config, ... }@module:
        moduleToWrap:
        moduleToWrap
        // {
          config = nixpkgs.lib.mkIf module.config.ingredient.${name}.enable (moduleToWrap.config or { });
        }
      ) "ingredient/${name}/${subpath}";

    # Gets modules for a specific ingredient, based on a base directory and a name
    # Includes a declaration of options.ingredient.${name}.enable and auto-imports for all modules in ${ingredientDirectory}/${name}, mkIfed behind that enable option
    #
    # this: {ingredientsDirectory -> name -> outModule[]}
    #
    # ingredientsDirectory: {path} the path in which your ingredients reside
    # name: {string} the name of the ingredient
    # outModule[]: {(moduleArgs -> normalizedModuleAttrset | normalizedModuleAttrset)[]} modules for the ingredient, with their config conditionally-enabled on the ingredient being enabled
    # moduleArgs: the standard arguments to a module, including standard arguments (lib, pkgs, etc.), extraArgs, etc.
    # normalizedModuleAttrset: a module attrset that has been normalized to have either config or options as a top-level option
    collectIngredientModules =
      ingredientsDirectory: name:
      let
        ingredientDirectoryListing = builtins.readDir "${ingredientsDirectory}/${name}";
        ingredientNixFiles = nilla.lib.attrs.filter (
          name: value: nilla.lib.strings.hasSuffix ".nix" name && value == "regular"
        ) ingredientDirectoryListing;
        ingredientNixFileSubpaths = builtins.attrNames ingredientNixFiles;
        modules = map (
          subpath: this.mkIngredientModule name subpath (import "${ingredientsDirectory}/${name}/${subpath}")
        ) ingredientNixFileSubpaths;
      in
      modules
      ++ [
        {
          options.ingredient.${name}.enable = nixpkgs.lib.mkEnableOption "the ${name} ingredient";
        }
      ];

    # Gets modules for all ingredients, based on just a directory
    # Includes all required option declarations (under options.ingredient.${name}.enable for each ingredient) and conditional auto-imports
    # Includes any options, imports, etc. that are defined in *any* ingredient, even if it is not enabled
    #
    # this: {ingredientsDirectory -> outModule[]}
    # ingredientsDirectory: {path} the path in which your ingredients reside
    # name: {string} the name of the ingredient
    # outModule[]: {(moduleArgs -> normalizedModuleAttrset | normalizedModuleAttrset)[]} modules for all ingredients, with their config conditionally-enabled on their ingredient being enabled
    # moduleArgs: the standard arguments to a module, including standard arguments (lib, pkgs, etc.), extraArgs, etc.
    # normalizedModuleAttrset: a module attrset that has been normalized to have either config or options as a top-level option
    collectIngredientsModules =
      ingredientsDirectory:
      let
        ingredientsDirectoryListing = builtins.readDir ingredientsDirectory;
        ingredientSubdirectories = nilla.lib.attrs.filter (
          _: value: value == "directory"
        ) ingredientsDirectoryListing;
        ingredientNames = builtins.attrNames ingredientSubdirectories;
        modules = map (this.collectIngredientModules ingredientsDirectory) ingredientNames;
      in
      nilla.lib.lists.flatten modules;
  };
}
