extends Node

var is_production = OS.get_environment("IS_PRODUCTION")
var server_host = OS.get_environment("SERVER_HOST")
var server_port = OS.get_environment("SERVER_PORT")

enum Scene { CHARACTER_SELECTION_MENU, GAME }


func read_file(file_path: String) -> String:
	var file = File.new()
	file.open(file_path, file.READ)
	var file_str = file.get_as_text()
	file.close()
	return file_str


# Character data


func get_characters(file_path: String) -> Array:
	var characters_str = read_file(file_path)
	var json = JSON.new()
	var result = json.parse(characters_str)
	if result == OK:
		return json.get_data()
	else:
		print(json.get_error_message())
		return []


var characters_file_path = "res://data/characters.json"
var characters = get_characters(characters_file_path)


func get_character_by_id(character_id: String) -> Dictionary:
	for character in characters:
		if character.id == character_id:
			return character
	print(
		"Character id `{character_id}` not found.".format(
			{"character_id": character_id}
		)
	)
	return {}


# Colour data


func get_colours(file_path: String) -> Array:
	var colours_str = read_file(file_path)
	var json = JSON.new()
	var result = json.parse(colours_str)
	if result == OK:
		return json.get_data()
	else:
		print(json.get_error_message())
		return []


var colours_file_path = "res://data/colours.json"
var colours = get_colours(colours_file_path)


func get_colour_by_id(colour_id: String) -> Color:
	for colour in colours:
		if colour.id == colour_id:
			return Color(colour.hex)
	print("Colour id `{colour_id}` not found.".format({"colour_id": colour_id}))
	return Color()
