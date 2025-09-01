# SPDX-FileCopyrightText: 2025 Collabora Productivity Limited
# SPDX-FileCopyrightText: 2025 FreshlyBakedCake
#
# SPDX-License-Identifier: MIT

{
  config,
  lib,
  project,
  pkgs,
  system,
  ...
}:
{
  options.jujutsu = {
    allowedSSHSigners = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf lib.types.str);
      description = "A mapping of SSH keys to emails they are valid for";
      default = { };
    };
  };

  config = {
    ingredient.scriptfs.enable = true; # used for signing configuration
    programs.jujutsu = {
      enable = true;
      package = project.packages.jujutsu.result.${system};
      settings = {
        aliases = {
          init = [
            "git"
            "init"
            "--colocate"
          ]; # TODO: remove when git is no longer the only backend

          clean = [
            "abandon"
            "-r"
            "empty() & ~::immutable_heads() & ~bookmarks()"
          ]; # Delete commits that are no longer useful - less important after jujutsu includes its change IDs in commits

          tug =
            let
              tug-script = pkgs.writeScript "tug.sh" ''
                #!${pkgs.bash}/bin/bash

                set -e

                if [[ -z "$1" ]]; then
                  ${config.programs.jujutsu.package}/bin/jj bookmark move --from "closest_bookmark(@)" --to "closest_pushable_allow_empty_desc(@)"
                else
                  ${config.programs.jujutsu.package}/bin/jj bookmark move --to "closest_pushable_allow_empty_desc(@)" "$@"
                fi
              '';
            in
            [
              "util"
              "exec"
              "--"
              tug-script
            ]; # Move the nearest bookmark up to a commit

          t = [
            "log"
            "-r"
            "touched()"
          ];
          touched = [
            "log"
            "-r"
            "touched()"
          ];

          evol = [ "evolution-log" ]; # `evol` is what you get to when you try to tab complete from `ev`, as you stop between `evolog` and `evolution-log`

          ia = [
            "new"
            "--no-edit"
            "--after"
          ]; # short for jj insertafter, good for megamerges

          here = [
            "log"
            "-r"
            "here"
          ];
          hereish = [
            "log"
            "-r"
            "here | trunk() | here-"
          ]; # Show commits that are generally around @ - a less noisy alternative to the default log revset

          stat = [
            "show"
            "--stat"
          ];

          copy = [
            "util"
            "exec"
            "--"
            "${pkgs.bash}/bin/bash"
            "-c"
            "${config.programs.jujutsu.package}/bin/jj show --git $@ | ${pkgs.wl-clipboard}/bin/wl-copy"
            "--"
          ]; # Copy a git-compatible patch to your clipboard

          rangediff =
            let
              rangediff-script = pkgs.writeScript "rangediff.sh" ''
                #!${pkgs.bash}/bin/bash

                set -e

                BEFORE_REVSET="$1"
                shift || (echo "Usage !!BEFORE_REVSET!! AFTER_REVSET BEFORE_LENGTH [AFTER_LENGTH] [...ARGS]"; exit 1)
                AFTER_REVSET="$1"
                shift || (echo "Usage BEFORE_REVSET !!AFTER_REVSET!! BEFORE_LENGTH [AFTER_LENGTH] [...ARGS]"; exit 1)
                BEFORE_LENGTH="$1"
                shift || (echo "Usage BEFORE_REVSET AFTER_REVSET !!BEFORE_LENGTH!! [AFTER_LENGTH] [...ARGS]"; exit 1)

                if [[ $1 =~ ^[0-9]+$ ]]; then
                  AFTER_LENGTH="$1"
                  shift
                else
                  AFTER_LENGTH="$BEFORE_LENGTH"
                fi

                BEFORE_TOP=$(${config.programs.jujutsu.package}/bin/jj show -T "self.commit_id()" --no-patch --quiet $BEFORE_REVSET)
                BEFORE_BOTTOM=$(${config.programs.jujutsu.package}/bin/jj show -T "self.commit_id()" --no-patch --quiet "back($BEFORE_REVSET, $BEFORE_LENGTH)")

                AFTER_TOP=$(${config.programs.jujutsu.package}/bin/jj show -T "self.commit_id()" --no-patch --quiet $AFTER_REVSET)
                AFTER_BOTTOM=$(${config.programs.jujutsu.package}/bin/jj show -T "self.commit_id()" --no-patch --quiet "back($AFTER_REVSET, $AFTER_LENGTH)")

                ${pkgs.git}/bin/git range-diff $BEFORE_BOTTOM~..$BEFORE_TOP $AFTER_BOTTOM~..$AFTER_TOP "$@"
              '';
            in
            [
              "util"
              "exec"
              "--"
              rangediff-script
            ]; # Use git range-diff to see the difference between some revsets, usage 'jj rangediff before-revset after-refset before-length [after-length=before-length]'

          reverthere = [
            "revert"
            "-B"
            "@"
            "-r"
          ];
          rh = [ "reverthere" ];

          resetcid =
            let
              resetcid-script = pkgs.writeScript "resetcid.sh" ''
                #!${pkgs.bash}/bin/bash

                set -e

                CID_BEFORE=$(jj show "$1" -T "self.change_id().shortest(8)" --no-patch --color=always)

                jj new --before "$1" --no-edit --quiet
                CID_AFTER=$(jj show "$1-" -T "self.change_id().shortest(8)" --no-patch --color=always)

                jj squash --from "$1" --to "($1)-" --quiet

                echo "$CID_BEFORE is now known as $CID_AFTER"
              '';
            in
            [
              "util"
              "exec"
              "--"
              resetcid-script
            ]; # Reset a change ID, useful if you are using jj change IDs in scripts/etc. - uses new/squash though duplicate with some fancy flags and abandon could probably also work
        };
        fix.tools = {
          clang-format = {
            command = [
              "clang-format"
              "--assume-filename=$path"
            ]; # Not in nix because some projects want specific versions - use a shell
            patterns = [
              "glob:'**/*.cxx'"
              "glob:'**/*.hxx'"
              "glob:'**/*.c'"
              "glob:'**/*.h'"
            ];
          };
          prettier = {
            command = [
              "prettierd"
              "--stdin-filepath=$path"
            ]; # Not in nix because some projects want specific versions - use a shell
            patterns = [
              "glob:'**/*.js'"
              "glob:'**/*._js'"
              "glob:'**/*.bones'"
              "glob:'**/*.es'"
              "glob:'**/*.es6'"
              "glob:'**/*.frag'"
              "glob:'**/*.gs'"
              "glob:'**/*.jake'"
              "glob:'**/*.jsb'"
              "glob:'**/*.jscad'"
              "glob:'**/*.jsfl'"
              "glob:'**/*.jsm'"
              "glob:'**/*.jss'"
              "glob:'**/*.mjs'"
              "glob:'**/*.njs'"
              "glob:'**/*.pac'"
              "glob:'**/*.sjs'"
              "glob:'**/*.ssjs'"
              "glob:'**/*.xsjs'"
              "glob:'**/*.xsjslib'"
              "glob:'**/Jakefile'"

              "glob:'**/*.js.flow'"

              "glob:'**/*.jsx'"

              "glob:'**/*.ts'"
              "glob:'**/*.tsx'"

              "glob:'**/package.json'"
              "glob:'**/package-lock.json'"
              "glob:'**/composer.json'"

              "glob:'**/*.json'"
              "glob:'**/*.avsc'"
              "glob:'**/*.geojson'"
              "glob:'**/*.gltf'"
              "glob:'**/*.JSON-tmLanguage'"
              "glob:'**/*.jsonl'"
              "glob:'**/*.tfstate'"
              "glob:'**/*.tfstate.backup'"
              "glob:'**/*.topojson'"
              "glob:'**/*.webapp'"
              "glob:'**/*.webmanifest'"
              "glob:'**/.arcconfig'"
              "glob:'**/.htmlhintrc'"
              "glob:'**/.tern-config'"
              "glob:'**/.tern-project'"
              "glob:'**/composer.lock'"
              "glob:'**/mcmod.info'"
              "glob:'**/.prettierrc'"

              "glob:'**/*.jsonc'"
              "glob:'**/*.sublime-build'"
              "glob:'**/*.sublime-commands'"
              "glob:'**/*.sublime-completions'"
              "glob:'**/*.sublime-keymap'"
              "glob:'**/*.sublime-macro'"
              "glob:'**/*.sublime-menu'"
              "glob:'**/*.sublime-mousemap'"
              "glob:'**/*.sublime-project'"
              "glob:'**/*.sublime-settings'"
              "glob:'**/*.sublime-theme'"
              "glob:'**/*.sublime-workspace'"
              "glob:'**/*.sublime_metrics'"
              "glob:'**/*.sublime_session'"
              "glob:'**/.babelrc'"
              "glob:'**/.eslintrc.json'"
              "glob:'**/.jscsrc'"
              "glob:'**/.jshintrc'"
              "glob:'**/.jslintrc'"
              "glob:'**/tsconfig.json'"
              "glob:'**/.eslintrc'"

              "glob:'**/*.json5'"

              "glob:'**/*.css'"

              "glob:'**/*.pcss'"
              "glob:'**/*.postcss'"

              "glob:'**/*.less'"

              "glob:'**/*.scss'"

              "glob:'**/*.graphql'"
              "glob:'**/*.gql'"

              "glob:'**/*.md'"
              "glob:'**/*.markdown'"
              "glob:'**/*.mdown'"
              "glob:'**/*.mdwn'"
              "glob:'**/*.mkd'"
              "glob:'**/*.mkdn'"
              "glob:'**/*.mkdown'"
              "glob:'**/*.ronn'"
              "glob:'**/*.workbook'"
              "glob:'**/README'"

              "glob:'**/*.mdx'"

              "glob:'**/*.xhtml'"
              "glob:'**/*.component.html'"

              "glob:'**/*.html'"
              "glob:'**/*.htm'"
              "glob:'**/*.html.hl'"
              "glob:'**/*.inc'"
              "glob:'**/*.st'"
              "glob:'**/*.xht'"
              "glob:'**/*.xhtml'"
              "glob:'**/*.mjml'"

              "glob:'**/*.vue'"

              "glob:'**/*.yml'"
              "glob:'**/*.mir'"
              "glob:'**/*.reek'"
              "glob:'**/*.rviz'"
              "glob:'**/*.sublime-syntax'"
              "glob:'**/*.syntax'"
              "glob:'**/*.yaml'"
              "glob:'**/*.yaml-tmlanguage'"
              "glob:'**/*.yml.mysql'"
              "glob:'**/.clang-format'"
              "glob:'**/.clang-tidy'"
              "glob:'**/.gemrc'"
              "glob:'**/glide.lock'"
            ];
          };
        };
        merge-tools = {
          kdiff3 = {
            edit-args = [
              "--merge"
              "--cs"
              "CreateBakFiles=0"
              "--cs"
              "WhiteSpaceEqual=0"
              "--cs"
              "UnfoldSubdirs=1"
              "--cs"
              "EncodingForA=iso 8859-1"
              "--cs"
              "EncodingForB=iso 8859-1"
              "--cs"
              "EncodingForC=iso 8859-1"
              "--cs"
              "EncodingForOutput=iso 8859-1"
              "--cs"
              "EncodingForPP=iso 8859-1"
              "$left"
              "$right"
            ];
            program = "${pkgs.kdiff3}/bin/kdiff3";
          };
          mergiraf.program = "${pkgs.mergiraf}/bin/mergiraf";
        };
        revset-aliases = {
          "touched()" = "reachable(mine(), immutable_heads()..)";
          "stack()" = "(immutable_heads()..@ | @::)  & mine()::";
          "base()" = "trunk()";
          "here" = "reachable(@, trunk()..)";
          "in(branch, matching)" = "matching & ::branch";

          "back(revision, distance)" = "roots(ancestors(revision, distance))";
          "fwd(revision, distance)" = "heads(decendants(revision, distance))";

          "closest_bookmark(to)" = "heads(::to & bookmarks())";
          "closest_pushable_allow_empty_desc(to)" = "heads(::to & mutable() & (~empty() | merges()))";

          "main" = "coalesce(bookmarks(exact:'main'), bookmarks(exact:'master'))";

          "series(tip, length)" = "back(tip, length)::tip";
        };
        signing = {
          backend = "ssh";
          backends.ssh.allowed-signers =
            let
              allowedSigners = lib.mapAttrsToList (
                key: emails: "${builtins.concatStringsSep "," emails} ${key}"
              ) config.jujutsu.allowedSSHSigners;
              allowedSignersContent = builtins.concatStringsSep "\n" allowedSigners;
              allowedSignersFile = builtins.toFile "allowed-signers" allowedSignersContent;
            in
            allowedSignersFile;
          behavior = "drop"; # override or set git.sign-on-push in your own config to auto-sign stuff...
          key =
            let
              signingScript = pkgs.writeShellScript "first-ssh-key" ''
                set -euo pipefail

                KEYS="$(${pkgs.openssh}/bin/ssh-add -L)"

                SECURITY_KEY="$(echo "$KEYS" | ${pkgs.gnugrep}/bin/grep '^sk-' || echo "")"

                if [[ -z "$SECURITY_KEY" ]]; then
                  echo "$KEYS" | ${pkgs.coreutils}/bin/head -n 1
                  exit 0
                fi

                echo "$SECURITY_KEY" | ${pkgs.coreutils}/bin/head -n 1
              '';
              signingScriptPath = builtins.toString signingScript;
              signingScriptScriptFSPath =
                "~/.local/state/run/scriptfs" + (lib.removePrefix "/nix/store" signingScriptPath);
            in
            signingScriptScriptFSPath;
        };
        snapshot.auto-track = "~(root-glob:'**/.envrc' | root-glob:'**/*.env' | root-glob:'**/.direnv/**/*')";
        template-aliases.series_log = ''
          if(root,
            format_root_commit(self),
            label(if(current_working_copy, "working_copy"),
              concat(
                if(current_working_copy, label("op_log current_operation id", "@"),
                if(self.contained_in("..@"), label("diff added", "-"),
                label("diff removed", "+")
                )),
                " ",
                separate(" ",
                  format_short_change_id_with_hidden_and_divergent_info(self),
                  format_short_commit_id(commit_id),
                  git_head,
                  if(conflict, label("conflict", "conflict")),
                ) ++ " ",
                separate(" ",
                  if(self.contained_in("@.."),
                    label("rest", separate(" ",
                      if(empty, "(empty)"),
                      if(description,
                        description.first_line(),
                        "(no description set)",
                      ),
                    )),
                    separate(" ",
                      if(empty, label("empty", "(empty)")),
                      if(description,
                        description.first_line(),
                        label(if(empty, "empty"), description_placeholder),
                      ),
                    )
                  ),
                  if(!(current_working_copy || parents), "\033[22m")
                ) ++ "\n",
              ),
            )
          )
        '';
        templates = {
          git_push_bookmark = "'private/${config.home.username}/push-' ++ change_id.short()";
          commit_trailers = ''
            if(config("ui.should-sign-off").as_boolean(), format_signed_off_by_trailer(self))
            ++ if(config("ui.should-add-gerrit-change-id").as_boolean() && !trailers.contains_key("Change-Id"), format_gerrit_change_id_trailer(self))
          '';
        };
        ui = {
          default-command = "hereish";
          diff-editor = "kdiff3";
          diff-formatter = [
            "${pkgs.difftastic}/bin/difft"
            "--color=always"
            "$left"
            "$right"
          ];
          merge-editor = "mergiraf";
          pager = [
            "${pkgs.less}/bin/less"
            "-FRX"
          ];
          should-sign-off = false; # See templates.commit_trailers, override in individual repos
          should-add-gerrit-change-id = false; # See templates.commit_trailers, override in individual repos
          show-cryptographic-signatures = true;
        };
      };
    };
  };
}
