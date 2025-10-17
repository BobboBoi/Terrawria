extends WorldGenerator

@export var curve : Curve = null
@export var chance := 100
@export var maxBlobSize := 8
@export var maxBlobs := 6

func GetHint(_w : World) -> String:
	return "Addin spaghetti"

func Start(w : World):
	super(w)
	#Set world properties
	var width = world.width
	var height = world.worldHeight+world.hillHeight
	var pos := Vector2(0 - float(width)/2,-world.hillHeight)
	
	#Go over entire world width
	for x in range(width):
		if randi_range(1,chance) == 1:
			for y in range(height):
				#If block has StoneReplacable tag continue
				if world.HasTileTag(0,pos,"ValidCave"): 
					MainCave(pos)
					break
				
				pos.y += 1
		
		#Set properties for next loop
		pos.x += 1
		pos.y = -world.hillHeight

##When a succesful spot has been selected remove multiple blobs to form a cave
func MainCave(pos : Vector2):
	#Setup variables
	var blobPos := pos
	#var blobDir := 0.0
	
	var debug = Line2D.new()
	debug.width = 20
	add_child(debug)
	
	for i in range(randi_range(10,maxBlobs)):
		#if world.get_cell_source_id(0,blobPos) == -1: break
		var blobSize := randi_range(10,maxBlobSize)
		
		Circle(blobPos,blobSize)#draw circle
		if(randi_range(1,10) == 1):
			SmallBranch(blobPos)
		debug.add_point(blobPos*16)
		
		#blobDir += randf_range(-0.17*2,0.17*2)
		#blobDir = clamp(blobDir,1.570796,blobDir)
		#blobPos += Vector2.RIGHT.rotated(blobDir).normalized() * blobSize*0.3
		
		blobPos += Vector2(randf_range(-1,1),randf_range(0,0.5)).normalized() * blobSize * 0.3

func SmallBranch(pos : Vector2):
	var blobPos := pos
	#var blobDir := 0.0
	
	var debug = Line2D.new()
	debug.width = 10
	add_child(debug)
	
	for i in range(randi_range(10,maxBlobs)):
		#if world.get_cell_source_id(0,blobPos) == -1: break
		var blobSize := randi_range(10,maxBlobSize)
		
		Circle(blobPos,blobSize)#draw circle
		debug.add_point(blobPos*16)
		
		#blobDir += randf_range(-0.17*2,0.17*2)
		#blobDir = clamp(blobDir,1.570796,blobDir)
		#blobPos += Vector2.RIGHT.rotated(blobDir).normalized() * blobSize*0.3
		
		blobPos += Vector2(randf_range(-1,1),randf_range(0.5,0.5)).normalized() * blobSize * 0.3

##Draw a circle at pos with radius
func Circle(pos : Vector2,radius):
	var center = pos
	var origin = Vector2(pos.x - radius/2,pos.y - radius/2)
	pos = origin
	
	for x in range(radius):
		for y in range(radius):
			if (pos-center).length_squared() <= radius:
				world.set_cell(0,pos,-1)
			pos.y += 1
		pos.y = origin.y
		pos.x += 1
