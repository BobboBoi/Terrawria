extends Item

@export var tileId := 1

##Set item values
func _init():
	useTime = 0.5
	useAnimation = "none"
	texture = "Items/Item_20.png"
	itemId = 20
	
	recipes = {
		"Furnace": {
			"1": {
				12: 3,
				"Amount": 1
			}
		}
	}
	
	tagList["Tile"] = null
	tagList["CopperBar"] = null
	tagList["Bar"] = null

func Used(player : Player):
	var world : World = player.world
	var mousePos := world.local_to_map(world.to_local(world.get_global_mouse_position()))
	var targetTile = world.get_cell_source_id(0,mousePos)
	
	if targetTile == tileId: return
	
	return #Add the bar tile script before placing
	#world.Place(mousePos,tileId,0)
	#
	#var currentItem = player.currentItem
	#currentItem.stack -= 1
	#if currentItem.stack <= 0:
		#player.currentItem.queue_free()
