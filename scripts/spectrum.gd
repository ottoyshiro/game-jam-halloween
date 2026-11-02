extends Area2D

@export var spectrum_velocity: float = 35.0
@export var drain_stamina_contact: float = 100.0
@export var origin_spawn: Marker2D

@onready var sprite_2d: Sprite2D = $Sprite2D

var player: CharacterBody2D = null
var is_chasing: bool = false

func _ready() -> void:
	if origin_spawn != null:
		self.global_position = origin_spawn.global_position
	
	body_entered.connect(_on_body_entered)
	player = get_tree().get_first_node_in_group("Player") as CharacterBody2D

func _physics_process(delta: float) -> void:
	if not is_chasing:
		return
	
	var current_target: Node2D = null
	var mobile_invocation = get_tree().get_first_node_in_group("MobileInvocation")
	
	if mobile_invocation != null:
		current_target = mobile_invocation
	else:
		current_target = player
	
	if current_target != null:
		var direction = (current_target.global_position - global_position).normalized()
		global_position += direction * spectrum_velocity * delta
		
		# Inverte o sprite para olhar para o lado que está andando
		if direction.x != 0:
			sprite_2d.flip_h = (direction.x < 0)

func activate_chasing() -> void:
	is_chasing = true
	print("The Spectrum awakened!")

func deactivate_chasing() -> void:
	is_chasing = false
	if origin_spawn != null:
		self.global_position = origin_spawn.global_position

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("MobileInvocation"):
		print("O Espectro destruiu a isca (Invocação Móvel)!")
		body.queue_free()
		player.is_possessing = false
		return

	if body.is_in_group("Player"):
		print("O Espectro alcançou seu corpo mortal!")

		if body.has_method("spend_stamina"):
			body.spend_stamina(drain_stamina_contact)
		if body.has_method("die"):
			body.die()

func _on_player_died() -> void:
	if origin_spawn != null:
		global_position = origin_spawn.global_position
