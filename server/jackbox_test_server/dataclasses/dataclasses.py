from pydantic import BaseModel, Field


class Character(BaseModel):
    character_id: str = Field(alias="id")
    name: str


class Colour(BaseModel):
    colour_id: str = Field(alias="id")
    hex_id: str = Field(alias="hex")
