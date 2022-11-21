extends TextureButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Button_Positive_button_down():
	$AnimationPlayer.play("Button_Choice")

func _on_Button_Positive_button_up():
	$AnimationPlayer.play_backwards("Button_Choice")
	$SFX_Clicked.play()


func _on_Button_Positive_mouse_entered():
	$Label.rect_position = Vector2(0, 10)
	$SFX_Hover.play()

func _on_Button_Positive_mouse_exited():
	$Label.rect_position = Vector2(0, 16.5)	
	pass # Replace with function body.
