extends Area2D

@export_range(1, 3) var item_id: int = 1
@export var main_scene: Node2D

@export var new_possession_time: float = 7.0
@export var new_stamina_bar: float = 200.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if item_id == 1:
			body.animation_player.play("collect_red")
		elif item_id == 2:
			body.animation_player.play("collect_green")
		elif item_id == 3:
			body.animation_player.play("collect_blue")
			
		collect_item(body)
		GameManager.collected_items += 1
		GameManager.update_levels(main_scene.levels)
		
		if item_id == 1:
			body.animation_player.play("collect_red")
		elif item_id == 2:
			body.animation_player.play("collect_green")
		elif item_id == 3:
			body.animation_player.play("collect_blue")

func collect_item(player: Node2D) -> void:
	print("Ordeal Item ", item_id, " collected!")
	
	# 1. Aplica o upgrade no Player
	if player.has_method("apply_upgrade"):
		player.apply_upgrade(item_id, new_possession_time)
	
	# 2. Executa a transição de volta ao Hub
	var transition = player.transition
	if transition != null:
		transition.execute_transition(func():
			player.global_position = player.spawn_point
			queue_free()
		)
	else:
		player.global_position = player.spawn_point
		queue_free()
