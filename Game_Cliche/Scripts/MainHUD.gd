extends CanvasLayer


signal onInventorySlotSellClicked(_itemIndex)
signal onInventorySlotThrowClicked(_itemIndex)


# Called when the node enters the scene tree for the first time.
func _ready():
	var slotIndex : int = 1	
	for i in range(10):
		var slotName = "HBoxContainer/InventorySlot%d" % slotIndex
		var itemSlot : InventorySlot = .get_node(slotName)
		itemSlot.slotIndex = slotIndex
		itemSlot.connect("onSellClicked", self, "_on_sell_clicked")
		itemSlot.connect("onThrowClicked", self, "_on_throw_clicked")
		slotIndex += 1		

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

func ShowNPCEvent():
	$MainCharacter.show()
	$NPCChoice.show()
	
func HideAllCharacterAndChoices():
	$MainCharacter.hide()
	$HermesChoice.hide()
	$NPCChoice.hide()
	
func UpdateDebtAmount(_amount):
	$DebtAmount/Label.text = "-$%d" % _amount
	
func UpdateDayLeft(_dayLeft, _maxDay):
	$DayLeft/Label.text = str(_dayLeft)
	$DayLeft/TextureProgress.value = float(_dayLeft) / float(_maxDay) * 100
	
func ShowHermesEvent():
	$MainCharacter.show()
	$HermesChoice.show()
