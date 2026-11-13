# pjsk-cursors

Official Project SEKAI cursors from [colorfulstage.com](https://colorfulstage.com/media/download/) for Home Manager.

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
  character = "asahina-mafuyu";
  animated = true; # default
  size = 32;       # default
};
```

This sets `home.pointerCursor`, so remove any other `home.pointerCursor` definition.

## Characters

| SEKAI | Hatsune Miku | Other characters |
| --- | --- | --- |
| VIRTUAL SINGER | `hatsune-miku-virtual-singer` | `kagamine-rin`, `kagamine-len`, `megurine-luka`, `meiko`, `kaito` |
| Leo/need | `hatsune-miku-leo-need` | `hoshino-ichika`, `tenma-saki`, `mochizuki-honami`, `hinomori-shiho` |
| MORE MORE JUMP! | `hatsune-miku-more-more-jump` | `hanasato-minori`, `kiritani-haruka`, `momoi-airi`, `hinomori-shizuku` |
| Vivid BAD SQUAD | `hatsune-miku-vivid-bad-squad` | `azusawa-kohane`, `shiraishi-an`, `shinonome-akito`, `aoyagi-toya` |
| Wonderlands×Showtime | `hatsune-miku-wonderlands-x-showtime` | `tenma-tsukasa`, `otori-emu`, `kusanagi-nene`, `kamishiro-rui` |
| 25-ji, Nightcord de. | `hatsune-miku-nightcord-at-25` | `yoisaki-kanade`, `asahina-mafuyu`, `shinonome-ena`, `akiyama-mizuki` |
