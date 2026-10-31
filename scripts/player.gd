class_name Player
extends CharacterBody2D

### x = 351 y = 548

signal stamina_changed(current_stamina, max_stamina)

@export var max_stamina: float = 100.0
@export var regeneration_rate: float = 10.0
@export var max_speed: float = 100.0
@export var acceleration: float = 2000.0
@export var friction: float = 2000.0

@export var static_invocation_scene: PackedScene
@export var static_invocation_cost: float = 30.0
@export var invocation_distance: float = 12.0

@export var mobile_invocation_scene: PackedScene
@export var mobile_invocation_cost: float = 50.0
@export var current_time_possession: float = 3.0

@export var transition: CanvasLayer

@onready var camera: Camera2D = $Camera2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var last_direction: Vector2 = Vector2.DOWN
var current_stamina: float
var is_possessing: bool = false
var is_collecting: bool = false
var spawn_point: Vector2

var time_stopped: float = 0.0
var can_sleep: bool = false

var collected_items: Array[int] = []

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	animation_player.play("idle_rest")
	transition.visible = true
	
	current_stamina = max_stamina
	stamina_changed.emit(current_stamina, max_stamina)
	
	var spawn_node = get_tree().get_first_node_in_group("SpawnPoint")
	if spawn_node != null:
		spawn_point = spawn_node.global_position
		self.global_position = spawn_point
	else:
		spawn_point = self.global_position

func _process(delta: float) -> void:
	if velocity.length() > 0:
		last_direction = velocity.normalized()

	# stamina regeneration
	if current_stamina < max_stamina:
		current_stamina += regeneration_rate * delta
		current_stamina = clamp(current_stamina, 0, max_stamina)
		stamina_changed.emit(current_stamina, max_stamina)

func _physics_process(delta: float) -> void:
	if is_possessing or is_collecting:
		velocity = Vector2.ZERO
		return
	
	var input_vector: Vector2 = Input.get_vector("left", "right", "up", "down")
	
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * max_speed, acceleration * delta)
		
		# Determina qual animação e direção usar com base no input atual
		if abs(input_vector.x) > abs(input_vector.y):
			# Movimento horizontal
			if input_vector.x < 0:
				sprite.flip_h = false
			else:
				sprite.flip_h = true
			_trocar_animacao("idle")
		else:
			# Movimento vertical
			if input_vector.y < 0:
				_trocar_animacao("backwards")
			else:
				_trocar_animacao("idle_rest")
		
		# Reseta o temporizador de AFK
		time_stopped = 0.0
		can_sleep = false
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		
		# Se estiver parado, lida com o sistema de AFK
		time_stopped += delta
		if time_stopped >= 7.0 and not can_sleep:
			player_is_afk()
			can_sleep = true
		elif time_stopped < 5.0 and not can_sleep:
			# Mantém a última animação ou uma animação de idle padrão
			pass
		
	move_and_slide()

# Função auxiliar para trocar animação APENAS se for diferente da atual
func _trocar_animacao(nome_animacao: String) -> void:
	if animation_player.current_animation != nome_animacao:
		animation_player.play(nome_animacao)

func _unhandled_input(event: InputEvent) -> void:
	if is_possessing:
		if event.is_action_pressed("ui_cancel"):
			pass
		return

	if event.is_action_pressed("ui_accept"):
		static_invoke()
	
	if event.is_action_pressed("ui_focus_next"):
		mobile_invoke()


func player_is_afk() -> void:
	animation_player.play("idle_sleep")

func static_invoke() -> void:
	if spend_stamina(static_invocation_cost):
		if static_invocation_scene != null:
			var invoke = static_invocation_scene.instantiate()
			
			var spawn_position = global_position + (last_direction * invocation_distance)
			invoke.global_position = spawn_position
			
			get_parent().add_child(invoke)
			print("Object invoked successfully!")
		else:
			print("ERROR: You forgot to put the static_invocation_scene on inspector!")

func mobile_invoke() -> void:
	if spend_stamina(mobile_invocation_cost):
		if mobile_invocation_scene != null:
			var invoke = mobile_invocation_scene.instantiate()
			
			invoke.max_time_possession = current_time_possession
			
			var spawn_position = global_position + (last_direction * invocation_distance)
			invoke.global_position = spawn_position
			
			get_parent().add_child(invoke)
			assume_possession(invoke)
			GameManager.is_mirror_stopped = true

func assume_possession(invocation) -> void:
	is_possessing = true
	invocation.start_possession(self)

func return_control() -> void:
	is_possessing = false
	GameManager.is_mirror_stopped = false
	if camera != null:
		camera.make_current()

func spend_stamina(cost: float) -> bool:
	if current_stamina >= cost:
		current_stamina -= cost
		stamina_changed.emit(current_stamina, max_stamina)
		return true
	else:
		current_stamina = 0.0
		stamina_changed.emit(current_stamina, max_stamina)
		return false

func die() -> void:
	if transition != null:
		transition.execute_transition(_execute_respawn)
	else:
		_execute_respawn()

func define_new_spawn_point(new_position: Vector2) -> void:
	spawn_point = new_position
	print("Spawn point updated to: ", spawn_point)

func _execute_respawn() -> void:
	print("The Invoker succumbed to the darkness... Returning to Hub!")
	if is_possessing:
		return_control()
	
	current_stamina = max_stamina
	stamina_changed.emit(current_stamina, max_stamina)
	
	self.global_position = spawn_point

func apply_upgrade(item_id: int, new_time_possession: float) -> void:
	if not collected_items.has(item_id):
		collected_items.append(item_id)
		print("Player items: ", collected_items)
	current_time_possession = new_time_possession
	print("Upgrade applied! New time possession: ", current_time_possession)

func start_collect(nome_animacao: String) -> void:
	is_collecting = true
	velocity = Vector2.ZERO
	print("Tentando tocar animação no Player: ", nome_animacao)
	_trocar_animacao(nome_animacao)

func finish_collect() -> void:
	is_collecting = false
