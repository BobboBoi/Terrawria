extends Item

@export var tileId := 17

const SHAPE := [Vector2i(0,1),Vector2i(1,1),Vector2i(2,1),Vector2i(0,0),Vector2i(1,0),Vector2i(2,0)]
const OFFSET := [Vector2i(0,0),Vector2i(1,0),Vector2i(2,0),Vector2i(0,-1),Vector2i(1,-1),Vector2i(2,-1)]

##Set item values
func _init():
	useTime = 0.5
	useAnimation = "none"
	texture = "Items/Item_33.png"
	itemId = 33
	
	recipes = {
		"Hand": {
			"1": {
				3: 15,
				"Amount": 1
			}
		}
	}
	
	tagList["Furniture"] = null
	tagList["Furnace"] = null

func Used(player : Player):
	var world : World = player.world
	var mousePos := world.local_to_map(world.to_local(world.get_global_mouse_position()))
	
	for x in range(3):
		var targetTile = world.get_cell_source_id(0,mousePos + Vector2i(x,1))
		if targetTile == -1: return #TODO add check for plants tag
		
	
	for x in range(3):
		for y in range(2):
			var targetTile = world.get_cell_source_id(0,mousePos + Vector2i(x,-y))
			if targetTile != -1: 
				print("Blocked")
				return
	
	var numb := 0
	for o in OFFSET:
		world.Place(mousePos + o,tileId,0,SHAPE[numb],false)
		numb += 1
	
	for o in OFFSET:
		world._TileUpdate(mousePos + o,0,true)
	
	var currentItem = player.currentItem
	currentItem.stack -= 1
	if currentItem.stack <= 0:
		player.currentItem.queue_free()
