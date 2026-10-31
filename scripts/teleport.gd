extends Area2D

@export var teleport_destination: Marker2D
@export var spectrum: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if teleport_destination == null:
			print("WARNING: teleport_destination is not assigned in the Inspector!")
			return

		var transition = body.transition
		if transition != null:
			transition.execute_transition(func():
				body.define_new_spawn_point(teleport_destination.global_position)
				body.global_position = teleport_destination.global_position
			)
		else:
			body.define_new_spawn_point(teleport_destination.global_position)
			body.global_position = teleport_destination.global_position
		
		if spectrum != null and spectrum.has_method("activate_chasing"):
			spectrum.activate_chasing()
