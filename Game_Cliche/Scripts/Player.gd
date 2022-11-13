extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var debtInfo = DebtInfo.new(10, 1000)
var itemConfig = GDSheets.sheet("Items")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func Reborn():
	debtInfo = DebtInfo.new(10, 1000)
	$Inventory.ResetInventory()

func MoveNextDay():
	debtInfo.dayLeft -= 1
	
func GetDayLeft():
	return debtInfo.dayLeft
	
func SellItem():
	if $Inventory.GetItemCount() == 0:
		return
	var item = $Inventory.PickItem(0)
	var itemPrice = int(itemConfig[item.itemId]["Price"])
	RepayDebt(itemPrice)
	
func RepayDebt(_amount):
	debtInfo.amountLeft -= _amount

func GetDebetAmountLeft():
	return debtInfo.amountLeft

class DebtInfo:
	var dayLeft
	var amountLeft
	
	func _init(_dayLeft, _amountLeft):
		dayLeft = _dayLeft
		amountLeft = _amountLeft
