extends NPCBase

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _get_event_message():
	return "The cat's meow, meow, meow, meow~"

func _get_choices():
	return ["Give a fish can", "Ignore"]

var targetItemId = "1022"
var bonusItemId = "1006"
var probability = 30
var bProcessed = false

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

func _process_positive_choice(_player):
	print("Cat Give You a bonus")
	bProcessed = true
	_player.get_node("Inventory").RemoveItem(targetItemId)
	_player.get_node("Inventory").AddItem(bonusItemId, 1)
	pass

func _process_negative_choice(_player):
	print("Cat walk away ... ")	
	pass
	
func _reset_event():
	bProcessed = false
	pass
