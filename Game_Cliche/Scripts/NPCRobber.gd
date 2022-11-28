extends NPCBase

export var sfx_show : AudioStream
export var sfx_positive : AudioStream
export var sfx_negative : AudioStream

var triggerItemCount = 2
var bonusDay = 3
var probability = 30
var itemConfig = GDSheets.sheet("Items")

signal OnRobberNegativeChoice

func _get_event_message():
	return "He's gunning for a fight"

func _get_choices():
	return ["Give him something good", "Ignore"]
	
func _get_show_message():
	return "Hey! You!"

func _get_positive_message():
	return "Nice~~"

func _get_negative_message():
	return "Uh!!!!"

func _event_triggered(_player : Player):
	var bTriggered = false
	var luxuryItemCount = _player.get_node("Inventory").GetItemCountOfType("luxury")
	if luxuryItemCount >= triggerItemCount:
		var randWeight = randi() % 100
		if randWeight <= probability:
			bTriggered = true
	return bTriggered

func _process_positive_choice(_player : Player):
	print("Item Lost")
	var luxuryItemList = []
	var itemList = _player.GetInventory().GetItems()
	for itemInfo in itemList:
		var itemType = itemConfig[itemInfo.itemId]["Type"]
		if itemType == "luxury":
			luxuryItemList.append(itemInfo.itemId)
	
	if luxuryItemList.size() > 0:
		# Randomly Remove 
		luxuryItemList.shuffle()
		_player.GetInventory().RemoveItemWithId(luxuryItemList.pop_front())
	PlaySound(sfx_positive)

func _process_negative_choice(_player):
	print("Day End ... ")
	emit_signal("OnRobberNegativeChoice")
	PlaySound(sfx_negative)
	
func _reset_event():
	pass

func _npc_show():
	PlaySound(sfx_show)
	pass
	
func PlaySound(_audioStream):
	$SFX.stream = _audioStream
	$SFX.play()

func _keep_event(_player : Player) -> bool:
	var luxuryItemCount = _player.get_node("Inventory").GetItemCountOfType("luxury")
	return luxuryItemCount >= triggerItemCount
