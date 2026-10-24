extends Area2D

@onready var interaction_text: Label = $CanvasLayer/Label
@onready var altar_info: Label = $CanvasLayer/AltarInfo

@export var evil_beast_scene: PackedScene

var player_on_reach: Node2D = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if interaction_text != null:
		interaction_text.visible = false

	if altar_info != null:
		altar_info.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_on_reach = body
		if interaction_text != null:
			interaction_text.visible = true
		
		if altar_info != null:
			altar_info.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body == player_on_reach:
		player_on_reach = null
		if interaction_text != null:
			interaction_text.visible = false
		
		if altar_info != null:
			altar_info.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if player_on_reach != null and event.is_action_pressed("interact"):
		try_start_ritual()

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
	
	# 2. Transição visual ou tremor de câmera (Screen Shake)
	print("The floor shake... The shadows stir!")
	
	# 3. Instancia a Besta gigante no topo do Altar
	if evil_beast_scene != null:
		var beast = evil_beast_scene.instantiate()
		beast.global_position = global_position + Vector2(0, -32) # Um pouco acima da mesa
		get_parent().add_child(beast)
	
	# 4. Aguarda um momento dramático (ex: 2 segundos)
	await get_tree().create_timer(2.0).timeout
	
	# 5. Tela de Morte / Fim Trágico
	exibir_tela_final()

func exibir_tela_final() -> void:
	# Apaga o Player (simula a morte pela besta)
	if player_on_reach != null:
		player_on_reach.visible = false
	
	print("In an attempt to become the greatest summoner of all time, you summoned an evil beast that destroyed you.")
	
	# Você pode alternar para uma nova Cena de Créditos/Fim ou mostrar uma UI de Game Over:
	# get_tree().change_scene_to_file("res://Cenas/TelaFinal.tscn")
