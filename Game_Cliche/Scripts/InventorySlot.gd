extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var normalTexture : Texture
export var hoverTexture : Texture

export var interactBGTexture1 : Texture
export var interactBGTexture2 : Texture

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

var bShowInteract = false

func _process(delta):
	if $Interact.visible != bShowInteract:
		if bShowInteract:
			ShowInteract()
		else:
			HideInteract()
					

func ShowInteract():
	$TextureRect.texture = hoverTexture
	$Interact.show()
	$AnimationPlayer.play("InventorySlotHovered")

func HideInteract():
	$TextureRect.texture = normalTexture
	$Interact.hide()
	$AnimationPlayer.play_backwards("InventorySlotHovered")

func _on_InventorySlot_mouse_entered():
	bShowInteract = true
	
func _on_InventorySlot_mouse_exited():
	bShowInteract = false	

func _on_Interact_mouse_entered():
	bShowInteract = true

func _on_Interact_mouse_exited():
	bShowInteract = false	

func _on_TextureButton_Sell_mouse_entered():
	bShowInteract = true
	
func _on_TextureButton_Sell_mouse_exited():
	bShowInteract = false	

func _on_TextureButton_Throw_mouse_entered():
	bShowInteract = true

func _on_TextureButton_Throw_mouse_exited():
	bShowInteract = false

func _on_TextureButton_Sell_button_down():
	$AnimationPlayer.play("ButtonClicked_Sell")

func _on_TextureButton_Sell_button_up():
	$AnimationPlayer.play_backwards("ButtonClicked_Sell")
	$CloseInteractTimer.start()

func _on_TextureButton_Throw_button_down():
	$AnimationPlayer.play("ButtonClicked_Throw")

func _on_TextureButton_Throw_button_up():
	$AnimationPlayer.play_backwards("ButtonClicked_Throw")
	$CloseInteractTimer.start()

func _on_CloseInteractTimer_timeout():
	bShowInteract = false
	
func RefreshSlot(itemId):
	pass
