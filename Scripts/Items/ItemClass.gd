extends Node
class_name Item

var useTime := 0.5
var useAnimation := "none"
var texture := "Items/Item_1.png"
##The unique id of this item
var itemId := 1
var stack := 0

##Tags are used for all sorts of functions.[br]
##An example is that an item with the wood tagis used for multiple wood recipes.
##Or that an item with the Axe tag can mine trees.[br]
##Add your own tags to this list to easily categorize items for custom behaviour.
##Tags can also have values attached to them for even more customizability.
@export var tagList : Dictionary = { }

@export var recipes : Dictionary = { }


func CompileRecipes() -> Dictionary:
	var value := Dictionary()
	for c in recipes.values():
		value[recipes.find_key(c)] = Dictionary()
		var currentCat = recipes.find_key(c)
		for r in c.values():
			var currentRec = "Item"+str(itemId)+"-"+recipes[currentCat].find_key(r)
			value[currentCat][currentRec] = r
			value[currentCat][currentRec]["Result"] = itemId
			value[currentCat][currentRec]["Script"] = self.get_script().get_path()
	return value

func Use(player : Player) -> void:
	Used(player)

##Called when the player uses the item
func Used(player : Player) -> void:
	pass
