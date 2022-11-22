extends NPCBase

export var sfx_show : AudioStream
export var sfx_positive : AudioStream
export var sfx_negative : AudioStream

var targetItemId = "1027" #Diamond Ring
var bonusAmount = 250000
var probability = 100
var bProcessed = false

func _get_event_message():
	return "A woman is walking toward me"

func _get_choices():
	return ["Give her the Diamond Ring", "Ignore"]
	
func _get_show_message():
	return "Have you found my diamond ring ?"

func _get_positive_message():
	return "Thanks, please let me pay your debt"

func _get_negative_message():
	return "Hmmmm, please tell me if your found that"

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
	print("Woman Pay Your Debt")
	bProcessed = true
	_player.get_node("Inventory").RemoveItem(targetItemId)
	_player.RepayDebt(bonusAmount)
	
	pass

func _process_negative_choice(_player):
	print("Woman walk away ... ")	
	pass
	
func _reset_event():
	bProcessed = false
	pass
