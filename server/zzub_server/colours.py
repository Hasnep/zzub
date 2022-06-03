import json
from pathlib import Path

from pydantic import BaseModel, Field


def get_colours():
    with open(Path(".") / "data" / "colours.json") as f:
        colours = json.load(f)
    return [Colour(**c) for c in colours]


class Colour(BaseModel):
    colour_id: str = Field(alias="id")
    hex_id: str = Field(alias="hex")


COLOURS = get_colours()
