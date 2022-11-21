extends Node

export var sfx_nothing : AudioStream
export var sfx_returnItem : AudioStream
export var sfx_giveChoice : AudioStream
export var sfx_bingo : AudioStream

var itemConfig = GDSheets.sheet("Items")
var currentChoiceList = []

enum ChoicResult { Nothing, ReturnItem, GiveChoice, Bingo }
var choiceResultDic = {
	ChoicResult.Nothing    : 5,
	ChoicResult.ReturnItem : 15,
	ChoicResult.GiveChoice : 15,
	ChoicResult.Bingo      : 20
}

enum GamePhase { Prologue, PickItem, SelectChoice, GameOver }
var curGamePhase = GamePhase.Prologue

var curNPC : NPCBase
var maxDayLeft = 30
var maxDebtAmountLeft = 1000000
var maxDayChance = 3
var curDayChance = 3
var curDayPass = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$GameOver/ButtonNewGame.connect("button_up", self, "_on_button_newgame_clicked")
	$StartGameTimer.start()
	
func _on_button_newgame_clicked():
	$GameOver.hide()
	$StartGameTimer.start()

func StartNewGame():
	curDayChance = maxDayChance
	$Player.Reborn(maxDayLeft, maxDebtAmountLeft)
	$Cat._reset_event()
	$MainHUD.show()
	$MainHUD.ResetHUD()
	$MainHUD.MoveNewDay(maxDayLeft, "My Last Month .....")
	$MainHUD.UpdateDayLeft($Player.GetDayLeft(), maxDayLeft)
	$MainHUD.RefreshInventorySlots($Player/Inventory.GetItems())
	$MainHUD.UpdateDebtAmount($Player.GetDebetAmountLeft())	
	SetGamePhase(GamePhase.Prologue)
	currentChoiceList = ["1026", "1025", "1024"]
	yield(get_tree().create_timer(4), "timeout")
	$Music.play()	
	$MainHUD.PlayDropItem("1024")
	$MainHUD.ShowHermesEvent(currentChoiceList)	

func StartNewDay():
	curDayPass += 1
	curDayChance = maxDayChance
	$Player.MoveNextDay()	
	$MainHUD.UpdateDayLeft($Player.GetDayLeft(), maxDayLeft)
	
	if $Player.GetDayLeft() == 0:
		$Player.SellAllItem()
	
	if JudgeGameOver():
		SetGamePhase(GamePhase.GameOver)		
		return
	
	var dayEvent = "Nothing Happened ......"
	if TriggerNPCEvent():
		SetGamePhase(GamePhase.SelectChoice)
		dayEvent = curNPC._get_event_message()
	else:
		SetGamePhase(GamePhase.PickItem)
	
	$MainHUD.MoveNewDay($Player.GetDayLeft(), dayEvent)
	yield(get_tree().create_timer(1), "timeout")
	$MainHUD.PlayFadeIn()
	yield(get_tree().create_timer(3), "timeout")
	if curNPC != null:
		ProcessNPCEvent(curNPC)

func CreateRandomChoices(_firstChoice):
	var choiceList = []
	
	var itemPool = []
	var itemTotalWeight : int = 0
	
	var firstChoiceType = itemConfig[_firstChoice]["Type"]
	
	# Create Random Pool
	for itemId in itemConfig.keys():
		var itemWeight = int(itemConfig[itemId]["Weight"])
		var itemWeightModifier = int(itemConfig[itemId]["WeightModifier"])
		var itemType = itemConfig[itemId]["Type"]
		if itemType == firstChoiceType:
			itemWeight = itemWeight + itemWeightModifier
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

func JudgePrologueChoice(_index):
	var choiceResult = ChoicResult.GiveChoice
	if _index == 2 :
		choiceResult = ChoicResult.Bingo
	return choiceResult

func ProcessChoiceResult(choiceIndex, result):
	match result:
		ChoicResult.Nothing:
			print("Do Nothing")
			for i in range(3):
				# Play Bubble i explode
				var bubble : HermesBubble = $MainHUD.GetHermesBubble(i + 1)
				bubble.SetBubbleVolume(-5)
				bubble.PlayExplode()
		ChoicResult.ReturnItem:
			print("ReturnItem")
			$Player/Inventory.AddItem(currentChoiceList[2], 1)
			# Play Bubble 3 Move to Inventory
			for i in range(3):
				# Play Bubble i explode
				var bubble : HermesBubble = $MainHUD.GetHermesBubble(i + 1)
				if i != 2:
					bubble.SetBubbleVolume(-5)
					bubble.PlayExplode()
				else:
					bubble.SetBubbleVolume(0)					
					bubble.PlayGain()
					
		ChoicResult.GiveChoice:
			print("GiveChoice")
			$Player/Inventory.AddItem(currentChoiceList[choiceIndex], 1)
			# Play Bubble choiceIndex Move to Inventory
			for i in range(3):
				# Play Bubble i explode
				var bubble : HermesBubble = $MainHUD.GetHermesBubble(i + 1)
				if i != choiceIndex:
					bubble.SetBubbleVolume(-5)
					bubble.PlayExplode()
				else:
					bubble.SetBubbleVolume(0)
					bubble.PlayGain()
					
		ChoicResult.Bingo:
			print("Bingo!!!")
			var bubbleIndex = 1
			var bubbleGainVolume = 0
			var bubbleFallVolume = 0
			var emptySlotCount = 10 - $Player/Inventory.GetItemCount()
			if emptySlotCount >= 3:
				bubbleGainVolume = -10
			elif emptySlotCount == 2:
				bubbleGainVolume = -5
				bubbleFallVolume = 0
			else:
				bubbleGainVolume = 0
				bubbleFallVolume = -5
				
			for choice in currentChoiceList:
				if $Player/Inventory.AddItem(choice, 1) :
					var bubble : HermesBubble = $MainHUD.GetHermesBubble(bubbleIndex)
					bubble.SetBubbleVolume(bubbleGainVolume)					
					bubble.PlayGain()
				else:
					# Play Bubble bubbleIndex fall into Lake
					var bubble : HermesBubble = $MainHUD.GetHermesBubble(bubbleIndex)
					bubble.SetBubbleVolume(bubbleFallVolume)
					bubble.PlayFall()
				bubbleIndex += 1

func SetGamePhase(_phase):
	curGamePhase = _phase
	match curGamePhase:
		GamePhase.GameOver:
			$Music.stop()
			$MainHUD.PlayDayEnd()
			$GameOverTimer.start()
		GamePhase.PickItem:
			if $Player/Inventory.GetItemCount() == 1:
				$MainHUD.RefreshInventorySlotsState(InventorySlot.SlotState.ThrowOnly)
			else:
				$MainHUD.RefreshInventorySlotsState(InventorySlot.SlotState.Normal)
		GamePhase.SelectChoice:
			$MainHUD.RefreshInventorySlotsState(InventorySlot.SlotState.SellOnly)
			

func GetGamePhase():
	return curGamePhase
	
func JudgeGameOver():
	var dayLeft = $Player.GetDayLeft()
	var debtLeft = $Player.GetDebetAmountLeft()
	var itemLeft = $Player/Inventory.GetItemCount()
	var bGameOver = false
	
	if debtLeft <= 0 :
		bGameOver = true
		$GameOver/Label_GameOver.text = "You are free man now !!!"
	elif dayLeft <= 0 :
		bGameOver = true
		$GameOver/Label_GameOver.text = "Time to work in underground !!!"
	elif itemLeft == 0 :
		bGameOver = true
		$GameOver/Label_GameOver.text = "No More Item Left !!!"
	
	return bGameOver

func TriggerNPCEvent():
	curNPC = null
	if $Cat._event_triggered($Player):
		curNPC = $Cat
		return true
	return false

func ProcessNPCEvent(_npc : NPCBase):
	var npcChoices = _npc._get_choices()
	_npc._npc_show()
	$MainHUD.ShowNPCEvent(npcChoices, curNPC.bodyTexture)

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

func _on_MainHUD_onInventorySlotThrowClicked(_itemIndex):
	SetGamePhase(GamePhase.SelectChoice)
	
	if $Player/Inventory.GetItemCount() == 0:
		print("Nothing Can Throw !!")
		return
		
	var itemInfo = $Player/Inventory.PickItem(_itemIndex)
	currentChoiceList = CreateRandomChoices(itemInfo.itemId)
	
	yield(get_tree().create_timer(0.2), "timeout")
	
	$MainHUD.RefreshInventorySlots($Player/Inventory.GetItems())
	$MainHUD.PlayDropItem(itemInfo.itemId)
	$MainHUD.ShowHermesEvent(currentChoiceList)

func PlayJingles(_stream):
	$SFX_Jingles.stream = _stream
	$SFX_Jingles.play()

func _on_MainHUD_onHermesBubbleClicked(_bubbleIndex):
	var result = JudgeChoice()
	if GetGamePhase() == GamePhase.Prologue:
		result = JudgePrologueChoice(_bubbleIndex)
			
	match result:
		ChoicResult.Nothing:
			PlayJingles(sfx_nothing)
			$MainHUD.PlayCharacterTalkingBubble("Barefaced liar!!")
		ChoicResult.GiveChoice:
			PlayJingles(sfx_giveChoice)
			$MainHUD.PlayCharacterTalkingBubble("Anything goes")
		ChoicResult.ReturnItem:
			PlayJingles(sfx_returnItem)
			$MainHUD.PlayCharacterTalkingBubble("A little bird told me")
		ChoicResult.Bingo:
			PlayJingles(sfx_bingo)
			$MainHUD.PlayCharacterTalkingBubble("Honesty is the best policy")
	
	yield(get_tree().create_timer(0.75), "timeout")	
	
	ProcessChoiceResult(_bubbleIndex, result)
	
	yield(get_tree().create_timer(1), "timeout")	
	
	if GetGamePhase() == GamePhase.Prologue:
		$MainHUD.PlayFadeIn()
	
	if JudgeGameOver():
		SetGamePhase(GamePhase.GameOver)		
		return
	
	$MainHUD.RefreshInventorySlots($Player/Inventory.GetItems())	
	$MainHUD/AnimationPlayer_MainCharacter.play("CharacterHide")
	
	yield(get_tree().create_timer(0.25), "timeout")		
	
	curDayChance -= 1
	if curDayChance > 0:
		SetGamePhase(GamePhase.PickItem)
	else:
		$MainHUD.PlayDayEnd()
		yield(get_tree().create_timer(0.5), "timeout")
		StartNewDay()

func _on_MainHUD_onNpcChoiceSelected(_bPositive):
	if _bPositive:
		curNPC._process_positive_choice($Player)
		$MainHUD.PlayCharacterTalkingBubble("????????")
	else:
		curNPC._process_negative_choice($Player)
		$MainHUD.PlayCharacterTalkingBubble("%%%%%%%%")		
	
	$MainHUD/NPCChoice.hide()
	
	yield(get_tree().create_timer(1), "timeout")		
	
	$MainHUD.RefreshInventorySlots($Player/Inventory.GetItems())	
	$MainHUD/AnimationPlayer_MainCharacter.play("CharacterHide")
	
	curDayChance -= 1
	if curDayChance > 0:
		SetGamePhase(GamePhase.PickItem)
	else:
		$MainHUD.PlayDayEnd()
		yield(get_tree().create_timer(0.5), "timeout")
		StartNewDay()

func _on_GameOverTimer_timeout():
	$MainHUD.hide()
	$GameOver.show()

func _on_StartGameTimer_timeout():
	StartNewGame()
