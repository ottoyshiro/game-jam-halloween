class_name Player
extends CharacterBody2D

signal stamina_changed(current_stamina, max_stamina)

@export var max_stamina: float = 100.0
@export var regeneration_rate: float = 10.0
@export var max_speed: float = 300.0
@export var acceleration: float = 2000.0
@export var friction: float = 2000.0

@export var static_invocation_scene: PackedScene
@export var static_invocation_cost: float = 30.0
@export var invocation_distance: float = 32.0

@export var mobile_invocation_scene: PackedScene
@export var mobile_invocation_cost: float = 50.0

@onready var camera: Camera2D = $Camera2D

var last_direction: Vector2 = Vector2.DOWN
var current_stamina: float
var is_possessing: bool = false

func _ready() -> void:
	current_stamina = max_stamina
	stamina_changed.emit(current_stamina, max_stamina)

func _process(delta: float) -> void:
	if velocity.length() > 0:
		last_direction = velocity.normalized()

	# stamina regeneration
	if current_stamina < max_stamina:
		current_stamina += regeneration_rate * delta
		current_stamina = clamp(current_stamina, 0, max_stamina)
		stamina_changed.emit(current_stamina, max_stamina)

func _physics_process(delta: float) -> void:
	if is_possessing:
		velocity = Vector2.ZERO
		return
	
	var input_vector: Vector2 = Input.get_vector("left", "right", "up", "down")
	
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if is_possessing:
		if event.is_action_pressed("ui_cancel"):
			pass
		return

	if event.is_action_pressed("ui_accept"):
		static_invoke()
	
	if event.is_action_pressed("ui_focus_next"):
		mobile_invoke()

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
			
			var spawn_position = global_position + (last_direction * invocation_distance)
			invoke.global_position = spawn_position
			
			get_parent().add_child(invoke)
			assume_possession(invoke)

func assume_possession(invocation) -> void:
	is_possessing = true
	invocation.start_possession(self)

func return_control() -> void:
	is_possessing = false
	if camera != null:
		camera.make_current()

func spend_stamina(cost: float) -> bool:
	if current_stamina >= cost:
		current_stamina -= cost
		stamina_changed.emit(current_stamina, max_stamina)
		return true
	else:
		return false
