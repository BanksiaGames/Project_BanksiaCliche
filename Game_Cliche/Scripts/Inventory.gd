extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var itemList = []

# Called when the node enters the scene tree for the first time.
func _ready():
	itemList.resize(10)
	AddItem(1001, 1)
	AddItem(1002, 1)
	AddItem(1003, 1)
	AddItem(1004, 1)
	AddItem(1005, 1)

func AddItem(_itemId, _itemNum):
	itemList.append(ItemInfo.new(_itemId, _itemNum))

func RemoveItem(_itemInfo):
	var itemIndex = itemList.find(_itemInfo)
	itemList.remove(itemIndex)

func PickItem(_index):
	return itemList.pop_at(_index)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

class ItemInfo:
	var itemId
	var itemNum
	
	func _init(_itemId, _itemNum):
		itemId = _itemId
		itemNum = _itemNum
