extends Area2D

@export var teleport_destination: Marker2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var transition = body.transition
		if transition != null:
			transition.execute_transition(func():
				body.global_position = teleport_destination.global_position
			)
		else:
			body.global_position = teleport_destination.global_position
