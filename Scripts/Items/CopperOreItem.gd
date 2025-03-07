extends Item

@export var tileId := 7

##Set item values
func _init():
	useTime = 0.5
	useAnimation = "none"
	texture = "Items/Item_12.png"
	itemId = 12
	
	tagList["Tile"] = null
	tagList["CopperOre"] = null

func Used(player : Player):
	var world : World = player.world
	var mousePos := world.local_to_map(world.to_local(world.get_global_mouse_position()))
	var targetTile = world.get_cell_source_id(0,mousePos)
	
	if targetTile == tileId: return
	
	world.Place(mousePos,tileId,0)
	
	var currentItem = player.currentItem
	currentItem.stack -= 1
	if currentItem.stack <= 0:
		player.currentItem.queue_free()
