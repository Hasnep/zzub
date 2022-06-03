import json
from pathlib import Path

from pydantic import BaseModel, Field


class Character(BaseModel):
    character_id: str = Field(alias="id")
    name: str


def get_characters():
    with open(Path(".") / "data" / "characters.json") as f:
        characters = json.load(f)
    return [Character(**c) for c in characters]


CHARACTERS = get_characters()
