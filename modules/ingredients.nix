# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ config, lib, ... }@nilla:
{
  options.systems.nixos =
    let
      ingredientModules = nilla.config.lib.ingredients.collectIngredientsModules ../systems { };
    in
    nilla.lib.options.create {
      type = nilla.lib.types.attrs.of (
        nilla.lib.types.submodule (
          { config, name, ... }@submodule:
          {
            options.ingredients = nilla.lib.options.create {
              description = "Ingredients to activate for the system. Defaults to the common ingredient";
              type = nilla.lib.types.list.of nilla.lib.types.string;
            };

            config = {
              ingredients = [ "common" ];
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
