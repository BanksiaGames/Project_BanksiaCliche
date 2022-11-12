extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var itemConfigs = GDSheets.sheet("Items")
	
	for itemConfig in itemConfigs.values():
		print(itemConfig["Name"])
	
	StartNewRound()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_ButtonGive_button_up():
	# Replace with function body
	var itemInfo = $Player/Inventory.PickItem(0)
	$MainHUD/ButtonChoice1.show()
	$MainHUD/ButtonChoice2.show()
	$MainHUD/ButtonChoice3.show()
	$MainHUD/ButtonGive.hide()	

func _on_ButtonChoice1_button_up():
	$Player/Inventory.AddItem(10011, 1)
	StartNewRound()

func _on_ButtonChoice2_button_up():
	$Player/Inventory.AddItem(10012, 1)
	StartNewRound()
	
func _on_ButtonChoice3_button_up():
	$Player/Inventory.AddItem(10013, 1)
	StartNewRound()
	
func StartNewRound():
	HideAllChoices()	
	$Player.MoveNextDay()
	$MainHUD/Label_DayLeft.text = "Day Left : %d" % $Player.GetDayLeft()
	
func HideAllChoices():
	$MainHUD/ButtonChoice1.hide()
	$MainHUD/ButtonChoice2.hide()
	$MainHUD/ButtonChoice3.hide()
	$MainHUD/ButtonGive.show()


