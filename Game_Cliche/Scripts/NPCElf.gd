extends NPCBase

export var sfx_show : AudioStream
export var sfx_positive : AudioStream
export var sfx_negative : AudioStream

var targetItemId = "1021" # Clover
var bonusDay = 3
var probability = 30

func _get_event_message():
	return "........."

func _get_choices():
	return ["Give it a clover", "Ignore"]
	
func _get_show_message():
	return ".........."

func _get_positive_message():
	return "...."

func _get_negative_message():
	return ".."

func _event_triggered(_player):
	var bTriggered = false
	var bHasTargetItem = _player.get_node("Inventory").HasItem(targetItemId)
	if bHasTargetItem:
		var randWeight = randi() % 100
		if randWeight <= probability:
			bTriggered = true
	return bTriggered

func _process_positive_choice(_player : Player):
	print("Time Return")
	#PlaySound(sfx_positive)
	if _player.GetInventory().RemoveItemWithId(targetItemId):
		_player.BackToPast(bonusDay)

func _process_negative_choice(_player):
	print("Elf Disappar ... ")
	#PlaySound(sfx_negative)
	
func _reset_event():
	pass

func _npc_show():
	#PlaySound(sfx_show)
	pass
	
func PlaySound(_audioStream):
	$SFX.stream = _audioStream
	$SFX.play()
