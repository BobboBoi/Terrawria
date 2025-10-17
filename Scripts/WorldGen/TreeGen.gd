extends WorldGenerator

func GetHint(_w : World) -> String:
	return "Addin Long bois and short bois"

func Start(w : World):
	super(w)
	
	var width = world.width
	var pos = Vector2(0 - float(width)/2,0)
	
	for x in range(width):
		for y in range(world.worldHeight+1):
			if world.HasTileTag(0,pos,"Grass"):
				Plant(pos)
			
			pos.y -= 1
		
		#Set properies for next Loop
		pos.x += 1
		pos.y = 1

##Check if pos is valid and place plantLife
func Plant(pos):
	pos.y -= 1
	if randi_range(0,2) == 1 and world.get_cell_tile_data(0,pos) == null:
		#Place Tree
		if randi_range(0,2) == 1:
			var treeHeight = randi_range(7,22)
			var treeSize = Vector2(pos.x-2,pos.y)
			var end = false
			
			#Check For Valid Tree Spot
			for i in range(treeHeight+6):
				for j in range(5):
					if world.get_cell_tile_data(0,treeSize) != null:
						var data = world.get_cell_tile_data(0,treeSize).get_custom_data("Type")
						if data != "Decoration":
							end = true
							break
					treeSize.x += 1
				treeSize.x -= 5
				treeSize.y -= 1
			
			#GenerateTree
			GenerateTree(pos,end,treeHeight,treeSize)
		
		else:
			#Place Plant
			world.ControlledPlace(0,pos,3,Vector2i(randi_range(0,7),0),0)


func GenerateTree(pos,end,treeHeight,_treeSize):
	if end: return 
	
	#LeftRoot Check
	var rootL = false
	if randi_range(0,2) == 1:
		rootL = true
		var rootPos = pos
		rootPos.x -= 1
		rootL = world.ControlledPlace(0,rootPos,5,Vector2i(2,randi_range(6,8)),0,true)
	
	#RightRoot Check
	var rootR = false
	if randi_range(0,2) == 1:
		rootR = true
		var rootPos = pos
		rootPos.x += 1
		rootR = world.ControlledPlace(0,rootPos,5,Vector2i(1,randi_range(6,8)),0,true)
	
	#Bottom tile
	if rootL and rootR:
		world.ControlledPlace(0,pos,5,Vector2i(4,randi_range(6,8)),0)
	elif rootL:
		world.ControlledPlace(0,pos,5,Vector2i(3,randi_range(6,8)),0)
	elif rootR:
		world.ControlledPlace(0,pos,5,Vector2i(0,randi_range(6,8)),0)
	else:
		world.ControlledPlace(0,pos,5,Vector2i(0,randi_range(0,2)),0)
	
	#Leafs
	for i in range(treeHeight):
		pos.y -= 1
		world.ControlledPlace(0,pos,5,Vector2i(0,randi_range(0,2)),0)
		if i+1 == treeHeight:
			pos.y -= 1
			var leafPos = pos
			#var top = randi_range(0,2)
			if true:
				leafPos.x -= 2
				var atlas = Vector2i(0,4)
				for j in range(5):
					for k in range(5):
						world.set_cell(0,leafPos,666,atlas)
						leafPos.x += 1
						atlas.x += 1
					leafPos.y -= 1
					leafPos.x -= 5
					atlas.y -= 1
					atlas.x -= 5
