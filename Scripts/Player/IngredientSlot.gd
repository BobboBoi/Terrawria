extends TextureRect

func setItem(itemId : int,stack := 1):
	$Item.itemId = itemId
	$Item.stack = stack
	$Item.texture = load("res://Sprites/Items/Item_"+str(itemId)+".png")
