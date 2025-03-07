extends Control

@onready var slot = preload("res://Scenes/CraftingSlot.tscn")
@onready var ingredient = preload("res://Scenes/IngredientSlot.tscn")
@onready var ingredientContainer = $InCont
@onready var recipeContainer = $Cont
@onready var player : Player = $"../../.."

var items : Dictionary = {}
var recipeList : Dictionary = { }
var tagsInRange : Dictionary = {"Hand": null}

var stationRange := Vector2(9,6)

func start():
	var dir = DirAccess.open("res://Scripts/Items/")
	var recipes = []
	
	dir.list_dir_begin() 

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif file.ends_with(".gd"):
			recipes.append(file)

	dir.list_dir_end()
	
	#Don't use godot dictionaries worst mistake of my life!
	for i in recipes:
		var recipe = load("res://Scripts/Items/"+i).new()
		items[recipe.itemId] = i
		recipe = recipe.CompileRecipes()
		for c in recipe.values():
			#End me
			var categoryName = recipe.find_key(c)
			if !recipeList.has(categoryName): recipeList[categoryName] = Dictionary()
			for r in c.values():
				#print("recipeList[",categoryName,"][",recipe[categoryName].find_key(r),"] = ",r)
				recipeList[categoryName][recipe[categoryName].find_key(r)] = r

func checkStations() -> void:
	var newTags := {"Hand": null}
	var change := false
	var world := player.world
	var offset := -stationRange / 2 * Vector2(world.tile_set.tile_size)
	
	for x in range(stationRange.x):
		for y in range(stationRange.y):
			var tagDict := player.world.GetTileTags(0,world.local_to_map(world.to_local(player.global_position + offset)))
			for k in tagDict.keys():
				if k != "Script":
					if !newTags.has(k):
						newTags[k] = tagDict.get(k)
					if !change:
						change = !tagsInRange.has(k)
			offset.y += world.tile_set.tile_size.y
		offset.x += world.tile_set.tile_size.x
		offset.y = -stationRange.y / 2 * Vector2(world.tile_set.tile_size).y
	
	#Not optimal
	if !change: change = tagsInRange != newTags
	
	tagsInRange = newTags
	if change: refresh()


func refresh():
	for i in recipeContainer.get_children():
		i.queue_free()
	
	#Collect a list of items the player has
	var inventoryItems = []
	var inventoryStacks = []
	for i in get_node("../").panels:
		if i.get_child_count() > 0:
			i = i.get_child(0)
			inventoryItems.append(i.itemId) #This should be combined for same id's
			inventoryStacks.append(i.stack) #This should be combined for same id's
	
	#Loopthrough the workstations that are available
	for key in tagsInRange:
		#Check for recipes for the nearby tags
		if recipeList.has(key):
			var category = recipeList.get(key)
			#Loop through the recipes that are available
			for recipe in category.values():
				var valid = true
				
				#Check if player has item
				for item in recipe.keys(): #Keys are faster in this scenario
					if item is not String:
						#Check if player has item
						if inventoryItems.find(item) == -1:
							valid = false
							break
						#Check if player has required amount of the item
						elif inventoryStacks[inventoryItems.find(item)] < recipe.get(item):
							#print(inventoryStacks[inventoryItems.find(item)]," < ",recipe.get(item))
							valid = false
							break
				
				#Add recipe to current list
				if valid:
					addNewRecipe(recipe)
	
	get_node("../").refreshRecipes()

func addNewRecipe(recipe : Dictionary) -> void:
	var panel = slot.instantiate()
	panel.get_child(0).itemId = recipe["Result"]
	panel.get_child(0).stack = recipe["Amount"]
	panel.get_child(0).itemScript = recipe["Script"]
	
	var ing := []
	for i in recipe.keys(): if i is not String: ing.append([i,recipe[i]])
	
	panel.ingredients = ing
	panel.get_child(0).texture = load("res://Sprites/Items/Item_"+str(recipe["Result"])+".png") #This should be changed to the texture defined in the script
	
	recipeContainer.add_child(panel)

func setIngredients(ingredients : Array):
	for i in ingredientContainer.get_children():
		i.queue_free()
	
	for i in ingredients:
		var ingredientInst = ingredient.instantiate()
		ingredientInst.setItem(i[0],i[1])
		ingredientContainer.add_child(ingredientInst)
