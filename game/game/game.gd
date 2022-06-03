extends CanvasLayer

signal get_question

@onready var websocket_client
@onready var question_label = $"Background/HSplitContainer/VSplitContainer/MarginContainer/QuestionBox/Question"
@onready var answer_nodes = [
	$"Background/HSplitContainer/VSplitContainer/MarginContainer/QuestionBox/Answer1",
	$"Background/HSplitContainer/VSplitContainer/MarginContainer/QuestionBox/Answer2",
	$"Background/HSplitContainer/VSplitContainer/MarginContainer/QuestionBox/Answer3",
	$"Background/HSplitContainer/VSplitContainer/MarginContainer/QuestionBox/Answer4",
]
@onready var timer = $"Timer"

var ANSWER_TIMEOUT_SECONDS: float = 3.0


func _ready():
	websocket_client.set_question.connect(self._on_set_question)
	websocket_client.reveal_answer.connect(self._on_reveal_answer)
	self.get_question.connect(websocket_client._on_get_question)
	timer.timeout.connect(self._on_timer_timeout)
	# Get the first question
	timer.start(0.0)


func _on_set_question(question: String, answers: Array) -> void:
	question_label.text = question
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
