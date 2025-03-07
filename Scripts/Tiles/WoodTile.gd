extends Tile

var item = "res://Scripts/Items/WoodItem.gd"

func _init():
	tileId = 30
	tagList["Wood"] = null

func Destroyed(player : Player,pos : Vector2i) -> void:
	var world = player.world
	
	var newItem = load(item)
	world.DropItem(newItem.new(),pos)
	Erase(world,pos)
