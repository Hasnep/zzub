extends Node

var is_production = OS.get_environment("IS_PRODUCTION")
var server_host = OS.get_environment("SERVER_HOST")
var server_port = OS.get_environment("SERVER_PORT")

enum Scene { CHARACTER_SELECTION_MENU, GAME }

# Character data


func get_character_by_id(character_id: String) -> Dictionary:
	for character in Characters.data:
		if character.id == character_id:
			return character
	print(
		"Character id `{character_id}` not found.".format(
			{"character_id": character_id}
		)
	)
	return {}


# Colour data


func get_colour_by_id(colour_id: String) -> Color:
	for colour in Colours.data:
		if colour.id == colour_id:
			return Color(colour.hex)
	print("Colour id `{colour_id}` not found.".format({"colour_id": colour_id}))
	return Color()
