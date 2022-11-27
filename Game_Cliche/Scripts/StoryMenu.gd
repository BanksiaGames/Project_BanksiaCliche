extends CanvasLayer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal OnStoryEnd

export (Array, Texture) var StoryScenes
export (Array, String) var StoryTexts

var curStoryIndex = 0

func StartPrologue():
	curStoryIndex = 0
	PlayStory()

func PlayStory():
	if curStoryIndex >= StoryScenes.size():
		emit_signal("OnStoryEnd")
		return
	
	$StoryBoard/TextureRect_Scene.texture = StoryScenes[curStoryIndex]
	$StoryBoard/Label.StartTyping(StoryTexts[curStoryIndex], 0.05)
	$AnimationPlayer_Typing.stop()
	$AnimationPlayer_Typing.play("PlayTypingSFX")
	$Timer.start()
	curStoryIndex += 1

func _on_Timer_timeout():
	PlayStory()
