extends Control

@onready var player_name_label = $"NameAndScore/PlayerNameLabelBackground/PlayerNameLabel"
@onready var player_score_label = $"NameAndScore/PlayerScoreLabel"
@onready var character_portrait_background = $"CharacterPortraitBackground"
@onready var character_portrait=$"CharacterPortraitBackground/CharacterPortrait"

var my_player_id: String
var my_character_id: String
var my_colour_id: String
var my_player_name: String
var my_player_score: int = 0


func _ready() -> void:
	player_name_label.text = my_player_name
	player_score_label.text = "{score}".format({"score":my_player_score})
	character_portrait_background.color = Global.get_colour_by_id(my_colour_id)
	character_portrait.texture = load(
		"res://textures/{character_id}-joy.png".format(
			{"character_id": my_character_id}
		)
	)

func _on_set_player_score(player_id: String, score: int) -> void:
	if player_id == my_player_id:
		my_player_score = score
	player_score_label.text = "{score}".format({"score":my_player_score})
