extends Node2D

@export var lobby: PackedScene
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	pass # Replace with function body.

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		animation_player.play("return")
		await get_tree().create_timer(1).timeout
		get_tree().change_scene_to_packed(lobby)
