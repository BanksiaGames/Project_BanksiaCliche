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

func ShowNPCEvent(_npChoices, _npcBodyTexture, _npcMessage):
	$MainCharacter.texture = _npcBodyTexture
	$MainCharacter.show()
	$NPCChoice.show()
	$MainCharacter/NinePatchRect.rect_scale = Vector2.ZERO		
	$AnimationPlayer_MainCharacter.play("CharacterPopup")
	PlayCharacterTalkingBubble(_npcMessage)
	$NPCChoice/Button_Positive.SetText(_npChoices[0])
	$NPCChoice/Button_Negative.SetText(_npChoices[1])
	
func HideAllCharacterAndChoices():
	$MainCharacter.hide()
	$HermesChoice.hide()
	$NPCChoice.hide()
	
func UpdateDebtAmount(_amount):
	$DebtAmount/Label.text = "-$%d" % _amount
	$DebtAmount/AnimationPlayer.play("AmountChange")
	
func UpdateDayLeft(_dayLeft, _maxDay):
	$DayLeft/Label.text = str(_dayLeft)
	$DayLeft/TextureProgress.value = float(_dayLeft) / float(_maxDay) * 100
	$DayLeft/AnimationPlayer.play("DayChange")
	
func ShowHermesEvent(_choiceItemList):
	yield(get_tree().create_timer(1.25), "timeout")
	$MainCharacter.texture = hermesBodyTexture	
	$MainCharacter.show()
	$HermesChoice.show()
	$MainCharacter/NinePatchRect.rect_scale = Vector2.ZERO
	$AnimationPlayer_MainCharacter.play("CharacterPopup")
	PlayCharacterTalkingBubble("What did you fall into the lake ?")
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
	#$MainCharacter.scale = Vector2.ZERO
	$MainCharacter/NinePatchRect.rect_scale = Vector2.ZERO
	
func GetHermesBubble(_bubbleIndex):
	var choiceName = "HermesChoice/HermesBubble%d" % _bubbleIndex
	var choiceBubble : HermesBubble = .get_node(choiceName)
	return choiceBubble

func PlayCharacterTalkingBubble(_talkingContent):
	$MainCharacter/NinePatchRect/Label.StartTyping(_talkingContent, 0.03)
	$AnimationPlayer_Talking.play("CharacterTalk")

func MoveNewDay(_dayLeft, _dayEvent):
	#$Panel_Day/SFX_Typing.play(1.5)
	$Panel_Day/AnimationPlayer_Typing.play("PlayTypingSFX")
	var dayLeftText = "%d Days" % _dayLeft
	if _dayLeft == 1:
		dayLeftText = "The Last Day"
	var typingTime = $Panel_Day/Label_Day.StartTyping(dayLeftText, 0.1)
	yield(get_tree().create_timer(typingTime), "timeout")	
	typingTime = $Panel_Day/Label_Event.StartTyping(_dayEvent, 0.075)
	yield(get_tree().create_timer(typingTime), "timeout")		
	$AnimationPlayer_Day.play("NewDay")
	yield(get_tree().create_timer(0.5), "timeout")				


func PlayDayEnd():
	$AnimationPlayer_HUD.play_backwards("FadeIn")		
	yield(get_tree().create_timer(0.5), "timeout")			
	$Panel_Day/Label_Day.text = ""
	$Panel_Day/Label_Event.text = ""
	$AnimationPlayer_Day.play("DayEnd")

func ResetHUD():
	$Panel_Day/Label_Day.text = ""
	$Panel_Day/Label_Event.text = ""
	$AnimationPlayer_HUD.play("Reset")

func PlayFadeIn():
	$AnimationPlayer_HUD.play("FadeIn")
