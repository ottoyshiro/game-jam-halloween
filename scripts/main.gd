extends Node2D

@onready var level_1: StaticBody2D = $Door_hub
@onready var level_2: StaticBody2D = $Door_hub2
@onready var level_3: StaticBody2D = $Door_hub3

var levels: Array[StaticBody2D] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level_1.open()
	level_2.close()
	level_3.close()
	
	levels.append(level_1)
	levels.append(level_2)
	levels.append(level_3)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
