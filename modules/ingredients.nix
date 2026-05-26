# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ config, lib, ... }@nilla:
{
  options.systems.nixos =
    let
      ingredientModules = nilla.config.lib.ingredients.collectIngredientsModules ../systems { };
      ingredientExists = nilla.config.lib.ingredients.ingredientExists ../systems;
    in
    nilla.lib.options.create {
      type = nilla.lib.types.attrs.of (
        nilla.lib.types.submodule (
          { config, name, ... }@submodule:
          {
            options = {
              ingredients = nilla.lib.options.create {
                description = "Ingredients to activate for the system. Defaults to the common ingredient, the ingredient named as the system's hostname, any ingredients named after users on the system and any ingredients used in homes";
                type = nilla.lib.types.list.of (
                  nilla.lib.types.either nilla.lib.types.string nilla.lib.types.attrs.any
                );
              };

              specialisedIngredients = nilla.lib.options.create {
                description = "Ingredients to activate for specific specialisations. Note the spelling is British English to match NixOS. There is a special 'unspecialised' value to add ingredients to the default system (i.e. the one which doesn't have any specialisations)";
                type = nilla.lib.types.attrs.of (
                  nilla.lib.types.list.of (nilla.lib.types.either nilla.lib.types.string nilla.lib.types.attrs.any)
                );
              };
            };

            config = {
              ingredients = [
                "common"
                submodule.name
                (nilla.lib.strings.removePrefix "packetmix-" submodule.name)
                {
                  _type = "_homesIngredients";
                  homes = submodule.config.homes;
                }
              ];
              specialisedIngredients = builtins.zipAttrsWith (_: nilla.lib.lists.flatten) (
                [
                  {
                    unspecialised = [ "unspecialised" ];
                  }
                ]
                ++ (nilla.lib.attrs.mapToList (specialisation: homes: {
                  ${specialisation} = [
                    {
                      _type = "_homesIngredients";
                      homes = homes;
                    }
                  ];
                }) submodule.config.specialisedHomes)
              );

              modules =
                ingredientModules
                ++ (nilla.config.lib.ingredients.getIngredientsEnableModules ../systems submodule.config.ingredients
                  true
                )
                ++ nilla.lib.attrs.mapToList (
                  specialisation: ingredients:
                  if specialisation != "unspecialised" then
                    {
                      config.specialisation.${specialisation}.configuration.imports =
                        nilla.config.lib.ingredients.getIngredientsEnableModules ../systems ingredients
                          true;
                    }
                  else
                    (
                      { lib, config, ... }@nixos:
                      {
                        imports = nilla.config.lib.ingredients.getIngredientsEnableModules ../systems ingredients (
                          nixos.lib.mkIf (
                            nixos.config.specialisation != { }
                            || submodule.config.specialisedIngredients == { unspecialised = [ "unspecialised" ]; }
                          ) true
                        );
                      }
                    )
                ) submodule.config.specialisedIngredients;
            };
          }
        )
      );
    };
}
