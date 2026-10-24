extends Area2D

@export var drained_stamina_per_second: float = 25.0
var player_on_zone: Node2D = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	if player_on_zone != null:
		# Se o Player estiver na zona, drena a stamina
		if player_on_zone.has_method("spend_stamina"):
			player_on_zone.spend_stamina(drained_stamina_per_second * delta)
		
		if player_on_zone.current_stamina <= 0:
			player_on_zone.die()
			player_on_zone = null

func _on_body_entered(body: Node2D) -> void:
	# Verifica se é o Invocador (Player) e se NÃO está possuindo um NPC no momento
	if body.is_in_group("Player"):
		player_on_zone = body

func _on_body_exited(body: Node2D) -> void:
	if body == player_on_zone:
		player_on_zone = null
