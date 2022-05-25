import random
from typing import Any, Dict, List, Optional

import uvicorn
from fastapi import FastAPI, Request, WebSocket, WebSocketDisconnect
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from jackbox_test_server.data import CHARACTERS, COLOURS

from jackbox_test_server.dataclasses.dataclasses import Character, Colour
from jackbox_test_server.dataclasses.player import Player
from jackbox_test_server.trivia import get_question as get_question_object
from jackbox_test_server.utils import shuffle


class ConnectionManager:
    def __init__(self):
        self.host_websocket: Optional[WebSocket] = None
        self.players: Dict[str, Player] = {}
        self.scene_id: str = "character_selection_menu"

    def get_active_connections(self) -> List[WebSocket]:
        host_connections = (
            [self.host_websocket] if self.host_websocket is not None else []
        )
        player_connections = [
            p.websocket for p in self.players.values() if p.websocket is not None
        ]
        return host_connections + player_connections

    async def connect_player(self, websocket: WebSocket, player_id: str):
        print(f"Accepting message from player {player_id}")
        await websocket.accept()
        if player_id not in self.players:
            await self.join_host(player_id)
        self.players[player_id].websocket = websocket

    async def connect_host(self, websocket: WebSocket):
        await websocket.accept()
        self.host_websocket = websocket

    def disconnect_player(self, player_id: str):
        self.players[player_id].websocket = None

    def disconnect_host(self):
        self.host_websocket = None

    async def send_message_to_player(self, message: Dict[str, Any], player_id: str):
        websocket = self.players[player_id].websocket
        if websocket is None:
            raise ValueError("aaaaaa")
        await websocket.send_json(message)

    async def send_message_to_host(self, message: Dict[str, Any]):
        websocket = self.host_websocket
        if websocket is None:
            raise ValueError("aaaaaa")
        await websocket.send_json(message)

    async def broadcast(self, message: Dict[str, Any]):
        for connection in self.get_active_connections():
            await connection.send_json(message)

    async def join_host(self, player_id: str):
        print(f"Player {player_id} joining.")
        self.players[player_id] = Player()
        await self.send_message_to_host({"action": "join", "player_id": player_id})

    async def set_player_name(self, player_id: str, player_name: str):
        print(f"Setting the name of player {player_id} to {player_name}.")
        self.players[player_id].player_name = player_name
        await self.send_message_to_host(
            {
                "action": "set_player_name",
                "player_id": player_id,
                "player_name": player_name,
            }
        )

    async def set_is_ready(self, player_id: str, is_ready: bool):
        print(f"Setting the ready status of player {player_id} to {is_ready}.")
        self.players[player_id].is_ready = is_ready
        await self.send_message_to_host(
            {"action": "set_is_ready", "player_id": player_id, "is_ready": is_ready}
        )
        if self._are_all_players_ready():
            await self.set_scene_id("game")

    async def set_character_id(self, player_id: str, character_id: str):
        print(f"Setting the character id of player {player_id} to {character_id}.")
        self.players[player_id].character_id = character_id
        await self.send_message_to_host(
            {
                "action": "set_character_id",
                "player_id": player_id,
                "character_id": character_id,
            }
        )
        # If the player hasn't given themself a name yet we'll give them the name of their character
        if self.players[player_id].player_name is None:
            await self.set_player_name(
                player_id,
                next(c.name for c in CHARACTERS if c.character_id == character_id),
            )

    async def set_colour_id(self, player_id: str, colour_id: str):
        print(f"Setting the colour id of player {player_id} to {colour_id}.")
        self.players[player_id].colour_id = colour_id
        await self.send_message_to_host(
            {
                "action": "set_colour_id",
                "player_id": player_id,
                "colour_id": colour_id,
            }
        )

    async def set_scene_id(self, scene_id: str) -> None:
        self.scene_id = scene_id
        await self.broadcast({"action": "set_scene_id", "scene_id": scene_id})

    def _are_all_players_ready(self) -> bool:
        return (
            len(self.players) >= 2
            and all(p.player_name is not None for p in self.players.values())
            and all(p.is_ready for p in self.players.values())
        )

    async def set_question(self) -> None:
        question_object = await get_question_object()
        self.question = question_object.question
        self.answers = shuffle(
            [question_object.correct_answer]
            + random.sample(question_object.incorrect_answers, 3)
        )
        self.correct_answer_index = self.answers.index(question_object.correct_answer)
        await self.broadcast(
            {
                "action": "set_question",
                "question": self.question,
                "answers": self.answers,
            }
        )

    async def answer_question(self, player_id: str, answer_index: int) -> None:
        self.players[player_id].answer_index = answer_index
        await self.send_message_to_host(
            {
                "action": "answer_question",
                "player_id": player_id,
                "answer_index": answer_index,
            }
        )
        if self._have_all_players_answered():
            await self.broadcast(
                {
                    "action": "reveal_answer",
                    "correct_answer_index": self.correct_answer_index,
                }
            )

    def _have_all_players_answered(self) -> bool:
        return all(p.answer_index is not None for p in self.players.values())


connection_manager = ConnectionManager()

app = FastAPI()

# app.mount("/", StaticFiles(directory="static"), name="static")


@app.websocket("/host")
async def host_websocket_endpoint(websocket: WebSocket):
    await connection_manager.connect_host(websocket)
    while True:
        try:
            data = await websocket.receive_json()
            print(f"Received data from host: {data}")

            if data["action"] == "get_question":
                await connection_manager.set_question()

            else:
                print(f"Unknown action: {data}")

        except WebSocketDisconnect:
            print("host disconnected")
            connection_manager.disconnect_host()


@app.websocket("/player/{player_id}")
async def player_websocket_endpoint(websocket: WebSocket, player_id: str):
    await connection_manager.connect_player(websocket, player_id)
    # await connection_manager.set_scene_id("game")  # TEMPORARY
    while True:
        try:
            data = await websocket.receive_json()
            print(f"Received data from player {player_id}: {data}")

            if data["action"] == "set_player_name":
                await connection_manager.set_player_name(player_id, data["player_name"])

            elif data["action"] == "set_is_ready":
                await connection_manager.set_is_ready(player_id, data["is_ready"])

            elif data["action"] == "set_character_id":
                await connection_manager.set_character_id(
                    player_id, data["character_id"]
                )

            elif data["action"] == "set_colour_id":
                await connection_manager.set_colour_id(player_id, data["colour_id"])

            elif data["action"] == "get_question":
                await connection_manager.set_question()

            elif data["action"] == "answer_question":
                await connection_manager.answer_question(
                    data["player_id"], data["answer_index"]
                )

            else:
                print(f"Unknown action: {data}")

        except WebSocketDisconnect:
            print(f"Disconnecting player {player_id}")
            connection_manager.disconnect_player(player_id)


# if __name__ == "__main__":
#     uvicorn.run(app, host="0.0.0.0", port=5000, log_level="info")
