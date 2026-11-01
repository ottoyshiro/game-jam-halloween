extends CharacterBody2D

@export var invocation_velocity: float = 120.0
@export var max_time_possession: float = 3.0
@export var life_time: float = 10.0

@onready var camera: Camera2D = $Camera2D
@onready var timer_possession: Timer = $TimerPossession
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var being_possessed: bool = false
var player_ref: CharacterBody2D = null

func _ready() -> void:
	add_to_group("MobileInvocation")
	timer_possession.timeout.connect(_on_timer_possession_timeout)
	
	if life_time > 0:
		await get_tree().create_timer(life_time).timeout
		queue_free()

func _physics_process(delta: float) -> void:
	if being_possessed:
		var direction = Input.get_vector("left", "right", "up", "down")
		velocity = direction * invocation_velocity
		
		if abs(direction.x) > abs(direction.y):
			# Movimento horizontal
			if direction.x < 0:
				sprite.flip_h = false
			else:
				sprite.flip_h = true
		
		if direction.y < 0:
			_trocar_animacao("backwards")
		else:
			_trocar_animacao("idle")

		move_and_slide()

func _trocar_animacao(nome_animacao: String) -> void:
	if animation_player.current_animation != nome_animacao:
		animation_player.play(nome_animacao)

func start_possession(player: CharacterBody2D) -> void:
	player_ref = player
	being_possessed = true
	
	# Change the current Player camera to this NPC camera
	camera.make_current()
	
	# Start the timer
	timer_possession.start(max_time_possession)
	print("Possession started! Time remaining: ", max_time_possession)

func _on_timer_possession_timeout() -> void:
	finish_possession()

func finish_possession() -> void:
	if not being_possessed:
		return
		
	being_possessed = false
	velocity = Vector2.ZERO
	
	# Returns the control and the camera to Player
	if player_ref != null:
		player_ref.return_control()
		player_ref = null
		
	print("Possession finished!")
