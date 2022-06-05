extends VSplitContainer

@onready var character_texture = $"CharacterTexture"
@onready var player_name_label = $"PlayerNameLabelBackground/PlayerNameLabel"

var my_player_id: String
var my_character_id: String
var my_player_name: String


func _ready():
	character_texture.texture = load(
		"res://textures/{character_id}-joy.png".format(
			{"character_id": my_character_id}
		)
	)
	player_name_label.text = my_player_name
