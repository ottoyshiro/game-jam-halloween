extends Area2D

signal collected

@export_range(1, 3) var item_id: int = 1
@export var main_scene: Node2D

@export var new_possession_time: float = 7.0
@export var new_stamina_bar: float = 200.0

@export var use_transition: bool = true

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if item_id == 1:
			animation_player.play("red")
	elif item_id == 2:
			animation_player.play("green")
	elif item_id == 3:
			animation_player.play("blue")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		sprite_2d.visible = false
		
		var collect_anim = "idle_rest"
		if item_id == 1:
			collect_anim = "collect_red"
		elif item_id == 2:
			collect_anim = "collect_green"
		elif item_id == 3:
			collect_anim = "collect_blue"
		body.start_collect(collect_anim)
		collected.emit()
		GameManager.collected_items += 1
		if main_scene != null:
			GameManager.update_levels(main_scene.levels)
		
		collect_item(body)

func collect_item(player: Node2D) -> void:
	print("Ordeal Item ", item_id, " collected!")
	
	# 1. Aplica o upgrade no Player
	if player.has_method("apply_upgrade"):
		player.apply_upgrade(item_id, new_possession_time)
	
	# 2. Executa a transição de volta ao Hub
	if use_transition and player.transition != null:
		player.transition.execute_transition(func():
			player.global_position = player.spawn_point
			await get_tree().create_timer(1.0).timeout
			player.finish_collect()
			player.animation_player.play("idle_rest")
			queue_free()
		)
	else:
		await get_tree().create_timer(1.0).timeout
		player.finish_collect()
		player.animation_player.play("idle_rest")
		queue_free()
