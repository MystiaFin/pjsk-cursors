{
  description = "Official Project SEKAI cursors (colorfulstage.com) as Xcursor themes";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      fullNames = import ./names.nix;

      # keyed by short name and style, like "mafuyu-animated"
      shortSources = lib.importJSON ./sources.json;

      # "mafuyu-animated" -> { character = "asahina-mafuyu"; style = "animated"; }
      parseKey =
        key:
        let
          parts = builtins.match "(.+)-(animated|static)" key;
          shortName = lib.elemAt parts 0;
        in
        if parts == null then
          throw "sources.json key \"${key}\" doesn't end in -animated or -static"
        else
          {
            # sets missing from names.nix keep their short name
            character = fullNames.${shortName} or shortName;
            style = lib.elemAt parts 1;
          };

      toPackageName =
        key:
        let
          set = parseKey key;
        in
        "${set.character}-${set.style}";

      # keyed by package name, like "asahina-mafuyu-animated"
      sources = lib.mapAttrs' (key: source: lib.nameValuePair (toPackageName key) source) shortSources;

      characters = lib.unique (map (key: (parseKey key).character) (lib.attrNames shortSources));

      buildThemes =
        pkgs: lib.mapAttrs (name: source: pkgs.callPackage ./package.nix { inherit name source; }) sources;

      forAllSystems = f: lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (
        pkgs:
        let
          themes = buildThemes pkgs;

          everyTheme = pkgs.symlinkJoin {
            name = "pjsk-cursors";
            paths = lib.attrValues themes;
          };
        in
        themes // { default = everyTheme; }
      );

      homeManagerModules.default = import ./module.nix { inherit buildThemes characters; };
    };
}
