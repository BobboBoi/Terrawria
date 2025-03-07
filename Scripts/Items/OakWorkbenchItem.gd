extends Item

@export var tileId := 18

##Set item values
func _init():
	useTime = 0.5
	useAnimation = "none"
	texture = "Items/Item_36.png"
	itemId = 36
	
	recipes = {
		"Hand": {
			"1": {
				9: 10,
				"Amount": 1
			}
		}
	}
	
	tagList["Furniture"] = null
	tagList["Oak"] = null

func Used(player : Player):
	var world : World = player.world
	var mousePos := world.local_to_map(world.to_local(world.get_global_mouse_position()))
	
	var targetTile = world.get_cell_source_id(0,mousePos)
	if targetTile != -1: return #add check for plants tag
	targetTile = world.get_cell_source_id(0,mousePos + Vector2i.RIGHT)
	if targetTile != -1: return #add check for plants tag
	
	targetTile = world.get_cell_source_id(0,mousePos + Vector2i.DOWN)
	if targetTile == -1: return
	targetTile = world.get_cell_source_id(0,mousePos + Vector2i.RIGHT + Vector2i.DOWN)
	if targetTile == -1: return
	
	
	targetTile = world.get_cell_source_id(0,mousePos)
	
	world.Place(mousePos,tileId,0,Vector2i(0,0),false)
	world.Place(mousePos + Vector2i.RIGHT,tileId,0,Vector2i(1,0),false)
	
	world._TileUpdate(mousePos,0,true)
	world._TileUpdate(mousePos + Vector2i.RIGHT,0,true)
	
	var currentItem = player.currentItem
	currentItem.stack -= 1
	if currentItem.stack <= 0:
		player.currentItem.queue_free()
