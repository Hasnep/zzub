extends VBoxContainer

var my_player_id: String

@onready var player_name_label = $"PlayerName"
@onready var is_ready_label = $"IsReady"
# @onready var character_name_label = $"CharacterName"
@onready var character_texture = $"CharacterTexture"


func _on_set_player_name(player_id: String, player_name: String) -> void:
	if player_id == my_player_id:
		player_name_label.text = player_name


func _on_set_is_ready(player_id: String, is_ready: bool) -> void:
	if player_id == my_player_id:
		if is_ready:
			is_ready_label.text = "Ready"
		else:
			is_ready_label.text = "Not ready yet"


func _on_set_character_id(player_id: String, character_id: String) -> void:
	if player_id == my_player_id:
		character_texture.texture = load(
			"res://textures/{character_id}-joy.png".format(
				{"character_id": character_id}
			)
		)
