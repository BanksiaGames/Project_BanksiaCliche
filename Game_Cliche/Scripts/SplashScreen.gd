extends CanvasLayer

signal OnSplashShow
signal OnSplashHide

func CallOnSpalshShow():
	emit_signal("OnSplashShow")

func CallOnSplashHide():
	emit_signal("OnSplashHide")

func PlayFadeOut():
	$AnimationPlayer.play("FadeOut")
