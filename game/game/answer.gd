extends ColorRect

@onready var answer_label = $"AnswerLabel"


func reset() -> void:
	color = Color("#000000")


func set_label(answer: String) -> void:
	answer_label.text = answer


func reveal(correct: bool) -> void:
	if correct:
		color = Color("#88FF88")
	else:
		color = Color("#FF8888")
