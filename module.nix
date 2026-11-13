{ buildThemes, characters }:
{
  config,
  lib,
  pkgs,
  ...
}:

let
  # upstream draws everything at 32px; convert.py adds 64 and 96 copies
  NATIVE_SIZE = 32;

  cfg = config.pjsk-cursor;

  style = if cfg.animated then "animated" else "static";
  package = (buildThemes pkgs)."${cfg.character}-${style}";
in
{
  options.pjsk-cursor = {
    enable = lib.mkEnableOption "a Project SEKAI cursor theme";

    character = lib.mkOption {
      type = lib.types.enum characters;
      example = "asahina-mafuyu";
      description = "Character whose cursors to use, e.g. \"asahina-mafuyu\" or \"hatsune-miku-nightcord-at-25\".";
    };

    animated = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use the animated cursors instead of the static ones.";
    };

    size = lib.mkOption {
      type = lib.types.int;
      default = NATIVE_SIZE;
      description = "Cursor size in pixels. Each theme has ${toString NATIVE_SIZE}, 64 and 96; other sizes use the closest one.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.pointerCursor = {
      inherit package;
      inherit (cfg) size;

      name = package.themeName;
      gtk.enable = lib.mkDefault true;
    };
  };
}
