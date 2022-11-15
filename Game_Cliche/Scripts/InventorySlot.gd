extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var normalTexture : Texture
export var hoverTexture : Texture

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_InventorySlot_mouse_entered():
	$TextureRect.texture = hoverTexture
	$TextureRect2.show()
	


func _on_InventorySlot_mouse_exited():
	$TextureRect.texture = normalTexture
	$TextureRect2.hide()	
