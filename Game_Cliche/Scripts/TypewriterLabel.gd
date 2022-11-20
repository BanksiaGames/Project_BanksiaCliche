extends Label

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func StartTyping(_text, _typeSpeed):
	text = _text
	percent_visible = 0
	var typingTime = _typeSpeed * text.length()
	$Tween.interpolate_property(
		self, "percent_visible", 
		0.0, 1.0, typingTime, 
		Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$Tween.start()
	return typingTime
