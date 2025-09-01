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
            options.ingredients = nilla.lib.options.create {
              description = "Ingredients to activate for the system. Defaults to the common ingredient, as well as the ingredient named as the system's hostname if it exists";
              type = nilla.lib.types.list.of nilla.lib.types.string;
            };

            config = {
              ingredients = [ "common" ] ++ (if ingredientExists name then [ name ] else [ ]);
              modules =
                ingredientModules
                ++ (map (ingredient: {
                  config.ingredient.${ingredient}.enable = true;
                }) submodule.config.ingredients);
            };
          }
        )
      );
    };
}
