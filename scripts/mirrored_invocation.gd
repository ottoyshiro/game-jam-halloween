extends CharacterBody2D

@export var max_speed: float = 100.0
@export var acceleration: float = 2000.0
@export var friction: float = 2000.0
@export var moving_area: Area2D
@export var origin_spawn: Marker2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

var ultima_direcao_olhando: String = "idle_rest"
var can_move: bool = false

func _ready() -> void:
	animation_player.play("idle_rest")
	if origin_spawn != null:
		global_position = origin_spawn.global_position
	

func _process(delta: float) -> void:
	pass
		

func _physics_process(delta: float) -> void:
	if GameManager.is_mirror_stopped:
		return
	if can_move:
		var input_vector: Vector2 = Input.get_vector("left", "right", "up", "down")
		
		# Inverte o vetor multiplicando por -1
		var input_espelhado: Vector2 = -input_vector
		
		if input_espelhado != Vector2.ZERO:
			velocity = velocity.move_toward(input_espelhado * max_speed, acceleration * delta)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		
		# SÓ muda a animação se o jogador estiver realmente pressionando alguma tecla
		if input_vector != Vector2.ZERO:
			if abs(input_vector.x) > abs(input_vector.y):
				if input_vector.x < 0:
					sprite.flip_h = true
				else:
					sprite.flip_h = false
				ultima_direcao_olhando = "idle" # "idle" lateral
			else:
				if input_vector.y < 0:
					ultima_direcao_olhando = "idle_rest" # Olhando para cima
				else:
					ultima_direcao_olhando = "backwards" # Olhando para frente
		
		# Aplica a animação baseada na última direção guardada (seja andando ou parado)
		_trocar_animacao(ultima_direcao_olhando)
			
		move_and_slide()

func _on_player_died() -> void:
	if origin_spawn != null:
		global_position = origin_spawn.global_position

func on_moving_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		can_move = true

func on_moving_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		can_move = false

func _trocar_animacao(nome_animacao: String) -> void:
	if animation_player.current_animation != nome_animacao:
		animation_player.play(nome_animacao)
