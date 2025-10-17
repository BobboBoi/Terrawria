extends Pickaxe

##Set item values
func _init():
	super()
	useTime = 20
	power = 40
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
