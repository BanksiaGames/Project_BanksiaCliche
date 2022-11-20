extends Control

class_name HermesBubble

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal onBubbleClicked(_bubbleIndex)

var itemConfig = GDSheets.sheet("Items")
var bubbleIndex : int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("BubbleFloat")
	
func RefreshBubble(_itemId, _index):
	var itemImagePath = itemConfig[_itemId]["Image"]
	var texture = load(itemImagePath)
	$Body/Item.texture = texture
	$Timer.wait_time = _index * 0.075 + 0.25
	$Timer.start()
	bubbleIndex = _index
	$sfx_popup.volume_db = 5
	$AnimationPlayer_Body.play("Reset")

func _on_Timer_timeout():
	$AnimationPlayer_Popup.play("BubblePopup")	

func _on_TextureButton_button_up():
	emit_signal("onBubbleClicked", bubbleIndex)
	$sfx_click.play()

func _on_TextureButton_mouse_entered():
	$AnimationPlayer_Hover.play("BubbleFocus")		
	$sfx_select.play()

func _on_TextureButton_mouse_exited():
	$AnimationPlayer_Hover.play_backwards("BubbleFocus")

func PlayExplode():
	$AnimationPlayer_Body.play("BubbleExplode")

func PlayFall():
	$AnimationPlayer_Body.play("BubbleFall")

func PlayGain():
	yield(get_tree().create_timer(0.3), "timeout")	
	$AnimationPlayer_Body.play("BubbleGain")

func SetBubbleVolume(_volumedB):
	$sfx_popup.volume_db = _volumedB
