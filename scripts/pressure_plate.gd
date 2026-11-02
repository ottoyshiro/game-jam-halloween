extends Area2D

signal pressed
signal unpressed

var bodies_on_plate: int = 0
@export var spikes: Array[Area2D] = []
@export var partner: Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	if len(spikes) > 0:
		for spike in spikes:
			spike.get_node("Sprite2D").visible = true
			spike.get_node("CollisionShape2D").set_deferred("disabled", false)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	# Opcional: filtrar apenas o Player e Invocados
	if bodies_on_plate == 0:
		audio_stream_player.play()
		animation_player.play("pressed")
	bodies_on_plate += 1
	if bodies_on_plate == 1:
		pressed.emit()
		print("Plate pressed!")
	if len(spikes) > 0:
		for spike in spikes:
			spike.get_node("Sprite2D").visible = false
			spike.get_node("CollisionShape2D").set_deferred("disabled", true)
	

func _on_body_exited(body: Node2D) -> void:
	if bodies_on_plate == 1:
		audio_stream_player.play()
		animation_player.play("unpressed")
	if partner != null:
		if partner.bodies_on_plate > 0:
			return
	bodies_on_plate -= 1
	if bodies_on_plate <= 0:
		bodies_on_plate = 0
		unpressed.emit()
		print("Plate unpressed!")
	if len(spikes) > 0:
		for spike in spikes:
			spike.get_node("Sprite2D").visible = true
			spike.get_node("CollisionShape2D").set_deferred("disabled", false)
	
