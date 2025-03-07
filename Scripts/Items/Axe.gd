extends Item

##Set item values
func _init():
	useTime = 0.5
	useAnimation = "none"
	texture = "Items/Item_10.png"
	itemId = 10
	
	recipes = {
		"Hand": {
			"1": { #recipe 1
				9: 12, # tileId : amount
				"Amount": 1  # amount
			}
		}
	}
	
	tagList["Tool"] = null
	tagList["Axe"] = null

func Used(player : Player):
	var world : World = player.world
	var mousePos := world.local_to_map(world.to_local(world.get_global_mouse_position()))
	
	if !world.HasTileTag(0,mousePos,"Tree"): return
	world.Erase(mousePos,0,player)
