extends StaticBody2D

@export var opened_by_default: bool = false
@onready var collisor: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	if opened_by_default:
		open()
	else:
		close()

func open() -> void:
	collisor.set_deferred("disabled", true)
	sprite.visible = false
	print("Door opened!")

func close() -> void:
	collisor.set_deferred("disabled", false)
	sprite.visible = true
	print("Door closed!")
