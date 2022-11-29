extends Node

export (Array, AudioStream) var sfx_choiceResults;
export (Array, AudioStream) var sfx_gameOvers
export (Array, AudioStream) var bgms

var itemConfig = GDSheets.sheet("Items")
var currentChoiceList = []
var giftStoryItem = []

enum ChoicResult { Nothing, GiveChoice, GiveOther, Bingo }
var choiceResultDic = {
	ChoicResult.Nothing    : 10,
	ChoicResult.GiveChoice : 40,
	ChoicResult.GiveOther  : 40,
	ChoicResult.Bingo      : 60
}
var hermesEmotion = 0
var honestEmotionStep = 1
var dishonestEmotionStep = 2
var maxHermesEmotion = 20
var minHermesEmotion = -20
var defaultBingoWeight = 60
var defaultGiveOtherWeight = 40
var defaultNothingWeight = 10

enum GamePhase { Prologue, PickItem, SelectChoice, JudgeChoice, GameOver }
var curGamePhase = GamePhase.Prologue

var curNPC : NPCBase
var maxDayLeft = 30
var maxDebtAmountLeft = 1000000
var maxDayChance = 3
var curDayChance = 3
var curDayPass = 0

enum GameEnding { Free, Work, NoItem }
var curGameEnding = GameEnding.Free

func _ready():
	randomize()
	#$GameOver/ButtonNewGame.connect("button_up", self, "_on_button_newgame_clicked")
	$Player.GetInventory().connect("OnInventoryChanged", self, "_on_player_inventory_changed")
	#$StartGameTimer.start()
	$SplashScreen.PlayFadeOut()

func _on_StoryMenu_OnStoryEnd():
	$MainHUD.show()
	$StoryMenu.hide()
	$StartGameTimer.start()

func _on_StartMenu_OnGameStart():
	$StoryMenu.show()
	$StartMenu.hide()
	$StoryMenu.StartPrologue()
	$Tween.interpolate_property(
		$Music, "volume_db", 
		-10, -50, 1, 
		Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$Tween.start()

func StartNewGame():
	SetGamePhase(GamePhase.Prologue)	
	curDayChance = maxDayChance
	hermesEmotion = 0
	currentChoiceList.clear()
	giftStoryItem.clear()
	$Player.Reborn(maxDayLeft, maxDebtAmountLeft)
	ResetNPCEvent()
	$MainHUD.show()
	$MainHUD.ResetHUD()
	$MainHUD.MoveNewDay(maxDayLeft, "My Last Month .....")
	currentChoiceList = ["1026", "1025", "1024"]
	yield(get_tree().create_timer(4), "timeout")
	$Music.stream = bgms[1]
	$Music.play()
	$Tween.interpolate_property(
		$Music, "volume_db", 
		-50, -10, 1, 
		Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$Tween.start()
	$MainHUD.PlayDropItem("1024")
	$MainHUD.ShowHermesEvent(currentChoiceList)	

func ResetNPCEvent():
	$Cat._reset_event()
	$Woman._reset_event()
	$Elf._reset_event()
	$Robber._reset_event()

func StartNewDay():
	curDayPass += 1
	curDayChance = maxDayChance
	$Player.MoveNextDay()
	
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
	yield(get_tree().create_timer(2.75), "timeout")
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
			
		if itemType == "unique" && $Player/Inventory.HasItem(itemId) :
			itemWeight = 0
		
		if itemType == "luxury" && firstChoiceType == "trash":
			itemWeight = itemWeight + itemWeightModifier
		
		if itemId != _firstChoice and !giftStoryItem.has(itemId):
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

func UpdateHermesEmotion(_honest):
	if _honest:
		hermesEmotion += honestEmotionStep
	else:
		hermesEmotion -= dishonestEmotionStep
	hermesEmotion = clamp(hermesEmotion, minHermesEmotion, maxHermesEmotion)
	choiceResultDic[ChoicResult.GiveOther] = defaultGiveOtherWeight - hermesEmotion
	choiceResultDic[ChoicResult.Bingo] = defaultBingoWeight + hermesEmotion * 1.25
	choiceResultDic[ChoicResult.Nothing] = defaultNothingWeight - hermesEmotion * 0.5
	var printText = ""
	for choiceResult in choiceResultDic:
		printText += "%s : %d" % [choiceResult, choiceResultDic[choiceResult]]
		if (choiceResult != choiceResultDic.keys().back()):
			printText += "\n"
	print(printText)
	$MainHUD.SetHermesEmotion(hermesEmotion)

func JudgeChoice():
	var totalWeight : int = 0
	for result in choiceResultDic:
		totalWeight += choiceResultDic[result]
	
	print("JudgeChoice TotalWeight %d" % totalWeight)
	
	var randWeight = randi() % totalWeight
	print("JudgeChoice randWeight %d" % randWeight)
	
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

func IsStoryItem(_itemId):
	var itemType = itemConfig[_itemId]["Type"]
	return itemType == "story"

func ProcessChoiceResult(choiceIndex, result):
	match result:
		ChoicResult.Nothing:
			print("Do Nothing")
			for i in range(3):
				# Play Bubble i explode
				var bubble : HermesBubble = $MainHUD.GetHermesBubble(i + 1)
				bubble.SetBubbleVolume(-5)
				bubble.PlayExplode()
		ChoicResult.GiveOther:
			print("GiveOther")
			var choiceArray = []
			for i in range(3):
				if i != choiceIndex:
					choiceArray.append(i)
			choiceArray.shuffle()
			var giveOtherIndex = choiceArray[0]
			var choiceItemId = currentChoiceList[giveOtherIndex]
			$Player/Inventory.AddItem(choiceItemId, 1)
			if(IsStoryItem(choiceItemId)):
				giftStoryItem.append(choiceItemId)
			# Play Bubble 3 Move to Inventory
			for i in range(3):
				# Play Bubble i explode
				var bubble : HermesBubble = $MainHUD.GetHermesBubble(i + 1)
				if i != giveOtherIndex:
					bubble.SetBubbleVolume(-5)
					bubble.PlayExplode()
				else:
					bubble.SetBubbleVolume(0)
					bubble.PlayGain()
					
		ChoicResult.GiveChoice:
			print("GiveChoice")
			$Player/Inventory.AddItem(currentChoiceList[choiceIndex], 1)
			if(IsStoryItem(currentChoiceList[choiceIndex])):
				giftStoryItem.append(currentChoiceList[choiceIndex])
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
					if(IsStoryItem(choice)):
						giftStoryItem.append(choice)
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
	if curGamePhase == _phase:
		return false
	curGamePhase = _phase
	match curGamePhase:
		GamePhase.GameOver:
			$Music.stop()
			$GameOverTimer.start()
		GamePhase.PickItem:
			curNPC = null
			currentChoiceList.empty()
			if $Player/Inventory.GetItemCount() == 1:
				$MainHUD.RefreshInventorySlotsState(InventorySlot.SlotState.ThrowOnly)
			else:
				$MainHUD.RefreshInventorySlotsState(InventorySlot.SlotState.Normal)
		GamePhase.SelectChoice:
			$MainHUD.RefreshInventorySlotsState(InventorySlot.SlotState.SellOnly)
	return true

func GetGamePhase():
	return curGamePhase
	
func JudgeGameOver():	
	var dayLeft = $Player.GetDayLeft()
	var debtLeft = $Player.GetDebetAmountLeft()
	var itemLeft = $Player/Inventory.GetItemCount()
	var bGameOver = false
	
	if debtLeft <= 0 :
		bGameOver = true
		curGameEnding = GameEnding.Free
		#$MainHUD/AnimationPlayer_HUD.play_backwards("FadeIn")
		#$GameOver/Label_GameOver.text = "You are free man now !!!"
	elif dayLeft <= 0 :
		bGameOver = true
		curGameEnding = GameEnding.Work
		#$MainHUD/AnimationPlayer_HUD.play_backwards("FadeIn")		
		#$GameOver/Label_GameOver.text = "Time to work in underground !!!"
	elif itemLeft == 0 :
		bGameOver = true
		curGameEnding = GameEnding.NoItem
		$MainHUD/AnimationPlayer_HUD.play_backwards("FadeIn")				
		#$GameOver/Label_GameOver.text = "No More Item Left !!!"
	
	return bGameOver

func TriggerNPCEvent():
	curNPC = null
	
	if $Cat._event_triggered($Player):
		curNPC = $Cat
		return true
	
	if $Woman._event_triggered($Player):
		curNPC = $Woman
		return true
		
	if $Elf._event_triggered($Player):
		curNPC = $Elf
		return true
		
	if $Robber._event_triggered($Player):
		curNPC = $Robber
		return true
	
	return false

func ProcessNPCEvent(_npc : NPCBase):
	var npcChoices = _npc._get_choices()
	_npc._npc_show()
	$MainHUD.ShowNPCEvent(npcChoices, curNPC.bodyTexture, curNPC._get_show_message())

func PlayJingles(_stream):
	$SFX_Jingles.stream = _stream
	$SFX_Jingles.play()

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
	
func _on_MainHUD_onInventorySlotThrowClicked(_itemIndex):
	if not SetGamePhase(GamePhase.SelectChoice):
		return
	
	if $Player/Inventory.GetItemCount() == 0:
		print("Nothing Can Throw !!")
		return
		
	var itemInfo = $Player/Inventory.GetItem(_itemIndex)
	if itemInfo.itemId != "":
		currentChoiceList = CreateRandomChoices(itemInfo.itemId)
		$Player.GetInventory().RemoveItem(_itemIndex)
	
	yield(get_tree().create_timer(0.2), "timeout")
	
	$MainHUD.RefreshInventorySlots($Player/Inventory.GetItems())
	$MainHUD.PlayDropItem(itemInfo.itemId)
	$MainHUD.ShowHermesEvent(currentChoiceList)

func _on_MainHUD_onHermesBubbleClicked(_bubbleIndex):
	if currentChoiceList.size() == 0:
		return
		
	var result = JudgeChoice()
	
	var bProcessPrologue = GetGamePhase() == GamePhase.Prologue
	
	if bProcessPrologue:
		result = JudgePrologueChoice(_bubbleIndex)
	
	var processPhase = SetGamePhase(GamePhase.JudgeChoice)
	if processPhase == false :
		return
	
	UpdateHermesEmotion(_bubbleIndex == 2)
			
	match result:
		ChoicResult.Nothing:
			if _bubbleIndex == 2:
				PlayJingles(sfx_choiceResults[4])
				$MainHUD.PlayCharacterTalkingBubble("No legacy is so rich as honesty")
			else:
				PlayJingles(sfx_choiceResults[0])
				$MainHUD.PlayCharacterTalkingBubble("Barefaced liar!!")
		ChoicResult.GiveChoice:
			PlayJingles(sfx_choiceResults[1])
			$MainHUD.PlayCharacterTalkingBubble("Anything goes")
		ChoicResult.GiveOther:
			PlayJingles(sfx_choiceResults[2])
			$MainHUD.PlayCharacterTalkingBubble("A little bird told me")
		ChoicResult.Bingo:
			if _bubbleIndex == 2:			
				PlayJingles(sfx_choiceResults[3])
				$MainHUD.PlayCharacterTalkingBubble("Honesty is the best policy")
			else:
				PlayJingles(sfx_choiceResults[4])
				$MainHUD.PlayCharacterTalkingBubble("Even if it is not true, ... ...")
	
	yield(get_tree().create_timer(1.25), "timeout")	
	
	ProcessChoiceResult(_bubbleIndex, result)
	
	yield(get_tree().create_timer(1), "timeout")	
	
	if bProcessPrologue:
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
	if GetGamePhase() != GamePhase.SelectChoice:
		return
		
	if not SetGamePhase(GamePhase.JudgeChoice):
		return
		
	if _bPositive:
		curNPC._process_positive_choice($Player)
		$MainHUD.PlayCharacterTalkingBubble(curNPC._get_positive_message())
	else:
		curNPC._process_negative_choice($Player)
		$MainHUD.PlayCharacterTalkingBubble(curNPC._get_negative_message())		
	
	$MainHUD/NPCChoice.hide()
	
	yield(get_tree().create_timer(2), "timeout")		
	
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
	#$MainHUD.PlayDayEnd()
	#return
	#yield(get_tree().create_timer(1), "timeout")
	$MainHUD.hide()
	$GameOver.show()
	match curGameEnding:
		GameEnding.Free:
			$GameOver.ShowGameOver("You are freeman now ...")
			$SFX_Jingles.stream = sfx_gameOvers[0]
		GameEnding.Work:
			$GameOver.ShowGameOver("Work Work ...")
			$SFX_Jingles.stream = sfx_gameOvers[1]			
		GameEnding.NoItem:
			$GameOver.ShowGameOver("Welcome to my river, haha ...")
			$SFX_Jingles.stream = sfx_gameOvers[2]			
	$SFX_Jingles.play()

func _on_StartGameTimer_timeout():
	StartNewGame()

func _on_Player_OnDebtChanged():
	$MainHUD.UpdateDebtAmount($Player.GetDebetAmountLeft())	
	yield(get_tree().create_timer(0.5), "timeout")
	if JudgeGameOver():
		SetGamePhase(GamePhase.GameOver)
		return

func _on_Player_OnDayLeftChanged():
	if $Player.GetDayLeft() <= 10 and $Music.stream != bgms[2]:
		$Tween.interpolate_property(
		$Music, "volume_db", 
		-10, -50, 2, 
		Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$Tween.start()
		yield(get_tree().create_timer(2.5), "timeout")
		$Music.stream = bgms[2]
		$Music.play()
		$Tween.interpolate_property(
		$Music, "volume_db", 
		-50, -10, 1, 
		Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$Tween.start()
	#$MainHUD.UpdateDayLeft($Player.GetDayLeft(), maxDayLeft)

func _on_Player_OnPlayerReborn():
	#$MainHUD.UpdateDayLeft($Player.GetDayLeft(), maxDayLeft)
	$MainHUD.UpdateDebtAmount($Player.GetDebetAmountLeft())	

func _on_player_inventory_changed():
	if GetGamePhase() == GamePhase.SelectChoice and curNPC != null :
		if curNPC._keep_event($Player) == false:
			_on_MainHUD_onNpcChoiceSelected(false)
	
	yield(get_tree().create_timer(1), "timeout")	
	
	$MainHUD.RefreshInventorySlots($Player/Inventory.GetItems())
	
func _on_Robber_OnRobberNegativeChoice():
	curDayChance = 0
	$Player.BackToPast(-3)

func _on_GameOver_OnGameOverEnd():
	$GameOver.hide()
	$StartMenu.show()
	$StartMenu.ShowMenu(true)
	$Music.stream = bgms[0]
	$Music.play()

func _on_SplashScreen_OnSplashShow():
	$StartMenu.show()

func _on_SplashScreen_OnSplashHide():
	$StartMenu.ShowMenu(false)
	$Music.stream = bgms[0]
	$Music.play()
