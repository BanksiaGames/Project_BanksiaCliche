extends Control

export (Array, Texture) var emojiTextures

export var emotionMax : float
export var emotionMin : float

var curEmotionValue = 0
var firstEmotion = false

func ResetEmotion():
	curEmotionValue = 0
	firstEmotion = false
	$TextureRect_Emoji.texture = emojiTextures[2]

func SetEmotionValue(_emotionValue):
	if curEmotionValue != _emotionValue:
		var bBetterEmotion = _emotionValue > curEmotionValue
		var bPlayGainEmotion = firstEmotion
		curEmotionValue = _emotionValue
		if bPlayGainEmotion:
			if bBetterEmotion :
				$TextureRect_EmojiGain.texture = emojiTextures[3]
			else:
				$TextureRect_EmojiGain.texture = emojiTextures[1]
			$AnimationPlayer.play("GainEmotion")
		else:
			firstEmotion = true
			_on_AnimationPlayer_animation_finished("")
		
func _on_Tween_tween_completed(object, key):
	var startRotation = $TextureRect_Handle.rect_rotation
	if startRotation >= 70:
		$TextureRect_Emoji.texture = emojiTextures[0]
	elif startRotation >= 26:
		$TextureRect_Emoji.texture = emojiTextures[1]
	elif startRotation >= -23:
		$TextureRect_Emoji.texture = emojiTextures[2]
	elif startRotation >= -68:
		$TextureRect_Emoji.texture = emojiTextures[3]
	else:
		$TextureRect_Emoji.texture = emojiTextures[4]

func _on_AnimationPlayer_animation_finished(anim_name):
	var emotionWeight = (curEmotionValue - emotionMin) / (emotionMax - emotionMin)
	var handleRotation = lerp(90, -90, emotionWeight)
	var startRotation = $TextureRect_Handle.rect_rotation
	$Tween.interpolate_property(
	$TextureRect_Handle, "rect_rotation", 
	startRotation, handleRotation, 0.25, 
	Tween.TRANS_BACK, Tween.EASE_OUT)
	$Tween.start()
