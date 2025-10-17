extends Item
class_name Pickaxe

## Detemines the amount of hits a block takes to break, aswell as the maximum strength of blocks it can break.
var power := 35

##Set item values
func _init():
	tagList["Tool"] = null
	tagList["Pickaxe"] = null

func Used(player : Player):
	var world : World = player.world
	var mousePos := world.local_to_map(world.to_local(world.get_global_mouse_position()))
	
	if !world.HasTileTag(0,mousePos,"Mineable"): return
	world.Mine(mousePos, 0, player, self)
