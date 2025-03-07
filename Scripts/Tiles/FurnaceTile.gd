extends Tile

var item := "res://Scripts/Items/FurnaceItem.gd"

const SHAPE := [[Vector2(0,0),Vector2(1,0),Vector2(2,0)],[Vector2(0,1),Vector2(1,1),Vector2(2,1)]]

func _init():
	tileId = 17
	tagList["Furnace"] = null
	tagList["Furniture"] = null
	tagList["Table"] = null
	tagList["Floored"] = null

func Destroyed(player : Player, pos : Vector2i) -> void:
	var world = player.world
	
	var newItem = load(item)
	world.DropItem(newItem.new(),pos)
	Erase(world,pos)

func Updated(world : World, pos : Vector2i) -> void:
	return
	var atlas := world.get_cell_atlas_coords(0,pos)
	var indexX := -1
	var indexY := 0
	
	if world.get_cell_source_id(0,pos + Vector2i.DOWN) == -1:
			world.erase_cell(0,pos)
			print("floating")
			return
	
	for i in SHAPE:
		if i.find(atlas) != 0:
			indexX = i.find(atlas)
		indexY += 1
	
	if indexX == -1:
		world.erase_cell(0,pos)
		return
	
	var neighbour := Vector2i.ZERO
	if indexX > 0:
		neighbour = SHAPE[indexY][indexX-1]
		if world.get_cell_atlas_coords(0,pos + neighbour) != neighbour:
			world.erase_cell(0,pos)
			return
	
	if indexX < SHAPE[indexY].size():
		neighbour = SHAPE[indexY][indexX+1]
		if world.get_cell_atlas_coords(0,pos + neighbour) != neighbour:
			world.erase_cell(0,pos)
			return
	
	neighbour = SHAPE[wrapi(indexY+1,0,SHAPE.size()-1)][indexX]
	if world.get_cell_atlas_coords(0,pos + neighbour) != neighbour:
		world.erase_cell(0,pos)
		return
