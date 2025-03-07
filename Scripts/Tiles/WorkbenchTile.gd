extends Tile

var type := TYPES.OAK
var item := "res://Scripts/Items/OakWorkbenchItem.gd"

enum TYPES {
	OAK
}

func _init():
	tileId = 18
	tagList["Workbench"] = null
	tagList["Furniture"] = null
	tagList["Table"] = null
	tagList["Floored"] = null

func Destroyed(player : Player,pos : Vector2i) -> void:
	var world = player.world
	
	var newItem = load(item)
	world.DropItem(newItem.new(),pos)
	Erase(world,pos)

func Updated(world,pos) -> void:
	if world.get_cell_atlas_coords(0,pos) == Vector2i(0+type*2,0):
		var isTile = world.get_cell_source_id(0,pos+Vector2i.RIGHT) == tileId
		if !isTile or (isTile and world.get_cell_atlas_coords(0,pos+Vector2i.RIGHT) != Vector2i(1+type*2,0)):
			world.erase_cell(0,pos)
	elif world.get_cell_atlas_coords(0,pos) == Vector2i(1+type*2,0):
		var isTile = world.get_cell_source_id(0,pos+Vector2i.LEFT) == tileId
		if !isTile or (isTile and world.get_cell_atlas_coords(0,pos+Vector2i.LEFT) != Vector2i(0+type*2,0)):
			world.erase_cell(0,pos)
