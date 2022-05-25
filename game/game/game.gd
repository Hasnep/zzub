extends CanvasLayer

signal get_question

@onready var websocket_client
@onready var question_label = $"QuestionBox/Question"
@onready var answer_nodes = [
	$"QuestionBox/Answer1",
	$"QuestionBox/Answer2",
	$"QuestionBox/Answer3",
	$"QuestionBox/Answer4"
]

var json = JSON.new()

#func _ready():
#	websocket_client.set_question.connect(self._on_set_question)
#	websocket_client.reveal_answer.connect(self._on_reveal_answer)
#	self.get_question.connect(websocket_client._on_get_question)
#	emit_signal("get_question")


func _on_set_question(question: String, answers: Array) -> void:
	question_label.text = question
	for i in range(4):
		answer_nodes[i].reset()
		answer_nodes[i].set_label(answers[i])


func _on_reveal_answer(correct_answer_index: int) -> void:
	answer_nodes[correct_answer_index].reveal(true)
