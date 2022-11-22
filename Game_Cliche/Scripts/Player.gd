extends Node

class_name Player

signal OnDebtChanged
signal OnDayLeftChanged

var debtInfo = DebtInfo.new(10, 1000)
var itemConfig = GDSheets.sheet("Items")

func Reborn(_dayLeft, _amountLeft):
	debtInfo = DebtInfo.new(_dayLeft, _amountLeft)
	$Inventory.ResetInventory()

func MoveNextDay():
	debtInfo.dayLeft -= 1
	emit_signal("OnDayLeftChanged")

func BackToPast(_day):
	debtInfo.dayLeft += _day
	emit_signal("OnDayLeftChanged")
	
func GetDayLeft():
	return debtInfo.dayLeft
	
func SellItem(_itemIndex):
	if $Inventory.GetItemCount() == 0:
		return
	var item = $Inventory.PickItem(_itemIndex)
	var itemPrice = int(itemConfig[item.itemId]["Price"])
	RepayDebt(itemPrice)

func SellAllItem():
	while $Inventory.GetItemCount() > 0 :
		var item = $Inventory.PickItem(0)
		var itemPrice = int(itemConfig[item.itemId]["Price"])
		RepayDebt(itemPrice)
	
func RepayDebt(_amount):
	debtInfo.amountLeft -= _amount
	$SFX_PayDebt.play()
	emit_signal("OnDebtChanged")

func GetDebetAmountLeft():
	return debtInfo.amountLeft

class DebtInfo:
	var dayLeft
	var amountLeft
	
	func _init(_dayLeft, _amountLeft):
		dayLeft = _dayLeft
		amountLeft = _amountLeft
