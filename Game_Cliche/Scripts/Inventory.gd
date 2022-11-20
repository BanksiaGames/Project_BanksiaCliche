extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var itemList = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func AddItem(_itemId, _itemNum):
	print("Inventory Add Item %s" % _itemId)
	if itemList.size() < 10 :
		itemList.append(ItemInfo.new(_itemId, _itemNum))
		return true
	return false

func RemoveItem(_itemId):
	var removeItemIndex = GetItemIndex(_itemId)
	if removeItemIndex != -1:
		itemList.remove(removeItemIndex)

func ResetInventory():
	itemList.clear()

func PickItem(_index):
	return itemList.pop_at(_index)

func PrintItems():
	var itemIdString : String = ""
	for item in itemList:
		itemIdString += item.itemId + " "
	
	print("Inventory Items : %s" % itemIdString)

func GetItemCount():
	return itemList.size()

func GetItemIndex(_itemId):
	var itemIndex = -1
	var curIndex = 0
	for item in itemList:
		if item.itemId == _itemId : 
			itemIndex = curIndex
			break
		curIndex += 1
	return itemIndex

func HasItem(_itemId):
	var bHas = false
	for item in itemList:
		if item.itemId == _itemId:
			bHas = true
	return bHas

func GetItems():
	return itemList

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

class ItemInfo:
	var itemId
	var itemNum
	
	func _init(_itemId, _itemNum):
		itemId = _itemId
		itemNum = _itemNum
