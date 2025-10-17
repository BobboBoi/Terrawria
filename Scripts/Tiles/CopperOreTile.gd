extends Tile

var item = "res://Scripts/Items/CopperOreItem.gd"

func _init():
	tileId = 7
	hitpoints = 100
	tagList["Ore"] = null

func Destroyed(player : Player,pos : Vector2i) -> void:
	var world = player.world
	
	var newItem = load(item)
	world.DropItem(newItem.new(),pos)
	Erase(world,pos)
