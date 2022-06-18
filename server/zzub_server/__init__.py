import random
from typing import Any, Dict, List, Optional

from fastapi import FastAPI, WebSocket, WebSocketDisconnect

from .characters import CHARACTERS
from .players import Player
from .trivia import get_question as get_question_object
from .utils import shuffle


class ConnectionManager:
    def __init__(self):
        self.game_websocket: Optional[WebSocket] = None
        self.players: Dict[str, Player] = {}
        self.scene_id: str = "character_selection_menu"

    def _are_all_players_ready(self) -> bool:
        return (
            len(self.players) >= 2
            and all(p.player_name is not None for p in self.players.values())
            and all(p.is_ready for p in self.players.values())
        )

    def _have_all_players_answered(self) -> bool:
        return all(p.answer_index is not None for p in self.players.values())

    def get_active_connections(self) -> List[WebSocket]:
        game_connections = (
            [self.game_websocket] if self.game_websocket is not None else []
        )
        player_connections = [
            p.websocket for p in self.players.values() if p.websocket is not None
        ]
        return game_connections + player_connections

    async def connect_player(self, websocket: WebSocket, player_id: str):
        print(f"Accepting message from player {player_id}.")
        await websocket.accept()
        if player_id not in self.players:
            await self.join_game(player_id)
        self.players[player_id].websocket = websocket

    async def connect_game(self, websocket: WebSocket):
        await websocket.accept()
        self.game_websocket = websocket

    def disconnect_player(self, player_id: str):
        self.players[player_id].websocket = None

    def disconnect_game(self):
        self.game_websocket = None

    async def send_message_to_player(self, message: Dict[str, Any], player_id: str):
        websocket = self.players[player_id].websocket
        if websocket is None:
            raise ValueError(f"Player {player_id} did not have a websocket.")
        await websocket.send_json(message)

    async def send_message_to_game(self, message: Dict[str, Any]):
        websocket = self.game_websocket
        if websocket is None:
            raise ValueError("aaaaaa")
        await websocket.send_json(message)

    async def broadcast(self, message: Dict[str, Any]):
        for connection in self.get_active_connections():
            await connection.send_json(message)

    async def join_game(self, player_id: str):
        print(f"Player {player_id} joining.")
        self.players[player_id] = Player()
        await self.send_message_to_game({"action": "join", "player_id": player_id})

    async def set_player_name(self, player_id: str, player_name: str):
        print(f"Setting the name of player {player_id} to {player_name}.")
        self.players[player_id].player_name = player_name
        await self.send_message_to_game(
            {
                "action": "set_player_name",
                "player_id": player_id,
                "player_name": player_name,
            }
        )

    async def set_is_ready(self, player_id: str, is_ready: bool):
        print(f"Setting the ready status of player {player_id} to {is_ready}.")
        self.players[player_id].is_ready = is_ready
        await self.send_message_to_game(
            {"action": "set_is_ready", "player_id": player_id, "is_ready": is_ready}
        )
        if self._are_all_players_ready():
            await self.set_scene_id("game")

    async def set_character_id(self, player_id: str, character_id: str):
        print(f"Setting the character id of player {player_id} to {character_id}.")
        self.players[player_id].character_id = character_id
        await self.send_message_to_game(
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
        await self.send_message_to_game(
            {
                "action": "set_colour_id",
                "player_id": player_id,
                "colour_id": colour_id,
            }
        )

    async def set_scene_id(self, scene_id: str) -> None:
        print(f"Setting the scene id to {scene_id}.")
        self.scene_id = scene_id
        await self.broadcast({"action": "set_scene_id", "scene_id": scene_id})

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
                "category": question_object.question_category,
            }
        )

    async def answer_question(self, player_id: str, answer_index: int) -> None:
        self.players[player_id].answer_index = answer_index
        await self.send_message_to_game(
            {
                "action": "answer_question",
                "player_id": player_id,
                "answer_index": answer_index,
            }
        )
        if self._have_all_players_answered():
            await self.reveal_answer()

    async def reveal_answer(self) -> None:
        print(
            f"Revealing that the correct answer was answer {self.correct_answer_index}."
        )
        await self.broadcast(
            {
                "action": "reveal_answer",
                "correct_answer_index": self.correct_answer_index,
            }
        )
        for player_id, player in self.players.items():
            # Add points to every player that got the answer right
            if player.answer_index == self.correct_answer_index:
                await self.add_player_score(player_id, 10)
            # Reset their answers
            player.answer_index = None

    async def set_player_score(self, player_id: str, score: int):
        print(f"Setting the score of player {player_id} to {score}.")
        await self.send_message_to_game(
            {"action": "set_player_score", "player_id": player_id, "score": score}
        )
        self.players[player_id].score = score

    async def add_player_score(self, player_id: str, score_delta: int):
        print(f"Adding {score_delta} to the score of player {player_id}.")
        await self.set_player_score(
            player_id, self.players[player_id].score + score_delta
        )

    async def send_all_player_data(self):
        await self.send_message_to_game(
            {
                "action": "send_all_player_data",
                "player_data": [
                    {
                        "player_id": player_id,
                        "character_id": p.character_id,
                        "colour_id": p.colour_id,
                        "player_name": p.player_name,
                    }
                    for player_id, p in self.players.items()
                ],
            }
        )


connection_manager = ConnectionManager()

app = FastAPI()


@app.websocket("/game")
async def game_websocket_endpoint(websocket: WebSocket):
    await connection_manager.connect_game(websocket)
    while True:
        try:
            data = await websocket.receive_json()
            print(f"Received data from game: {data}")

            match data["action"]:
                case "get_question":
                    await connection_manager.set_question()

                case "reveal_answer":
                    await connection_manager.reveal_answer()

                case "get_all_player_data":
                    await connection_manager.send_all_player_data()

                case _:
                    print(f"Unknown action: {data}")

        except WebSocketDisconnect:
            print("game disconnected")
            connection_manager.disconnect_game()


@app.websocket("/player/{player_id}")
async def player_websocket_endpoint(websocket: WebSocket, player_id: str):
    await connection_manager.connect_player(websocket, player_id)
    # await connection_manager.set_scene_id("game")  # TEMPORARY
    while True:
        try:
            data = await websocket.receive_json()
            print(f"Received data from player {player_id}: {data}")

            match data["action"]:
                case "set_player_name":
                    await connection_manager.set_player_name(
                        player_id, data["player_name"]
                    )

                case "set_is_ready":
                    await connection_manager.set_is_ready(player_id, data["is_ready"])

                case "set_character_id":
                    await connection_manager.set_character_id(
                        player_id, data["character_id"]
                    )

                case "set_colour_id":
                    await connection_manager.set_colour_id(player_id, data["colour_id"])

                case "get_question":
                    await connection_manager.set_question()

                case "answer_question":
                    await connection_manager.answer_question(
                        data["player_id"], data["answer_index"]
                    )

                case _:
                    print(f"Unknown action: {data}")

        except WebSocketDisconnect:
            print(f"Disconnecting player {player_id}")
            connection_manager.disconnect_player(player_id)
