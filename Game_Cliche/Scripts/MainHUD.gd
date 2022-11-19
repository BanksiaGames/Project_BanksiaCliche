extends CanvasLayer

export var hermesBodyTexture : Texture

signal onInventorySlotSellClicked(_itemIndex)
signal onInventorySlotThrowClicked(_itemIndex)
signal onHermesBubbleClicked(_bubbleIndex)
signal onNpcChoiceSelected(_bPositive)

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(10):
		var slotName = "HBoxContainer/InventorySlot%d" % (i + 1)
		var itemSlot : InventorySlot = .get_node(slotName)
		itemSlot.slotIndex = i
		itemSlot.connect("onSellClicked", self, "_on_sell_clicked")
		itemSlot.connect("onThrowClicked", self, "_on_throw_clicked")
	for i in range(3):
		var bubbleIndex = i + 1
		var bubbleName = "HermesChoice/HermesBubble%d" % bubbleIndex
		var bubble : HermesBubble = .get_node(bubbleName)
		bubble.connect("onBubbleClicked", self, "_on_bubble_clicked")
	$NPCChoice/Button_Positive.connect("button_up", self, "_on_select_positive_choice")
	$NPCChoice/Button_Negative.connect("button_up", self, "_on_select_negative_choice")
		
func _on_select_positive_choice():
	emit_signal("onNpcChoiceSelected", true)
	
func _on_select_negative_choice():
	emit_signal("onNpcChoiceSelected", false)

func _on_bubble_clicked(_bubbleIndex):
	print("_on_bubble_clicked %d" % _bubbleIndex)
	emit_signal("onHermesBubbleClicked", _bubbleIndex)

func _on_sell_clicked(_slotIndex):
	print("_on_sell_clicked %d" % _slotIndex)
	emit_signal("onInventorySlotSellClicked", _slotIndex)
	
func _on_throw_clicked(_slotIndex):
	print("_on_throw_clicked %d" % _slotIndex)
	emit_signal("onInventorySlotThrowClicked", _slotIndex)	

func RefreshInventorySlots(itemList):
	var slotIndex : int = 1
	for i in range(10):
		var slotName = "HBoxContainer/InventorySlot%d" % slotIndex
		var itemSlot = .get_node(slotName)
		if slotIndex <= itemList.size():
			itemSlot.RefreshSlot(itemList[slotIndex - 1].itemId)
		else:
			itemSlot.RefreshSlot("")
		slotIndex += 1
		
func RefreshInventorySlotsState(_slotState):
	var slotIndex : int = 1
	for i in range(10):
		var slotName = "HBoxContainer/InventorySlot%d" % slotIndex
		var itemSlot : InventorySlot = .get_node(slotName)
		itemSlot.SetSlotState(_slotState)
		slotIndex += 1
	pass

func ShowNPCEvent(_npChoices, _npcBodyTexture):
	$MainCharacter.texture = _npcBodyTexture
	$MainCharacter.show()
	$NPCChoice.show()
	$NPCChoice/Button_Positive/Label.text = _npChoices[0]
	$NPCChoice/Button_Negative/Label.text = _npChoices[1]
	
func HideAllCharacterAndChoices():
	$MainCharacter.hide()
	$HermesChoice.hide()
	$NPCChoice.hide()
	
func UpdateDebtAmount(_amount):
	$DebtAmount/Label.text = "-$%d" % _amount
	
func UpdateDayLeft(_dayLeft, _maxDay):
	$DayLeft/Label.text = str(_dayLeft)
	$DayLeft/TextureProgress.value = float(_dayLeft) / float(_maxDay) * 100
	
func ShowHermesEvent(_choiceItemList):
	$MainCharacter.texture = hermesBodyTexture	
	$MainCharacter.show()
	$HermesChoice.show()
	$AnimationPlayer_MainCharacter.play("CharacterPopup")
	for i in range(3):
		var choiceName = "HermesChoice/HermesBubble%d" % (i + 1)
		var choiceBubble : HermesBubble = .get_node(choiceName)
		choiceBubble.RefreshBubble(_choiceItemList[i], i)
	
func _on_HermesChoice_hide():
	$HermesChoice/HermesBubble1/Body.scale = Vector2.ZERO
	$HermesChoice/HermesBubble2/Body.scale = Vector2.ZERO
	$HermesChoice/HermesBubble3/Body.scale = Vector2.ZERO
	
func PlayDropItem(_itemId):
	var itemConfig = GDSheets.sheet("Items")
	var itemImagePath = itemConfig[_itemId]["Image"]
	var texture = load(itemImagePath)
	$DropItem.texture = texture
	$AnimationPlayer_DropItem.play("Anim_DropItem")

func _on_MainCharacter_hide():
	$MainCharacter.scale = Vector2.ZERO
	$MainCharacter/NinePatchRect.rect_scale = Vector2.ZERO
	
func GetHermesBubble(_bubbleIndex):
	var choiceName = "HermesChoice/HermesBubble%d" % _bubbleIndex
	var choiceBubble : HermesBubble = .get_node(choiceName)
	return choiceBubble

func PlayCharacterTalkingBubble(_talkingContent):
	$MainCharacter/NinePatchRect/Label.text = _talkingContent
	$AnimationPlayer_MainCharacter.play("CharacterTalk")
