extends Tile

var item = "res://Scripts/Items/DirtItem.gd"

func _init():
	tileId = 2
	tagList["Grass"] = null
	tagList["ValidCave"] = null
	tagList["StoneReplacable"] = null

func Destroyed(player : Player,pos : Vector2i) -> void:
	var world = player.world
	
	var newItem = load(item)
	world.DropItem(newItem.new(),pos)
	Erase(world,pos)
