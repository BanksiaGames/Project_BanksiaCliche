extends NPCBase

export var sfx_show : AudioStream
export var sfx_positive : AudioStream
export var sfx_negative : AudioStream

var targetItemId = "1022" # Fish Can
var bonusItemId = "1027"  # Diamond Ring
var probability = 30
var bProcessed = false

func _get_event_message():
	return "The cat's meow, meow, meow, meow ~~~~"

func _get_choices():
	return ["Give a fish can", "Ignore"]

func _get_show_message():
	return "Meow Meow Meow ???????"

func _get_positive_message():
	return "> W < Meow Meow"

func _get_negative_message():
	return "O W O @#$@#$#@$#@"

func _event_triggered(_player):
	var bTriggered = false
	var bHasTargetItem = _player.get_node("Inventory").HasItem(targetItemId)
	if bHasTargetItem:
		var randWeight = randi() % 100
		if randWeight <= probability:
			bTriggered = true
	if bProcessed:
		bTriggered = false
	return bTriggered

func _process_positive_choice(_player : Player):
	print("Cat Give You a bonus")
	PlaySound(sfx_positive)		
	bProcessed = true
	var itemIndex = _player.GetInventory().GetItemIndex(targetItemId)
	_player.GetInventory().ReplaceItem(itemIndex, bonusItemId)
	pass

func _process_negative_choice(_player):
	print("Cat walk away ... ")	
	PlaySound(sfx_negative)	
	pass
	
func _reset_event():
	bProcessed = false
	pass

func _npc_show():
	PlaySound(sfx_show)
	pass

func PlaySound(_audioStream):
	$SFX.stream = _audioStream
	$SFX.play()

func _keep_event(_player : Player) -> bool:
	var bHasTargetItem = _player.get_node("Inventory").HasItem(targetItemId)	
	return bHasTargetItem
