extends Tile

var item = "res://Scripts/Items/StoneItem.gd"

func _init():
	tileId = 1
	tagList["Stone"] = null

func Destroyed(player : Player,pos : Vector2i) -> void:
	var world = player.world
	
	var newItem = load(item)
	world.DropItem(newItem.new(),pos)
	Erase(world,pos)

func Updated(world : World,pos : Vector2i):
	var connected = InterConnect(world,pos,0)
	if connected: return
	Connect(world,pos)
