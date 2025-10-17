extends WorldGenerator

@export var curve : Curve = null
@export var chance := 800
@export var maxBlobSize := 6
@export var maxBlobs := 6

func GetHint(_w : World) -> String:
	return "Adding cringe shiny"

func Start(w : World):
	super(w)
	
	#Set world properties
	var width = world.width
	var height = world.worldHeight+world.hillHeight
	var pos := Vector2(0 - float(width)/2,-world.hillHeight)
	
	#Go over entire world width
	for x in range(width):
		for y in range(height):
			#If block has StoneReplacable tag continue
			if world.HasTileTag(0,pos,"StoneReplacable"): 
				TryBlob(y,pos,height)
			
			pos.y += 1
		
		#Set properties for next loop
		pos.x += 1
		pos.y = -world.hillHeight

##When a succesful spot has been selected place multiple blobs to form a vein
func TryBlob(y : int,pos : Vector2,height : int):
	if randi_range(1,roundi(chance * (1. - curve.sample(float(y)/height)))) != 1: return
	
	#Setup variables
	var blobPos := pos
	
	#var debug = Line2D.new()
	#debug.width = 3
	#add_child(debug)
	
	for i in range(randi_range(2,maxBlobs)):
		if world.get_cell_source_id(0,blobPos) == -1: break
		var blobSize := randi_range(3,maxBlobSize)
		
		Circle(blobPos,blobSize)#draw circle
		#debug.add_point(blobPos*16)
		blobPos += Vector2(randf_range(-1,1),randf_range(-1,1)).normalized() * blobSize/2

##Draw a circle at pos with radius
func Circle(pos : Vector2,radius):
	var center = pos
	var origin = Vector2(pos.x - radius/2,pos.y - radius/2)
	pos = origin
	
	for x in range(radius):
		for y in range(radius):
			if (pos-center).length_squared() <= radius:
				world.ReplaceForcedTag(0,pos,7,Vector2i(6+randi_range(0+randi_range(0,2),2),1),"StoneReplacable")
			pos.y += 1
		pos.y = origin.y
		pos.x += 1
