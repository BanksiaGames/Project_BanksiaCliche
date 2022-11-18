extends Control

class_name InventorySlot

enum SlotState { Normal, ThrowOnly, SellOnly }

export var normalTexture : Texture
export var hoverTexture : Texture

export var interactBGTexture1 : Texture
export var interactBGTexture2 : Texture

signal onSellClicked(_slotIndex)
signal onThrowClicked(_slotIndex)

var itemConfig = GDSheets.sheet("Items")
var slotIndex = 0

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
	if not $TextureRect/TextureRect_Icon.visible:
		return
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
	emit_signal("onSellClicked", slotIndex)

func _on_TextureButton_Throw_button_down():
	$AnimationPlayer.play("ButtonClicked_Throw")

func _on_TextureButton_Throw_button_up():
	$AnimationPlayer.play_backwards("ButtonClicked_Throw")
	$CloseInteractTimer.start()
	emit_signal("onThrowClicked", slotIndex)

func _on_CloseInteractTimer_timeout():
	bShowInteract = false
	
func RefreshSlot(_itemId):
	if _itemId != "":
		$TextureRect/TextureRect_Icon.show()
		$TextureRect/Label_Price.show()
		var itemImagePath = itemConfig[_itemId]["Image"]
		var texture = load(itemImagePath)
		$TextureRect/TextureRect_Icon.texture = texture
		var itemPrice = int(itemConfig[_itemId]["Price"])
		$TextureRect/Label_Price.text = "$%d" % itemPrice
	else:
		$TextureRect/TextureRect_Icon.hide()
		$TextureRect/Label_Price.hide()
	
func SetSlotState(_slotState):
	match _slotState:
		SlotState.Normal:
			$Interact/HBoxContainer/TextureButton_Sell.show()
			$Interact/HBoxContainer/TextureButton_Throw.show()
			$Interact/TextureRect_Interact.texture = interactBGTexture1
		SlotState.SellOnly:
			$Interact/HBoxContainer/TextureButton_Sell.show()
			$Interact/HBoxContainer/TextureButton_Throw.hide()
			$Interact/TextureRect_Interact.texture = interactBGTexture2
		SlotState.ThrowOnly:
			$Interact/HBoxContainer/TextureButton_Sell.hide()
			$Interact/HBoxContainer/TextureButton_Throw.show()
			$Interact/TextureRect_Interact.texture = interactBGTexture2
