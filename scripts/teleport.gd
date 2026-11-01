extends Area2D

@export var teleport_destination: Marker2D
@export var spectrum: Node2D
@export var zoom_alvo: Vector2 = Vector2(2, 2)
@export var tempo_transicao: float = 0.8

var zoom_original: Vector2 = Vector2(1, 1)
var player_camera: Camera2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if GameManager.collected_items == 2:
			if body.has_node("Camera2D"):
				var camera = body.get_node("Camera2D") as Camera2D
				player_camera = camera

				zoom_original = camera.zoom
				var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
				tween.tween_property(camera, "zoom", zoom_alvo, tempo_transicao)

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
