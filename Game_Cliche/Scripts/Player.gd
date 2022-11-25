extends Node

class_name Player

signal OnPlayerReborn
signal OnDebtChanged
signal OnDayLeftChanged

var debtInfo = DebtInfo.new(10, 1000)
var itemConfig = GDSheets.sheet("Items")

func Reborn(_dayLeft, _amountLeft):
	debtInfo = DebtInfo.new(_dayLeft, _amountLeft)
	$Inventory.ResetInventory()	
	emit_signal("OnPlayerReborn")

func MoveNextDay():
	SetDayLeft(debtInfo.dayLeft - 1)

func BackToPast(_day):
	SetDayLeft(debtInfo.dayLeft + _day)

func SetDayLeft(_day):
	if debtInfo.dayLeft != _day :
		debtInfo.dayLeft = _day
		emit_signal("OnDayLeftChanged")	
	
func GetDayLeft():
	return debtInfo.dayLeft
	
func SellItem(_itemIndex):
	if $Inventory.GetItemCount() == 0:
		return
	var item = $Inventory.GetItem(_itemIndex)
	if item.itemId != "":
		var itemPrice = int(itemConfig[item.itemId]["Price"])
		RepayDebt(itemPrice)
		$Inventory.RemoveItem(_itemIndex)

func SellAllItem():
	var totalPrice = 0
	for item in $Inventory.itemList:
		var itemPrice = itemConfig[item.itemId]["Price"]
		totalPrice += itemPrice
	RepayDebt(totalPrice)
	$Inventory.ResetInventory()
	
func RepayDebt(_amount):
	debtInfo.amountLeft -= _amount
	$SFX_PayDebt.play()
	emit_signal("OnDebtChanged")

func GetDebetAmountLeft():
	return debtInfo.amountLeft
	
func GetInventory() -> Inventory:
	return $Inventory as Inventory

class DebtInfo:
	var dayLeft
	var amountLeft
	
	func _init(_dayLeft, _amountLeft):
		dayLeft = _dayLeft
		amountLeft = _amountLeft
