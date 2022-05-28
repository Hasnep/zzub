import random
from dataclasses import dataclass
from typing import Optional

from fastapi import WebSocket
from zzub_server.data import CHARACTERS, COLOURS


@dataclass
class Player:
    websocket: Optional[WebSocket] = None
    player_name: Optional[str] = None
    is_ready: bool = False
    character_id: str = random.choice([c.character_id for c in CHARACTERS])
    colour_id: str = random.choice([c.colour_id for c in COLOURS])
    answer_index: Optional[int] = None
