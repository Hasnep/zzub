extends CanvasLayer

@onready var websocket_client
@onready var players = $"VBoxContainer/Players"

var player_scene = preload("res://character_selection_menu/player.tscn")


func _ready() -> void:
	websocket_client.join.connect(self._on_join)


func _on_join(player_id: String) -> void:
	var player = player_scene.instantiate()
	player.my_player_id = player_id
	websocket_client.set_player_name.connect(player._on_set_player_name)
	websocket_client.set_is_ready.connect(player._on_set_is_ready)
	websocket_client.set_character_id.connect(player._on_set_character_id)
	websocket_client.set_colour_id.connect(player._on_set_colour_id)
	players.add_child(player)
