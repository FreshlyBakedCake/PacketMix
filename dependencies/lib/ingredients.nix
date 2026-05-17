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
    # this: {wrapper -> path -> overrideArgs -> moduleToWrap -> outModule}
    #
    # wrapper: {moduleArgs -> normalizedModuleAttrset -> moduleAttrset} a function which takes an applied module and returns an unapplied module
    # path: {string} a "path" that'll appear as "virtual:packetmix/wrapped/${path}" in evaluation failures for this module
    # overrideArgs: an attrset of arguments to override the defaults. Similar to specialArgs and co
    # moduleToWrap: {moduleArgs -> moduleAttrset | moduleAttrset} the module for which the wrapper will wrap the moduleAttrset
    # outModule: {moduleArgs -> moduleAttrset} the wrapped module
    # moduleArgs: the standard arguments to a module, including standard arguments (lib, pkgs, etc.), extraArgs, etc.
    # moduleAttrset: {normalizedModuleAttrset | shorthandModuleAttrset} the attrset to a module
    # normalizedModuleAttrset: a module attrset that has been normalized to have either config or options as a top-level option
    # shorthandModuleAttrset: a module attrset that has its config as shorthand properties (and contains no options)
    wrapModule =
      wrapper: path: overrideArgs: moduleToWrap:
      if builtins.isFunction moduleToWrap then
        let
          wrapped =
            args:
            let
              moduleArgs = builtins.intersectAttrs (nixpkgs.lib.functionArgs moduleToWrap) (args // overrideArgs);
              moduleAttrset = moduleToWrap moduleArgs;

              wrappedModule = this.wrapModule wrapper path overrideArgs moduleAttrset; # overrideArgs doesn't really matter at this point since as the other branch won't use it ... but we may as well
              wrapperArgs = builtins.intersectAttrs (nixpkgs.lib.functionArgs wrapper) (args // overrideArgs);
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
    # this: {name -> subpath -> overrideArgs -> moduleToWrap -> outModule}
    #
    # name: {string} the name of the ingredient, used as the enable option and as "virtual:packetmix/wrapped/ingredient/${name}/${subpath}" in evaluation failures for this module
    # subpath: {string} a more specific name for the module - e.g. filename.nix - used as "virtual:packetmix/wrapped/ingredient/${name}/${subpath}" in evaluation failures for this module
    # overrideArgs: an attrset of arguments to override the defaults. Similar to specialArgs and co
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

    # Gets modules for a specific ingredient, based on a base directory, a name and any argument overrides
    # Includes a declaration of options.ingredient.${name}.enable and auto-imports for all modules in ${ingredientDirectory}/${name}, mkIfed behind that enable option
    #
    # this: {ingredientsDirectory -> overrideArgs -> name -> outModule[]}
    #
    # ingredientsDirectory: {path} the path in which your ingredients reside
    # overrideArgs: an attrset of arguments to override the defaults. Similar to specialArgs and co
    # name: {string} the name of the ingredient
    # outModule[]: {(moduleArgs -> normalizedModuleAttrset | normalizedModuleAttrset)[]} modules for the ingredient, with their config conditionally-enabled on the ingredient being enabled
    # moduleArgs: the standard arguments to a module, including standard arguments (lib, pkgs, etc.), extraArgs, etc.
    # normalizedModuleAttrset: a module attrset that has been normalized to have either config or options as a top-level option
    collectIngredientModules =
      ingredientsDirectory: overrideArgs: name:
      let
        ingredientDirectoryListing = builtins.readDir "${ingredientsDirectory}/${name}";
        ingredientNixFiles = nilla.lib.attrs.filter (
          name: value: nilla.lib.strings.hasSuffix ".nix" name && value == "regular"
        ) ingredientDirectoryListing;
        ingredientNixFileSubpaths = builtins.attrNames ingredientNixFiles;
        modules = map (
          subpath:
          this.mkIngredientModule name subpath overrideArgs (
            import "${ingredientsDirectory}/${name}/${subpath}"
          )
        ) ingredientNixFileSubpaths;
      in
      modules
      ++ [
        {
          options.ingredient.${name}.enable = nixpkgs.lib.mkEnableOption "the ${name} ingredient";
        }
      ]
      ++ (
        if nilla.lib.strings.hasInfix "+" name then
          [
            (
              { config, ... }@module:
              {
                config.ingredient.${name}.enable =
                  let
                    components = nilla.lib.strings.split "+" name;
                    shouldEnable = builtins.all (component: module.config.ingredient.${component}.enable) components;
                  in
                  nixpkgs.lib.mkIf shouldEnable true;
              }
            )
          ]
        else
          [ ]
      );

    # Gets the names of all ingredients, based on just a directory
    #
    # this: {ingredientsDirectory -> moduleName[]}
    #
    # ingredientsDirectory: {path} the path in which your ingredients reside
    # moduleName[]: {string[]} names of all ingredients in your ingredientsDirectory
    getIngredientsNames =
      ingredientsDirectory:
      let
        ingredientsDirectoryListing = builtins.readDir ingredientsDirectory;
        ingredientSubdirectories = nilla.lib.attrs.filter (
          _: value: value == "directory"
        ) ingredientsDirectoryListing;
        ingredientNames = builtins.attrNames ingredientSubdirectories;
      in
      ingredientNames;

    # Gets modules for all ingredients, based on just a directory and any argument overrides
    # Includes all required option declarations (under options.ingredient.${name}.enable for each ingredient) and conditional auto-imports
    # Includes any options, imports, etc. that are defined in *any* ingredient, even if it is not enabled
    #
    # this: {ingredientsDirectory -> overrideArgs -> outModule[]}
    # ingredientsDirectory: {path} the path in which your ingredients reside
    # name: {string} the name of the ingredient
    # overrideArgs: an attrset of arguments to override the defaults. Similar to specialArgs and co
    # outModule[]: {(moduleArgs -> normalizedModuleAttrset | normalizedModuleAttrset)[]} modules for all ingredients, with their config conditionally-enabled on their ingredient being enabled
    # moduleArgs: the standard arguments to a module, including standard arguments (lib, pkgs, etc.), extraArgs, etc.
    # normalizedModuleAttrset: a module attrset that has been normalized to have either config or options as a top-level option
    collectIngredientsModules =
      ingredientsDirectory: overrideArgs:
      let
        ingredientNames = this.getIngredientsNames ingredientsDirectory;
        modules = map (this.collectIngredientModules ingredientsDirectory overrideArgs) ingredientNames;
      in
      nilla.lib.lists.flatten modules;

    # Gets whether an ingredient exists, based on a directory name and a
    #
    # this: {ingredientsDirectory -> name -> exists}
    #
    # ingredientsDirectory: {path} the path in which your ingredients reside
    # name: {string} the name of the ingredient to search for
    # exists: {boolean} whether that ingredient exists
    ingredientExists =
      ingredientsDirectory: name: builtins.elem name (this.getIngredientsNames ingredientsDirectory);
  };
}
