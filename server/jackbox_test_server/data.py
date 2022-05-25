from pathlib import Path
import json

from jackbox_test_server.dataclasses.dataclasses import Character, Colour


def get_characters():
    with open(Path(".") / "data" / "characters.json") as f:
        characters = json.load(f)
    return [Character(**c) for c in characters]


def get_colours():
    with open(Path(".") / "data" / "colours.json") as f:
        colours = json.load(f)
    return [Colour(**c) for c in colours]


CHARACTERS = get_characters()
COLOURS = get_colours()
