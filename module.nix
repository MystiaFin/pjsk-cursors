{ themesFor, themeNames }:
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.pjsk-cursor;
  package = (themesFor pkgs)."${cfg.theme}-${if cfg.animated then "animated" else "static"}";
in
{
  options.pjsk-cursor = {
    enable = lib.mkEnableOption "a Project SEKAI cursor theme";

    theme = lib.mkOption {
      type = lib.types.enum themeNames;
      example = "asahina-mafuyu";
      description = "Cursor set to use: a unit (e.g. \"nightcord-at-25\") or a single character (e.g. \"asahina-mafuyu\").";
    };

    animated = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use the animated cursors instead of the static ones.";
    };

    size = lib.mkOption {
      type = lib.types.int;
      default = 32;
      description = "Cursor size in pixels.";
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
