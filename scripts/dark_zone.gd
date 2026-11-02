extends Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var is_active: bool = false
var player_on_zone: Node2D = null
@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if is_active:
		animation_player.play("spike")

func _process(delta: float) -> void:
	pass

		#if player_on_zone.has_method("spend_stamina"):
			#player_on_zone.spend_stamina(drained_stamina_per_second * delta)
		#
		#if player_on_zone.current_stamina <= 0:
			#player_on_zone.die()
			#player_on_zone = null

func _on_body_entered(body: Node2D) -> void:
	# Verifica se é o Invocador (Player) e se NÃO está possuindo um NPC no momento

	if body.is_in_group("Player"):
		player_on_zone = body
		
		if player_on_zone != null:
			animation_player.play("spike")
			if player_on_zone.has_method("die"):
				player_on_zone.die()
				player_on_zone = null
				animation_player.play_backwards("spike")
				audio_stream_player.play()
		

func _on_body_exited(body: Node2D) -> void:
	pass
	#if body == player_on_zone:
		#player_on_zone = null
