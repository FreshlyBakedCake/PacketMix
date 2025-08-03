# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{ config, ... }:
{
  config.packages.lua-multipart = {
    systems = [ "x86_64-linux" ];

    package =
      {
        lib,
        luaPackages,
        ...
      }:
      luaPackages.buildLuarocksPackage {
        pname = "multipart";
        version = config.inputs.lua-multipart.src.version;

        src = config.inputs.lua-multipart.src;

        meta = {
          homepage = "https://github.com/Kong/lua-multipart";
          description = "Multipart Parser for Lua";
          maintainers = [ lib.maintainers.minion3665 ];
          license = lib.licenses.mit;
        };
      };
  };
}
