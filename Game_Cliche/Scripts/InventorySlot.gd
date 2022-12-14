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
var itemId = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer_Content.play("ContentReset")	

var bShowInteract = false

func _process(delta):
	if $Interact.visible != bShowInteract:
		if bShowInteract:
			ShowInteract()
		else:
			HideInteract()
					
	if itemId != "":
		if $TextureRect/TextureRect_Icon.self_modulate.a == 0 || $TextureRect/Label_Price.modulate.a == 0:
			$AnimationPlayer_Content.play("ContentPopup")
	else:
		if $TextureRect/TextureRect_Icon.self_modulate.a == 1 || $TextureRect/Label_Price.modulate.a == 1:
			$AnimationPlayer_Content.play("ContentShrinkDown")

func ShowInteract():
	if itemId == "":
		return
	$TextureRect.texture = hoverTexture
	$Interact.show()
	$AnimationPlayer.play("InventorySlotHovered")
	$SlotSelected.play()
	$TextureRect/TextureRect_Icon.show()
	$TextureRect/Label_Price.show()

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
	bShowInteract = false
	HideInteract()
	$SellInteractTimer.start()
	$InteractClicked.play()

func _on_TextureButton_Throw_button_down():
	$AnimationPlayer.play("ButtonClicked_Throw")

func _on_TextureButton_Throw_button_up():
	$AnimationPlayer.play_backwards("ButtonClicked_Throw")
	bShowInteract = false
	HideInteract()
	$ThrowInteractTimer.start()
	$InteractClicked.play()	
	
func RefreshSlot(_itemId):
	if itemId != _itemId :
		if _itemId != "":
			$TextureRect/TextureRect_Icon.show()
			$TextureRect/Label_Price.show()
			var itemImagePath = itemConfig[_itemId]["Image"]
			var texture = load(itemImagePath)
			$TextureRect/TextureRect_Icon.texture = texture
			var itemPrice = int(itemConfig[_itemId]["Price"])
			$TextureRect/Label_Price.text = "$%d" % itemPrice
			#$AnimationPlayer_Content.play("ContentPopup")
		else:
			pass
			#$AnimationPlayer_Content.play("ContentShrinkDown")
		itemId = _itemId
	
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
			

func _on_AnimationPlayer_Content_animation_started(anim_name):
	pass
#	if anim_name == "ContentPopup" :
#		$TextureRect/TextureRect_Icon.show()
#		$TextureRect/Label_Price.show()

func _on_AnimationPlayer_Content_animation_finished(anim_name):
	if anim_name == "ContentShrinkDown" :
		#$TextureRect/TextureRect_Icon.hide()
		#$TextureRect/Label_Price.hide()
		bShowInteract = false

func _on_SellInteractTimer_timeout():
	#$AnimationPlayer_Content.play("ContentShrinkDown")	
	emit_signal("onSellClicked", slotIndex)	

func _on_ThrowInteractTimer_timeout():
	#$AnimationPlayer_Content.play("ContentShrinkDown")		
	emit_signal("onThrowClicked", slotIndex)	
