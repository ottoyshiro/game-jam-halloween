extends Node

var collected_items: int = 0

func _ready() -> void:
	pass


func update_levels(levels: Array[StaticBody2D]) -> void:
	if collected_items == 1:
		levels[0].close()
		levels[1].open()
		levels[2].close()
	elif collected_items == 2:
		levels[0].close()
		levels[1].close()
		levels[2].open()
	elif collected_items == 3:
		levels[0].close()
		levels[1].close()
		levels[2].close()
