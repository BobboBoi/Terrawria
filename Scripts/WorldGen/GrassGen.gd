extends WorldGenerator

func GetHint(w : World) -> String:
	return "Generratin A LOT off dirt "+str(w.worldHeight*w.width)+" to be exact"

func Start(w : World):
	super(w)
	
	# C U B E
	var pos := Vector2(0 - float(world.width)/2,world.worldHeight)
	for y in range(world.worldHeight):
		for x in range(world.width):
			world.set_cell(0,pos,0,Vector2i(randi_range(1,3),1))
			pos.x += 1
		pos.x = 0 - float(world.width)/2
		pos.y -= 1
	
	#Set world properties
	var repeat = 4
	var width = world.width
	var offset :=  0.0
	pos = Vector2(0 - float(width)/2,0)
	
	world.curve.bake_resolution = roundi(float(width)/repeat)
	world.curve.bake()
	
	#Go over entire world width
	for i in range(width):
		var heightOff = w.curve.sample(offset)
		#Place Grass at top
		
		#Place grass at bottom if curve y is 0
		if roundi(heightOff*world.hillHeight) == 0:
			world.set_cell(0,Vector2(pos.x,0),2,Vector2i(randi_range(1,3),0))
		else:
			#Set grass and dirt for curve offset
			for j in range(roundi(heightOff*world.hillHeight)):
				if j+1 == roundi(heightOff*world.hillHeight):
					world.set_cell(0,pos,2,Vector2i(randi_range(1,3),0))
				else:
					world.set_cell(0,pos,0,Vector2i(randi_range(1,3),1))
				pos.y -= 1
		
		#Set properties for next loop
		pos.x += 1
		pos.y = 0
		
		#Loop curve x offset
		if offset >= 1:
			offset = 0
		offset += 1.0/width*repeat
	
	
	
	#Spawn seeds
	pos = Vector2(0 - float(width)/2,0)
	for i in range(width):
		for j in range(round(float(world.worldHeight)/3)):
			if randi_range(1,100) == 1:
				world.set_cell(0,pos,2,Vector2i(6+randi_range(0,2),11))
			pos.y += 1
		
		#Set properties for next loop
		pos.x += 1
		pos.y = 0
