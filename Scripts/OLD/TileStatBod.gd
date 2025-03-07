extends StaticBody2D
class_name TileStat
##@deprecated
##This was a test 

var pos = Vector2i((global_position.x-8)/16,(global_position.y-8)/16)
func _ready():
	add_to_group(str(pos))
	Update()

func Update():
	var l = GetTile(Vector2i(pos.x - 1,pos.y))
	var r = GetTile(Vector2i(pos.x + 1,pos.y))
	var t = GetTile(Vector2i(pos.x,pos.y - 1))
	var b = GetTile(Vector2i(pos.x,pos.y + 1))
	
	var rand = randi_range(0,2) 
	if Null(l) and Null(r) and Null(t) and Null(b):
		$Sprite2D.set_region_rect(GetReg(Vector2i(9+rand,3)))
		
	elif !Null(l) and !Null(r) and !Null(t) and !Null(b):
		$Sprite2D.set_region_rect(GetReg(Vector2i(1+rand,1)))
		
	elif Null(l) and !Null(r) and !Null(t) and !Null(b):
		$Sprite2D.set_region_rect(GetReg(Vector2i(0,0+rand)))
		
	elif !Null(l) and Null(r) and !Null(t) and !Null(b):
		$Sprite2D.set_region_rect(GetReg(Vector2i(4,1+rand)))
		
	elif !Null(l) and !Null(r) and Null(t) and !Null(b):
		$Sprite2D.set_region_rect(GetReg(Vector2i(1+rand,0)))
		
	elif !Null(l) and !Null(r) and! Null(t) and Null(b):
		$Sprite2D.set_region_rect(GetReg(Vector2i(1+rand,2)))
	
	else:
		$Sprite2D.set_region_rect(GetReg(Vector2i(1+rand,1)))


func GetTile(tilePos):
	get_tree().get_first_node_in_group(str(tilePos))
func Null(variable):
	if variable == null:
		return true
	else:
		return false
func GetReg(atlas):
	var x = atlas.x*16 + atlas.x*2
	var y = atlas.y*16 + atlas.y*2
	return Rect2i(x,y,16,16)
