extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var itemConfig = GDSheets.sheet("Items")
var currentChoiceList = []

enum ChoicResult { Nothing, ReturnItem, GiveChoice, Bingo }
var choiceResultDic = {
	ChoicResult.Nothing    : 10,
	ChoicResult.ReturnItem : 50,
	ChoicResult.GiveChoice : 50,
	ChoicResult.Bingo      : 20
}

enum GamePhase { Prologue, PickItem, SelectChoice, GameOver }
var curGamePhase = GamePhase.Prologue

var curNPC : NPCBase
var maxDayLeft = 10
var maxDebtAmountLeft = 1000

# Called when the node enters the scene tree for the first time.
func _ready():
	StartNewGame()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func StartNewGame():
	randomize()		
	#$MainHUD/GameOver.hide()
	#$MainHUD/InGame.show()
	$Player.Reborn(maxDayLeft, maxDebtAmountLeft)
	$MainHUD.RefreshInventorySlots($Player/Inventory.GetItems())
	StartNewRound()

func _on_ButtonChoice1_button_up():
	var result = JudgeChoice()
	ProcessChoiceResult(0, result)
	StartNewRound()

func _on_ButtonChoice2_button_up():
	var result = JudgeChoice()
	ProcessChoiceResult(1, result)
	StartNewRound()
	
func _on_ButtonChoice3_button_up():
	var result = JudgeChoice()
	ProcessChoiceResult(2, result)
	StartNewRound()

func StartNewRound():
	if JudgeGameOver():
		SetGamePhase(GamePhase.GameOver)
		$MainHUD.hide()
		$GameOver.show()
		return
	
	if TriggerNPCEvent():
		$MainHUD.ShowNPCEvent()
		return
	
	SetGamePhase(GamePhase.PickItem)
	$MainHUD.HideAllCharacterAndChoices()
	if $Player/Inventory.GetItemCount() == 1:
		$MainHUD.RefreshInventorySlotsState(InventorySlot.SlotState.ThrowOnly)
	else:
		$MainHUD.RefreshInventorySlotsState(InventorySlot.SlotState.Normal)
	$MainHUD.UpdateDayLeft($Player.GetDayLeft(), maxDayLeft)
	$MainHUD.UpdateDebtAmount($Player.GetDebetAmountLeft())

func CreateRandomChoices(_firstChoice):
	SetGamePhase(GamePhase.SelectChoice)
	var choiceList = [_firstChoice]
	
	var itemPool = []
	var itemTotalWeight : int = 0
	
	# Create Random Pool
	for itemId in itemConfig.keys():
		var itemWeight = int(itemConfig[itemId]["Weight"])
		if itemId != _firstChoice:
			itemPool.append({id = itemId, weight = itemWeight})
			itemTotalWeight += itemWeight
	
	# Pick Two Items in Pool
	for i in range(2):
		var randWeight = randi() % itemTotalWeight
		var pickIndex = 0
		var curWeight = 0
		var curIndex = 0
		for item in itemPool:
			curWeight += item.weight
			if curWeight >= randWeight :
				choiceList.append(item.id)
				pickIndex = curIndex
				itemTotalWeight -= item.weight
				break
			curIndex += 1
		itemPool.remove(pickIndex)
	
	print("Get Random Choices")
	print(choiceList)
	return choiceList

func JudgeChoice():
	var totalWeight : int = 0
	for result in choiceResultDic:
		totalWeight += choiceResultDic[result]
	
	var randWeight = randi() % totalWeight
	var curWeight = 0
	var choiceResult = ""
	for result in choiceResultDic:
		curWeight += choiceResultDic[result]
		if curWeight >= randWeight:
			choiceResult = result
			break
	
	return choiceResult

func ProcessChoiceResult(choiceIndex, result):
	match result:
		ChoicResult.Nothing:
			print("Do Nothing")
		ChoicResult.ReturnItem:
			print("ReturnItem")
			$Player/Inventory.AddItem(currentChoiceList[0], 1)
		ChoicResult.GiveChoice:
			print("GiveChoice")
			$Player/Inventory.AddItem(currentChoiceList[choiceIndex], 1)
		ChoicResult.Bingo:
			print("Bingo!!!")
			for choice in currentChoiceList:
				$Player/Inventory.AddItem(choice, 1)
	$Player.MoveNextDay()

func _on_ButtonSell_button_up():
	if $Player/Inventory.GetItemCount() == 1 and GetGamePhase() == GamePhase.PickItem:
		print("No More Item Left !!")
		return
	$Player.SellItem()
	$Player/Inventory.PrintItems()
	$MainHUD/InGame/Label_DebtLeft.text = "Debt Left :  %d" % $Player.GetDebetAmountLeft()	
	
func SetGamePhase(_phase):
	curGamePhase = _phase

func GetGamePhase():
	return curGamePhase
	
func JudgeGameOver():
	var dayLeft = $Player.GetDayLeft()
	var debtLeft = $Player.GetDebetAmountLeft()
	var itemLeft = $Player/Inventory.GetItemCount()
	var bGameOver = false
	
	if itemLeft == 0:
		bGameOver = true
		$MainHUD/GameOver/Label_GameOver.text = "No More Item Left !!!"
	elif debtLeft <= 0:
		bGameOver = true
		$MainHUD/GameOver/Label_GameOver.text = "You are free man now !!!"		
	elif dayLeft <= 0:
		bGameOver = true
		$MainHUD/GameOver/Label_GameOver.text = "Time to work in underground !!!"				
		
	return bGameOver

func TriggerNPCEvent():
	if $Cat._event_triggered($Player):
		ProcessNPCEvent($Cat)
		return true
	return false

func ProcessNPCEvent(_npc):
	$MainHUD/InGame/GodChoice.hide()
	$MainHUD/InGame/NPCChoice.show()
	curNPC = _npc
	var npcChoices = _npc._get_choices()
	$MainHUD/InGame/NPCChoice/ButtonNPCChoice1.text = npcChoices[0]
	$MainHUD/InGame/NPCChoice/ButtonNPCChoice2.text = npcChoices[1]

func _on_ButtonNewGame_button_up():
	StartNewGame()

func _on_ButtonNPCChoice1_button_up():
	curNPC._process_positive_choice($Player) # Replace with function body.
	StartNewRound()

func _on_ButtonNPCChoice2_button_up():
	curNPC._process_negative_choice($Player) # Replace with function body.
	StartNewRound()


func _on_MainHUD_onInventorySlotSellClicked(_itemIndex):
	pass # Replace with function body.


func _on_MainHUD_onInventorySlotThrowClicked(_itemIndex):
	if $Player/Inventory.GetItemCount() == 0:
		print("Nothing Can Throw !!")
		return
	var itemInfo = $Player/Inventory.PickItem(_itemIndex - 1)

	currentChoiceList = CreateRandomChoices(itemInfo.itemId)
	$MainHUD.RefreshInventorySlots($Player/Inventory.GetItems())
	$MainHUD.RefreshInventorySlotsState(InventorySlot.SlotState.SellOnly)
	$MainHUD.ShowHermesEvent()
	
	#$MainHUD/InGame/GodChoice.show()
	
	#$MainHUD/InGame/GodChoice/ButtonChoice1.text = itemConfig[currentChoiceList[0]]["Name"]
	#$MainHUD/InGame/GodChoice/ButtonChoice2.text = itemConfig[currentChoiceList[1]]["Name"]
	#$MainHUD/InGame/GodChoice/ButtonChoice3.text = itemConfig[currentChoiceList[2]]["Name"]
	
	#$MainHUD/InGame/ButtonGive.hide()	
