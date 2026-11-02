extends Area2D

@export var teleport_destination: Marker2D
@export var main_menu: bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collisor: CollisionShape2D = $CollisionShape2D
@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	sprite_2d.visible = false
	collisor.set_deferred("disabled", true)

func click_menu() -> void:
	if main_menu:
		show_teleport()
		animation_player.play("return_menu")
		audio_stream_player.play()

func show_teleport() -> void:
	collisor.set_deferred("disabled", false)
	sprite_2d.visible = true

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.is_possessing = true
		if teleport_destination == null:
			print("WARNING: teleport_destination is not assigned in the Inspector!")
			return
		
		body.sprite.flip_h = false
		body._trocar_animacao("idle_rest")
		body.global_position = Vector2(global_position.x+1.5, global_position.y-5)
		animation_player.play("return")
		audio_stream_player.play()
		await get_tree().create_timer(1).timeout
		
		var transition = body.transition
		if transition != null:
			transition.execute_transition(func():
				body.define_new_spawn_point(teleport_destination.global_position)
				body.global_position = teleport_destination.global_position
				body.is_possessing = false
			)
		else:
			body.define_new_spawn_point(teleport_destination.global_position)
			body.global_position = teleport_destination.global_position
			body.is_possessing = false
