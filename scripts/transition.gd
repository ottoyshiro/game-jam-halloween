extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	color_rect.visible = true
	animation_player.play("fade_in")

func make_fade() -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	
	animation_player.play("fade_in")

func execute_transition(funcao_callable: Callable) -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	
	# Executa a função recebida (ex: teleportar o player)
	if funcao_callable.is_valid():
		funcao_callable.call()
	
	animation_player.play("fade_in")
