extends TextureButton

func _on_Button_Positive_button_down():
	$AnimationPlayer.play("Button_Choice")

func _on_Button_Positive_button_up():
	$AnimationPlayer.play_backwards("Button_Choice")
	$SFX_Clicked.play()

func _on_Button_Positive_mouse_entered():
	$Label.rect_position = Vector2(15, 10)
	$SFX_Hover.play()

func _on_Button_Positive_mouse_exited():
	$Label.rect_position = Vector2(15, 16.5)

func SetText(_text):
	$Label.text = _text
	$Label.rect_position = Vector2(15, 16.5)	
