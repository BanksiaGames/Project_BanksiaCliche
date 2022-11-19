extends Node

var itemConfig = GDSheets.sheet("Items")
var currentChoiceList = []

enum ChoicResult { Nothing, ReturnItem, GiveChoice, Bingo }
var choiceResultDic = {
	ChoicResult.Nothing    : 10,
	ChoicResult.ReturnItem : 30,
	ChoicResult.GiveChoice : 20,
	ChoicResult.Bingo      : 40
}

enum GamePhase { Prologue, PickItem, SelectChoice, GameOver }
var curGamePhase = GamePhase.Prologue

var curNPC : NPCBase
var maxDayLeft = 30
var maxDebtAmountLeft = 10000

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$GameOver/ButtonNewGame.connect("button_up", self, "_on_button_newgame_clicked")
	StartNewGame()

func _on_button_newgame_clicked():
	$MainHUD.show()
	$GameOver.hide()
	StartNewGame()

func StartNewGame():
	$Player.Reborn(maxDayLeft, maxDebtAmountLeft)
	$Cat._reset_event()
	StartNewRound()

func StartNewRound():
	$MainHUD.HideAllCharacterAndChoices()	
	$MainHUD.UpdateDayLeft($Player.GetDayLeft(), maxDayLeft)
	
	if $Player.GetDayLeft() == 0:
		$Player.SellAllItem()
	
	$MainHUD.RefreshInventorySlots($Player/Inventory.GetItems())	
	$MainHUD.UpdateDebtAmount($Player.GetDebetAmountLeft())	
	
	if JudgeGameOver():
		SetGamePhase(GamePhase.GameOver)		
		$GameOverTimer.start()
		return
	
	if TriggerNPCEvent():
		return
	
	SetGamePhase(GamePhase.PickItem)
	if $Player/Inventory.GetItemCount() == 1:
		$MainHUD.RefreshInventorySlotsState(InventorySlot.SlotState.ThrowOnly)
	else:
		$MainHUD.RefreshInventorySlotsState(InventorySlot.SlotState.Normal)

func CreateRandomChoices(_firstChoice):
	SetGamePhase(GamePhase.SelectChoice)
	var choiceList = []
	
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
	
	choiceList.append(_firstChoice)
	
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
			for i in range(3):
				# Play Bubble i explode
				var bubble : HermesBubble = $MainHUD.GetHermesBubble(i + 1)
				bubble.PlayExplode()
		ChoicResult.ReturnItem:
			print("ReturnItem")
			$Player/Inventory.AddItem(currentChoiceList[2], 1)
			# Play Bubble 3 Move to Inventory
			for i in range(3):
				# Play Bubble i explode
				var bubble : HermesBubble = $MainHUD.GetHermesBubble(i + 1)
				if i != 2:
					bubble.PlayExplode()
				else:
					bubble.PlayGain()
					
		ChoicResult.GiveChoice:
			print("GiveChoice")
			$Player/Inventory.AddItem(currentChoiceList[choiceIndex], 1)
			# Play Bubble choiceIndex Move to Inventory
			for i in range(3):
				# Play Bubble i explode
				var bubble : HermesBubble = $MainHUD.GetHermesBubble(i + 1)
				if i != choiceIndex:
					bubble.PlayExplode()
				else:
					bubble.PlayGain()
					
		ChoicResult.Bingo:
			print("Bingo!!!")
			var bubbleIndex = 1
			for choice in currentChoiceList:
				if $Player/Inventory.AddItem(choice, 1) :
					var bubble : HermesBubble = $MainHUD.GetHermesBubble(bubbleIndex)
					bubble.PlayGain()
				else:
					# Play Bubble bubbleIndex fall into Lake
					var bubble : HermesBubble = $MainHUD.GetHermesBubble(bubbleIndex)
					bubble.PlayFall()
				bubbleIndex += 1

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
		$GameOver/Label_GameOver.text = "No More Item Left !!!"
	elif debtLeft <= 0:
		bGameOver = true
		$GameOver/Label_GameOver.text = "You are free man now !!!"		
	elif dayLeft <= 0:
		bGameOver = true
		$GameOver/Label_GameOver.text = "Time to work in underground !!!"				
		
	return bGameOver

func TriggerNPCEvent():
	if $Cat._event_triggered($Player):
		ProcessNPCEvent($Cat)
		return true
	return false

func ProcessNPCEvent(_npc):
	curNPC = _npc
	var npcChoices = _npc._get_choices()
	$MainHUD.ShowNPCEvent(npcChoices, curNPC.bodyTexture)

func _on_ButtonNewGame_button_up():
	StartNewGame()

func _on_MainHUD_onInventorySlotSellClicked(_itemIndex):
	if $Player/Inventory.GetItemCount() == 1 and GetGamePhase() == GamePhase.PickItem:
		print("No More Item Left !!")
		return
	$Player.SellItem(_itemIndex)
	$MainHUD.RefreshInventorySlots($Player/Inventory.GetItems())
	
	if curGamePhase == GamePhase.PickItem:
		if $Player/Inventory.GetItemCount() == 1:
			$MainHUD.RefreshInventorySlotsState(InventorySlot.SlotState.ThrowOnly)
		else:
			$MainHUD.RefreshInventorySlotsState(InventorySlot.SlotState.Normal)
	
	$MainHUD.UpdateDebtAmount($Player.GetDebetAmountLeft())
	if JudgeGameOver():
		SetGamePhase(GamePhase.GameOver)
		$MainHUD.hide()
		$GameOver.show()

func _on_MainHUD_onInventorySlotThrowClicked(_itemIndex):
	if $Player/Inventory.GetItemCount() == 0:
		print("Nothing Can Throw !!")
		return
	var itemInfo = $Player/Inventory.PickItem(_itemIndex)

	currentChoiceList = CreateRandomChoices(itemInfo.itemId)
	
	yield(get_tree().create_timer(0.2), "timeout")
	
	$MainHUD.RefreshInventorySlots($Player/Inventory.GetItems())
	$MainHUD.RefreshInventorySlotsState(InventorySlot.SlotState.SellOnly)
	$MainHUD.PlayDropItem(itemInfo.itemId)
	
	yield(get_tree().create_timer(1), "timeout")
	
	$MainHUD.ShowHermesEvent(currentChoiceList)

func _on_MainHUD_onHermesBubbleClicked(_bubbleIndex):
	var result = JudgeChoice()
	
	$MainHUD.PlayCharacterTalkingBubble("Blalalalalala")
	
	yield(get_tree().create_timer(0.75), "timeout")	
	
	ProcessChoiceResult(_bubbleIndex, result)
	
	yield(get_tree().create_timer(1), "timeout")	
	
	$Player.MoveNextDay()	
	StartNewRound()

func _on_MainHUD_onNpcChoiceSelected(_bPositive):
	if _bPositive:
		curNPC._process_positive_choice($Player)
	else:
		curNPC._process_negative_choice($Player)
	StartNewRound()


func _on_GameOverTimer_timeout():
	$MainHUD.hide()
	$GameOver.show()
