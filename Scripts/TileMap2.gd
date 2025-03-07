extends TileMap

var lastPos:Vector2i

func _physics_process(_delta):
	var pos = Vector2i(round((get_global_mouse_position().x-8)/16),round((get_global_mouse_position().y-8)/16))
	if pos != lastPos:
		erase_cell(0,lastPos)
		set_cell(0,pos,1,Vector2i(1,1),1)
	lastPos = pos
