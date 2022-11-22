extends Node

class_name NPCBase, "res://icon.png"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var bodyTexture : Texture

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _get_event_message():
	pass

func _get_choices():
	pass

func _get_show_message():
	pass

func _get_positive_message():
	pass

func _get_negative_message():
	pass
	
func _event_triggered(_player):
	pass
	
func _process_positive_choice(_player):
	pass

func _process_negative_choice(_player):
	pass

func _reset_event():
	pass

func _npc_show():
	pass
