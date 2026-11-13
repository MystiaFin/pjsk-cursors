{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  python3,
  win2xcur,

  # package name, like "asahina-mafuyu-animated"
  name,

  # { url, hash } from sources.json
  source,
}:

let
  theme = "pjsk-${name}";

  # Windows cursor role -> Xcursor names; Person and Pin have no X11 equivalent and are dropped
  roles = {
    Normal = [
      "left_ptr"
      "default"
      "arrow"
      "top_left_arrow"
      "top-left-arrow"
      "x-cursor"
      "X_cursor"
      "context-menu"
      "copy"
      "dnd-copy"
    ];
    Working = [
      "progress"
      "left_ptr_watch"
      "half-busy"
    ];
    Busy = [
      "wait"
      "watch"
    ];
    Help = [
      "help"
      "question_arrow"
      "whats_this"
      "left_ptr_help"
      "ask"
      "dnd-ask"
    ];
    Precision = [
      "crosshair"
      "cross"
      "tcross"
      "diamond_cross"
      "cross_reverse"
      "cell"
      "plus"
    ];
    Text = [
      "text"
      "xterm"
      "ibeam"
      "vertical-text"
    ];
    Handwriting = [
      "pencil"
      "draft_large"
      "draft_small"
    ];
    Unavailable = [
      "not-allowed"
      "no-drop"
      "dnd-none"
      "dnd-no-drop"
      "circle"
      "crossed_circle"
      "forbidden"
      "pirate"
    ];
    Vertical = [
      "ns-resize"
      "row-resize"
      "n-resize"
      "s-resize"
      "sb_v_double_arrow"
      "v_double_arrow"
      "size_ver"
      "double_arrow"
      "split_v"
      "top_side"
      "bottom_side"
      "up"
      "sb_up_arrow"
      "down"
      "sb_down_arrow"
    ];
    Horizontal = [
      "ew-resize"
      "col-resize"
      "e-resize"
      "w-resize"
      "sb_h_double_arrow"
      "h_double_arrow"
      "size_hor"
      "split_h"
      "left_side"
      "right_side"
      "left"
      "sb_left_arrow"
      "right"
      "sb_right_arrow"
    ];
    Diagonal1 = [
      "nwse-resize"
      "nw-resize"
      "se-resize"
      "size_fdiag"
      "fd_double_arrow"
      "top_left_corner"
      "bottom_right_corner"
      "ul_angle"
      "lr_angle"
    ];
    Diagonal2 = [
      "nesw-resize"
      "ne-resize"
      "sw-resize"
      "size_bdiag"
      "bd_double_arrow"
      "top_right_corner"
      "bottom_left_corner"
      "ur_angle"
      "ll_angle"
    ];
    Move = [
      "move"
      "fleur"
      "all-scroll"
      "size_all"
      "dnd-move"
      "grabbing"
    ];
    Link = [
      "pointer"
      "hand2"
      "hand1"
      "hand"
      "pointing_hand"
      "openhand"
      "grab"
      "alias"
      "link"
      "dnd-link"
    ];
    Alternate = [
      "up-arrow"
      "up_arrow"
      "center_ptr"
      "right_ptr"
      "top-right-arrow"
    ];
  };

  # the first name gets the converted file, every other name links to it
  installRole =
    role: names:
    let
      file = lib.head names;
      aliases = lib.tail names;
    in
    ''
      install -m644 xcur/${role} $cursors/${file}
    ''
    + lib.concatMapStrings (alias: ''
      ln -s ${file} $cursors/${alias}
    '') aliases;
in
stdenvNoCC.mkDerivation {
  pname = "pjsk-cursors-${name}";

  # upstream has no versions; this is the date the last sets were added
  version = "0-unstable-2026-05-04";

  src = fetchurl {
    # the url basename has %20 in it, which isn't allowed in a store path
    name = "${name}.zip";
    inherit (source) url hash;
  };

  nativeBuildInputs = [
    unzip

    # win2xcur is packaged as an app; convert.py uses it as a library
    (python3.withPackages (ps: [ (ps.toPythonModule win2xcur) ]))
  ];

  # the zip has no top-level folder, so the default unpack can't pick a source root
  unpackPhase = ''
    runHook preUnpack

    unzip -q $src -x install.inf

    runHook postUnpack
  '';

  buildPhase = ''
    runHook preBuild

    # a set ships either .ani or .cur files, never both
    shopt -s nullglob nocaseglob

    mkdir xcur
    python3 ${./convert.py} xcur *.ani *.cur

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    icons=$out/share/icons/${theme}
    cursors=$icons/cursors
    mkdir -p $cursors

    cat > $icons/index.theme <<EOF
    [Icon Theme]
    Name=${theme}
    Comment=Project SEKAI cursors from colorfulstage.com
    EOF

    ${lib.concatStrings (lib.mapAttrsToList installRole roles)}

    runHook postInstall
  '';

  passthru.themeName = theme;

  meta = {
    description = "Project SEKAI ${name} cursor theme, converted to Xcursor";
    homepage = "https://colorfulstage.com/media/download/";
    platforms = lib.platforms.linux;
  };
}
