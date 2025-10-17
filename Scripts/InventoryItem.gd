extends TextureRect
class_name InventoryItem

@export var type : String = "nan"
@export var itemScript : String = "Script"
#@export var tileId : int = 0
@export var itemId : int = 0
@export var stack : int = 1 : 
	set(val):
		if get_parent() is CharacterBody2D:
			$Label.visible = false
		else:
			$Label.text = str(val)
			$Label.visible = val > 1
		stack = val
@export var item : Item = null

func _ready():
	stack  = stack
