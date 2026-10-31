extends Camera2D

# Configurações do tremor
@export var forca_tremor_padrao: float = 8.0
@export var duracao_padrao: float = 0.4

# Função principal para disparar o tremor
func tremer_tela(duracao: float = duracao_padrao, forca: float = forca_tremor_padrao) -> void:
	var tempo_decorrido: float = 0.0
	var offset_original: Vector2 = offset
	
	# Cria um loop rápido para aplicar offsets aleatórios enquanto o tempo durar
	while tempo_decorrido < duracao:
		# Gera um deslocamento aleatório nos eixos X e Y baseado na força atual
		var deslocamento_aleatorio = Vector2(
			randf_range(-forca, forca),
			randf_range(-forca, forca)
		)
		
		# Anima o offset rapidamente usando um Tween de curta duração
		var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(self, "offset", deslocamento_aleatorio, 0.03)
		
		# Aguarda o tween terminar antes de gerar o próximo tremor
		await tween.finished
		tempo_decorrido += 0.03
		
	# Retorna a câmera exatamente para a posição original ao terminar
	var tween_fim = create_tween()
	tween_fim.tween_property(self, "offset", offset_original, 0.05)

# Função para mover a câmera suavemente para um ponto específico do mundo
func mover_foco_para(posicao_alvo: Vector2, duracao: float) -> void:
	# Como a câmera é filha do player, convertemos a posição global do altar
	# para a posição local (relativa ao player)
	var posicao_local_alvo = get_parent().to_local(posicao_alvo)
	
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", posicao_local_alvo, duracao)

# Função para a câmera voltar a focar no centro do player
func voltar_foco_player(duracao: float) -> void:
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", Vector2.ZERO, duracao) 
