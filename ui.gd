extends Control

@onready var right_score_label: Label = $MarginContainer/HSplitContainer/RightScore
@onready var left_score_label: Label = $MarginContainer/HSplitContainer/LeftScore

func _ready() -> void:
	update_l_score(0)
	update_r_score(0)

func update_l_score(new_score: int) -> void:
	right_score_label.text = str(new_score)

func update_r_score(new_score: int) -> void:
	left_score_label.text = str(new_score)
