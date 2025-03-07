extends Tile

#Make this an array of all wood types and make the index correspont to the tree type
var item = "res://Scripts/Items/WoodItem.gd"
##8 types total
var treeType : TREETYPE = TREETYPE.OAK
var treeMod := 8
enum TREETYPE {
	OAK,
	EBON,
	CLASSICMAHOGANY,
	PEARLWOOD,
	BOREAL,
	SHADE,
	MAHOGANY,
	MUSHROOM,
}

func _init():
	tileId = 5
	treeMod *= treeType
	tagList ={
		"Floored" = null,
		"Tree" = null,
		"Plant" = null
	}

func Destroyed(player : Player,pos : Vector2i) -> void:
	var world = player.world
	
	if world.get_cell_source_id(0,Vector2i(pos.x,pos.y-1)) == 666:
		DeleteTreeTop(Vector2i(pos.x-2,pos.y),world)
	
	var newItem = load(item)
	world.DropItem(newItem.new(),pos)
	Erase(world,pos)

func Updated(world : World, pos : Vector2i) -> void:
	var floorTile := world.HasTileTag(0,Vector2i(pos.x,pos.y+1),"Grass") or world.HasTileTag(0,Vector2i(pos.x,pos.y+1),"Tree")
	var newItem = load(item)
	
	#Check if this is a valid tile to stand on if not delete this tile
	if !floorTile: 
		if world.get_cell_source_id(0,Vector2i(pos.x,pos.y-1)) == 666:
			DeleteTreeTop(Vector2i(pos.x-2,pos.y-1),world)
		DeleteAndDrop(newItem.new(),world,pos)
		return
	
	#Check if the tile above this one is also a tree tile
	if !world.HasTileTag(0,Vector2i(pos.x,pos.y-1),"Tree"):
		var atlas = world.get_cell_atlas_coords(0,pos)
		
		#Check if this is a root and if it should be removed
		if atlas == Vector2i(1+treeMod,6) or atlas == Vector2i(1+treeMod,7) or atlas == Vector2i(1+treeMod,8):
			if !world.HasTileTag(0,Vector2i(pos.x-1,pos.y),"Tree"):
				DeleteAndDrop(newItem.new(),world,pos)
			return
		if atlas == Vector2i(2+treeMod,6) or atlas == Vector2i(2+treeMod,7) or atlas == Vector2i(2+treeMod,8):
			if !world.HasTileTag(0,Vector2i(pos.x+1,pos.y),"Tree"):
				DeleteAndDrop(newItem.new(),world,pos)
			return
		
		#Change the atlas to be chopped of
		world.set_cell(0,pos,5,Vector2i(0+treeMod,9+randi_range(0,2)))

func DeleteTreeTop(pos : Vector2i,world : World):
	for j in range(5):
		for k in range(5):
			world.erase_cell(0,pos)
			pos.x += 1
		pos.y -= 1
		pos.x -= 5

func DeleteAndDrop(itemDrop : Item,world : World,pos : Vector2i):
	world.DropItem(itemDrop,pos)
	Erase(world,pos)
