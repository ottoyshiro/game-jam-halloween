extends StaticBody2D

@export var opened_by_default: bool = false
@onready var collisor: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	if opened_by_default:
		open()
	else:
		close()

func open() -> void:
	collisor.set_deferred("disabled", true)
	print("Door opened!")
	animation_player.play("open")

func close() -> void:
	collisor.set_deferred("disabled", false)
	print("Door closed!")
	animation_player.play("RESET")
