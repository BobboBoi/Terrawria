extends Item

##Set item values
func _init():
	useTime = 0.5
	useAnimation = "none"
	texture = "Items/Item_93.png"
	itemId = 93
	
	recipes = {
		"Workbench": {
			"1": {
				9: 1,
				"Amount": 4
			}
		}
	}
	
	tagList["Wall"] = null
	tagList["WoodenWall"] = null
