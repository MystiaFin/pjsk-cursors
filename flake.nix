{
  description = "Official Project SEKAI cursors (colorfulstage.com) as Xcursor themes";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      names = import ./names.nix;

      # "mafuyu-animated" -> "asahina-mafuyu-animated"
      rename =
        key:
        let
          m = builtins.match "(.*)-(animated|static)" key;
        in
        "${names.${lib.elemAt m 0} or (lib.elemAt m 0)}-${lib.elemAt m 1}";
      sources = lib.mapAttrs' (key: lib.nameValuePair (rename key)) (lib.importJSON ./sources.json);

      themeNames = lib.unique (map (n: lib.head (builtins.match "(.*)-(animated|static)" n)) (lib.attrNames sources));
      themesFor = pkgs: lib.mapAttrs (name: source: pkgs.callPackage ./package.nix { inherit name source; }) sources;
      forAllSystems = f: lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (s: f nixpkgs.legacyPackages.${s});
    in
    {
      packages = forAllSystems (
        pkgs:
        let
          themes = themesFor pkgs;
        in
        themes
        // {
          default = pkgs.symlinkJoin {
            name = "pjsk-cursors";
            paths = lib.attrValues themes;
          };
        }
      );

      overlays.default = final: _: { pjsk-cursors = themesFor final; };

      homeManagerModules.default = import ./module.nix { inherit themesFor themeNames; };
    };
}
