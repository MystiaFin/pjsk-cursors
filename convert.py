# converts windows cursors to xcursor files that carry every size in SCALES
#
# upstream only draws 32px cursors, and compositors pick the closest size the
# file has instead of scaling, so without bigger copies the cursor stays 32px
# (or shows at half size on a scaled output)
import sys
from pathlib import Path

from win2xcur.cursor import CursorFrame
from win2xcur.parser import open_blob
from win2xcur.writer import to_x11

# whole numbers only, so every pixel of the art becomes a clean square
SCALES = [2, 3]


def add_scaled_copies(frames: list[CursorFrame]) -> None:
    for frame in frames:
        originals = list(frame.images)

        for original in originals:
            for scale in SCALES:
                copy = original.clone()

                width = original.image.width * scale
                height = original.image.height * scale
                copy.image.resize(width, height, filter="point")

                hotspot_x, hotspot_y = original.hotspot
                copy.hotspot = (hotspot_x * scale, hotspot_y * scale)
                copy.nominal = original.nominal * scale

                frame.images.append(copy)


def main() -> None:
    output_dir = Path(sys.argv[1])

    for path in map(Path, sys.argv[2:]):
        cursor = open_blob(path.read_bytes())

        add_scaled_copies(cursor.frames)

        (output_dir / path.stem).write_bytes(to_x11(cursor.frames))


if __name__ == "__main__":
    main()
