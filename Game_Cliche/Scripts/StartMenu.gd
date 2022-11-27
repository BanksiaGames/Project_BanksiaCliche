extends CanvasLayer

signal OnGameStart

func _on_Button_GameStart_button_down():
	$AnimationPlayer.play("FadeOut")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "FadeOut":
		emit_signal("OnGameStart")

func ShowMenu(_bFadeIn):
	$AnimationPlayer_SlideIn.play("SlideIn")
	if _bFadeIn:
		$AnimationPlayer.play("FadeIn")
