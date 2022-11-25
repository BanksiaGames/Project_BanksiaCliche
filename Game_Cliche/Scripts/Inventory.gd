extends Node

class_name Inventory

signal OnInventoryChanged

var itemList = []
var itemConfig = GDSheets.sheet("Items")

func AddItem(_itemId, _itemNum):
	print("Inventory Add Item %s" % _itemId)
	if itemList.size() < 10 :
		itemList.append(ItemInfo.new(_itemId, _itemNum))
		emit_signal("OnInventoryChanged")
		return true
	return false

func RemoveItemWithId(_itemId):
	var itemIndex = GetItemIndex(_itemId)
	if itemIndex != -1:
		return RemoveItem(itemIndex)
	return false
	
func RemoveItem(_itemIndex):
	if itemList.size() > _itemIndex:
		itemList.remove(_itemIndex)
		emit_signal("OnInventoryChanged")
		return true
	return false

func ReplaceItem(_itemIndex, _itemId):
	if itemList.size() > _itemIndex:
		itemList[_itemIndex] = ItemInfo.new(_itemId, 1)
		emit_signal("OnInventoryChanged")
		return true
	return false

func ResetInventory():
	itemList.clear()
	emit_signal("OnInventoryChanged")

func GetItem(_itemIndex):
	if itemList.size() > _itemIndex:
		return itemList[_itemIndex]
	return ItemInfo.new("", 0)

func PrintItems():
	var itemIdString : String = ""
	for item in itemList:
		itemIdString += item.itemId + " "
	
	print("Inventory Items : %s" % itemIdString)

func GetItemCount():
	return itemList.size()

func GetItemCountOfType(_itemType):
	var itemCount = 0
	for item in itemList:
		var itemType = itemConfig[item.itemId]["Type"]
		if itemType == _itemType :
			itemCount += 1
	return itemCount

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

class ItemInfo:
	var itemId
	var itemNum
	
	func _init(_itemId, _itemNum):
		itemId = _itemId
		itemNum = _itemNum
