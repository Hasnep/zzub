extends CanvasLayer

signal get_question
signal get_all_player_data

@onready var websocket_client
@onready var question_label = $"Background/QuestionBox/Question"
@onready var answer_nodes = [
	$"Background/QuestionBox/Answer1",
	$"Background/QuestionBox/Answer2",
	$"Background/QuestionBox/Answer3",
	$"Background/QuestionBox/Answer4",
]
@onready var timer = $"Timer"
@onready var player_leaderboard = $"Background/PlayerLeaderboard"
@onready var characters = $"Background/Characters"
@onready var question_category_label = $"Background/QuestionBox/QuestionCategoryLabel"

# Preload scenes
var player_score_scene = preload("res://game/player_score.tscn")
var character_scene = preload("res://game/character.tscn")

# Set constants
const ANSWER_TIMEOUT_SECONDS := 3.0


func _ready() -> void:
	# Connect singals
	websocket_client.set_question.connect(self._on_set_question)
	websocket_client.reveal_answer.connect(self._on_reveal_answer)
	websocket_client.send_all_player_data.connect(self._on_send_all_player_data)
	self.get_question.connect(websocket_client._on_get_question)
	self.get_all_player_data.connect(websocket_client._on_get_all_player_data)
	timer.timeout.connect(self._on_timer_timeout)

	# Request player data
	emit_signal("get_all_player_data")


func _on_send_all_player_data(player_data: Array) -> void:
	_remove_all_players()
	for player in player_data:
		_add_player(
			player.player_id, player.character_id, player.colour_id, player.player_name
		)

	# Get the first question
	timer.start(0.0)


func _remove_all_players() -> void:
	for child in player_leaderboard.get_children():
		child.queue_free()

	for child in characters.get_children():
		child.queue_free()


func _add_player(
	player_id: String, character_id: String, colour_id: String, player_name: String
) -> void:
	var player_score = player_score_scene.instantiate()
	player_score.my_player_id = player_id
	player_score.my_character_id = character_id
	player_score.my_colour_id = colour_id
	player_score.my_player_name = player_name
	websocket_client.set_player_score.connect(player_score._on_set_player_score)
	player_leaderboard.add_child(player_score)

	var character = character_scene.instantiate()
	character.my_player_id = player_id
	character.my_character_id = character_id
	character.my_player_name = player_name
	characters.add_child(character)


func _on_set_question(question: String, answers: Array, category: String) -> void:
	question_label.text = question
	question_category_label.text = category
	for i in range(4):
		answer_nodes[i].reset()
		answer_nodes[i].set_label(answers[i])


func _on_reveal_answer(correct_answer_index: int) -> void:
	# Reveal answers
	for i in range(4):
		answer_nodes[i].reveal(i == correct_answer_index)

	# Wait a short time for players to see the answers
	timer.start(ANSWER_TIMEOUT_SECONDS)


func _on_timer_timeout() -> void:
	# Reset answer buttons
	for i in range(4):
		answer_nodes[i].reset()

	# Get the next question
	emit_signal("get_question")
