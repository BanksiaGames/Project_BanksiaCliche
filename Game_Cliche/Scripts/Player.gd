extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var debtInfo = DebtInfo.new(10, 1000)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func MoveNextDay():
	debtInfo.dayLeft -= 1
	
func GetDayLeft():
	return debtInfo.dayLeft

class DebtInfo:
	var dayLeft
	var amountLeft
	
	func _init(_dayLeft, _amountLeft):
		dayLeft = _dayLeft
		amountLeft = _amountLeft
