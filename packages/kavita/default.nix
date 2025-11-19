# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
# SPDX-FileCopyrightText: 2025 Nixpkgs Maintainers
#
# SPDX-License-Identifier: MIT
{
  config.packages.kavita = {
    systems = [ "x86_64-linux" ];
    package =
      {
        kavita,
        fetchFromGitHub,
        buildNpmPackage,
        buildDotnetModule,
        dotnetCorePackages,
        ...
      }:
      kavita.overrideAttrs (
        final: prev: {
          version = "0.8.8.3";
          src = fetchFromGitHub {
            owner = prev.src.owner;
            repo = prev.src.repo;
            rev = "v${final.version}";
            hash = "sha256-Va3scgMxcLhqP+s7x/iDneCPZQCF0iOIQAfTJENcvOI=";
          };

          backend = buildDotnetModule {
            pname = "kavita-backend";
            inherit (final) version src;

            patches = [
              # The webroot is hardcoded as ./wwwroot
              ./change-webroot.diff
              # NOTE: Upstream frequently removes old database migrations between versions.
              # Currently no migration patches are needed for upgrades from NixOS 24.11 (v0.8.3.2).
              # Future updates should check if migration restoration is needed for supported upgrade paths.
            ];
            postPatch = ''
              substituteInPlace API/Services/DirectoryService.cs --subst-var out

              substituteInPlace API/Startup.cs API/Services/LocalizationService.cs API/Controllers/FallbackController.cs \
                --subst-var-by webroot "${final.frontend}/lib/node_modules/kavita-webui/dist/browser"
            '';

            executables = [ "API" ];

            projectFile = "API/API.csproj";
            nugetDeps = ./nuget-deps.json;
            dotnet-sdk = dotnetCorePackages.sdk_9_0;
            dotnet-runtime = dotnetCorePackages.aspnetcore_9_0;
          };

          frontend = buildNpmPackage {
            pname = "kavita-frontend";
            inherit (final) version src;

            sourceRoot = "${final.src.name}/UI/Web";

            npmBuildScript = "prod";
            npmFlags = [ "--legacy-peer-deps" ];
            npmRebuildFlags = [ "--ignore-scripts" ]; # Prevent playwright from trying to install browsers
            npmDepsHash = "sha256-SqW9qeg0CKfVKYsDXmVsnVNmcH7YkaXtXpPjIqGL0i0=";
          };
        }
      );
  };
}
