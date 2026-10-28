extends CharacterBody2D

@export var life_time: float = 4.0

func _ready() -> void:
	if life_time > 0:
		await get_tree().create_timer(life_time).timeout
		queue_free()
