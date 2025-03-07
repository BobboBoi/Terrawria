extends Item

##Set item values
func _init():
	useTime = 0.5
	useAnimation = "none"
	texture = "Items/Item_1.png"
	itemId = 1
	
	recipes = {
		"Hand": {
			"1": { #recipe 1
				2: 24, # tileId : amount
				"Amount": 2  # amount
			}
		}
	}
	
	tagList["Tool"] = null
	tagList["Pickaxe"] = null

func Used(player : Player):
	var world : World = player.world
	var mousePos := world.local_to_map(world.to_local(world.get_global_mouse_position()))
	
	if !world.HasTileTag(0,mousePos,"Mineable"): return
	world.Erase(mousePos,0,player)
