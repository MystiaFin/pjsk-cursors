# pjsk-cursors

The official Project SEKAI cursors from [colorfulstage.com](https://colorfulstage.com/media/download/), converted to Xcursor themes with `win2xcur`. There are two kinds of set: six unit themes (one per unit, including Virtual Singer) and 25 character themes (one per character). Each comes in an animated and a static version.

The cursors are fetched straight from SEGA's site at build time and are not redistributed here.

## Home Manager

```nix
# flake.nix
inputs.pjsk-cursors = {
  url = "github:MystiaFin/pjsk-cursors";
  inputs.nixpkgs.follows = "nixpkgs";
};

# home configuration
imports = [ inputs.pjsk-cursors.homeManagerModules.default ];

pjsk-cursor = {
  enable = true;
  theme = "asahina-mafuyu"; # a character, or a unit like "nightcord-at-25"
  animated = true;           # default
  size = 32;                 # default
};
```

This sets `home.pointerCursor`, so remove any other `home.pointerCursor` definition.

## Packages

`nix build .#<theme>-<animated|static>`, for example `.#yoisaki-kanade-static`. `.#default` builds all of them. There is also `overlays.default`, which adds `pkgs.pjsk-cursors.<name>`. Installed themes are named `pjsk-<name>`.

Character themes use the character's full name, family name first, e.g. `asahina-mafuyu` (see `names.nix`). Unit themes are `virtual-singer`, `leo-need`, `more-more-jump`, `vivid-bad-squad`, `wonderlands-x-showtime` and `nightcord-at-25`.

## Updating

`./update.sh` reads the download page again and rewrites `sources.json`. A set it doesn't know yet keeps its short name until it's added to `names.nix`.
