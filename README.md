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

## Themes

Every value below works for `theme`. Each has an animated and a static version.

| Unit | Unit theme | Character themes |
| --- | --- | --- |
| VIRTUAL SINGER | `virtual-singer` | `kagamine-rin`, `kagamine-len`, `megurine-luka`, `meiko`, `kaito` |
| Leo/need | `leo-need` | `hoshino-ichika`, `tenma-saki`, `mochizuki-honami`, `hinomori-shiho` |
| MORE MORE JUMP! | `more-more-jump` | `hanasato-minori`, `kiritani-haruka`, `momoi-airi`, `hinomori-shizuku` |
| Vivid BAD SQUAD | `vivid-bad-squad` | `azusawa-kohane`, `shiraishi-an`, `shinonome-akito`, `aoyagi-toya` |
| Wonderlands×Showtime | `wonderlands-x-showtime` | `tenma-tsukasa`, `otori-emu`, `kusanagi-nene`, `kamishiro-rui` |
| 25-ji, Nightcord de. | `nightcord-at-25` | `yoisaki-kanade`, `asahina-mafuyu`, `shinonome-ena`, `akiyama-mizuki` |

There is no Hatsune Miku character theme because SEGA doesn't offer one.

## Packages

`nix build .#<theme>-<animated|static>`, for example `.#yoisaki-kanade-static`. `.#default` builds all of them. There is also `overlays.default`, which adds `pkgs.pjsk-cursors.<name>`. Installed themes are named `pjsk-<name>`.

## Updating

`./update.sh` reads the download page again and rewrites `sources.json`. A set it doesn't know yet keeps its short name until it's added to `names.nix`.
