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
                }) submodule.config.ingredients)
                ++ [
                  (
                    {
                      system,
                      ...
                    }:
                    let
                      homeIngredientModules = lib.attrs.mapToList (
                        _: value: value.result.${system}.config.ingredient
                      ) submodule.config.homes;
                      homeIngredients = lib.lists.flatten (
                        map (lib.attrs.mapToList (
                          name: value: if value.enable && ingredientExists name then [ name ] else [ ]
                        )) homeIngredientModules
                      );
                      homeIngredientEnables = map (ingredient: {
                        config.ingredient.${ingredient}.enable = true;
                      }) homeIngredients;
                      allHomeIngredientEnables = builtins.foldl' lib.attrs.mergeRecursive { } homeIngredientEnables;
                    in
                    allHomeIngredientEnables
                  )
                ];
            };
          }
        )
      );
    };
}
