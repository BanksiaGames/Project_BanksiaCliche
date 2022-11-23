extends NPCBase

export var sfx_show : AudioStream
export var sfx_positive : AudioStream
export var sfx_negative : AudioStream

var triggerItemCount = 2
var bonusDay = 3
var probability = 100

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
	#PlaySound(sfx_positive)

func _process_negative_choice(_player):
	print("Day End ... ")
	#PlaySound(sfx_negative)
	
func _reset_event():
	pass

func _npc_show():
	#PlaySound(sfx_show)
	pass
	
func PlaySound(_audioStream):
	$SFX.stream = _audioStream
	$SFX.play()
