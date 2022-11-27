extends CanvasLayer

signal OnGameOverEnd

func ShowGameOver(_endingMessage : String):
	$Label_GameOver.StartTyping(_endingMessage, 0.1)
	$AnimationPlayer_Typing.play("PlayTypingSFX")
	$Timer.start(_endingMessage.length() * 0.1 + 5)
	
func _on_Timer_timeout():
	emit_signal("OnGameOverEnd")
