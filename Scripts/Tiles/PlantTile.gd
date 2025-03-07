extends Tile

func _init():
	tileId = 3
	tagList["Plant"] = null

#For mushroom check the current atlas
func Destroyed(player : Player,pos : Vector2i) -> void:
	var world = player.world
	
	Erase(world,pos)

func Updated(world : World, pos : Vector2i) -> void:
	var floorTile := world.HasTileTag(0,Vector2i(pos.x,pos.y+1),"Grass")
	if !floorTile: world.erase_cell(0,pos)
