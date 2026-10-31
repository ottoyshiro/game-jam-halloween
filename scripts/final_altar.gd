extends Area2D

@onready var interaction_text: Label = $CanvasLayer/Label
@onready var altar_info: RichTextLabel = $CanvasLayer/AltarInfo
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var game_over: RichTextLabel = $CanvasLayer/GameOver

@export var evil_beast_scene: PackedScene
@export var zoom_alvo: Vector2 = Vector2(1.3, 1.3)
@export var tempo_transicao: float = 0.8

@export var doors_positions: Array[Marker2D]

var zoom_original: Vector2 = Vector2(1, 1)
var player_on_reach: Node2D = null
var player_camera: Camera2D = null
var skull_phrases: Array[String] = ["You wanna be stronger? I'll give you power if you bring to me all of the tree crystals spread in this dungeon",
"If so, you'll be the most powerful sorcerer in the world!!"]
var red_inserted: bool = false
var green_inserted: bool = false
var blue_inserted: bool = false
var is_running: bool = false
### You wanna be stronger? I'll give you power if you bring to me all of the tree crystals spread in this dungeon
### If so, you'll be the most powerful sorcerer in the world!!

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if interaction_text != null:
		interaction_text.visible = false

	if altar_info != null:
		altar_info.visible = false

func _on_body_entered(body: Node2D) -> void:
	if GameManager.collected_items > 0:
		if interaction_text != null:
			interaction_text.visible = false
			interaction_text.text = "Press [E] to insert the gem on vessel"

	if body.is_in_group("Player"):
		player_on_reach = body
		
		if body.has_node("Camera2D"):
			var camera = body.get_node("Camera2D") as Camera2D
			player_camera = camera

			#if camera.has_method("mover_foco_para"):
				#for i in range(len(doors_positions)):
					#camera.mover_foco_para(doors_positions[i].global_position, 0.8)
					#await get_tree().create_timer(1).timeout
			#
			#if camera.has_method("voltar_foco_player"):
				#camera.voltar_foco_player(0.8)
			
			zoom_original = camera.zoom
			var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			tween.tween_property(camera, "zoom", zoom_alvo, tempo_transicao)

		if interaction_text != null:
			interaction_text.visible = true
		
		if altar_info != null:
			altar_info.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body == player_on_reach:
		if player_on_reach.has_node("Camera2D"):
			var camera = player_on_reach.get_node("Camera2D") as Camera2D
			
			var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			tween.tween_property(camera, "zoom", zoom_original, tempo_transicao)
		player_on_reach = null
		if interaction_text != null:
			interaction_text.visible = false
		
		if altar_info != null:
			altar_info.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if player_on_reach != null and event.is_action_pressed("interact"):
		player_on_reach.is_possessing = true
		if is_running:
			return
		is_running = true
		
		if interaction_text != null:
			interaction_text.visible = false
			
		if altar_info != null:
			altar_info.visible = false
		
		if GameManager.collected_items == 1 and not red_inserted:
			animation_player.play("red")
			red_inserted = true
		elif GameManager.collected_items == 2 and not green_inserted:
			animation_player.play("green")
			green_inserted = true
		elif GameManager.collected_items == 3 and not blue_inserted:
			animation_player.play("blue")
			blue_inserted = true
		
		await get_tree().create_timer(2).timeout
		try_start_ritual()
		
		if GameManager.collected_items == 3:
			return
		if player_camera != null and player_camera.has_method("mover_foco_para"):
			for i in range(len(doors_positions)):
				player_camera.mover_foco_para(doors_positions[i].global_position, 0.8)
				
				var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
				tween.tween_property(player_camera, "zoom", zoom_original, tempo_transicao)
				
				await get_tree().create_timer(1).timeout
			
		if player_camera.has_method("voltar_foco_player"):
			player_camera.voltar_foco_player(0.8)
			
		var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(player_camera, "zoom", zoom_alvo, tempo_transicao)

		is_running = false
		player_on_reach.is_possessing = false
		
		if interaction_text != null:
			interaction_text.visible = true
		
		if altar_info != null:
			altar_info.visible = true

func try_start_ritual() -> void:
	# Verifica se o Player possui os 3 itens registrados no Array
	if player_on_reach.collected_items.size() >= 3:
		print("Ritual started! All 3 items were placed in altar.")
		execute_final_game()
	else:
		var missing = 3 - player_on_reach.collected_items.size()
		print("The altar consume energy... Still missing ", missing, " item(s)!")

func execute_final_game() -> void:
	# 1. Bloqueia movimentação do Player
	player_on_reach.set_physics_process(false)
	
	if player_on_reach.has_node("Camera2D"):
		var camera = player_on_reach.get_node("Camera2D")
		animation_player.play("final")
		if camera.has_method("tremer_tela"):
			camera.tremer_tela(1.5, 12.0)
	# 2. Transição visual ou tremor de câmera (Screen Shake)
	print("The floor shake... The shadows stir!")
	
	# 3. Instancia a Besta gigante no topo do Altar
	if evil_beast_scene != null:
		var beast = evil_beast_scene.instantiate()
		beast.global_position = global_position + Vector2(0, -32) # Um pouco acima da mesa
		get_parent().add_child(beast)
	
	# 4. Aguarda um momento dramático (ex: 2 segundos)
	await get_tree().create_timer(10.0).timeout
	animation_player.play("death_")
	# 5. Tela de Morte / Fim Trágico
	exibir_tela_final()

func exibir_tela_final() -> void:
	# Apaga o Player (simula a morte pela besta)
	if player_on_reach != null:
		player_on_reach.visible = false
	
	if altar_info != null:
		altar_info.visible = true
		altar_info.text = "[wave amp=20 freq=3]In an attempt to become the greatest summoner of all time, you summoned an evil beast that destroyed you.[/wave]"
		await get_tree().create_timer(4.0).timeout
		animation_player.play("death")
		await get_tree().create_timer(1.0).timeout
		game_over.visible = true
	print("In an attempt to become the greatest summoner of all time, you summoned an evil beast that destroyed you.")
	
	# Você pode alternar para uma nova Cena de Créditos/Fim ou mostrar uma UI de Game Over:
	# get_tree().change_scene_to_file("res://Cenas/TelaFinal.tscn")
