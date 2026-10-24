extends Area2D

signal pressed
signal unpressed

var bodies_on_plate: int = 0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	# Opcional: filtrar apenas o Player e Invocados
	bodies_on_plate += 1
	if bodies_on_plate == 1:
		pressed.emit()
		print("Plate pressed!")

func _on_body_exited(body: Node2D) -> void:
	bodies_on_plate -= 1
	if bodies_on_plate <= 0:
		bodies_on_plate = 0
		unpressed.emit()
		print("Plate unpressed!")
