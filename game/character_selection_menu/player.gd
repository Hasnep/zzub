extends ColorRect

var my_player_id: String

@onready var player_name_label = $"VBoxContainer/PlayerName"
@onready var is_ready_label = $"VBoxContainer/IsReady"
@onready var character_texture = $"VBoxContainer/CharacterTexture"


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


func _on_set_colour_id(player_id: String, colour_id: String) -> void:
	if player_id == my_player_id:
		color = Global.get_colour_by_id(colour_id)
