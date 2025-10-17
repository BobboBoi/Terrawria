extends Node
class_name Tile
##Used to execute code for tiles in the [World] class
##
##To change the default values set or add them in an _init() function.

##The tile this code is connected to.
@export var tileId := 0
##The pickaxe power required to destroy this tile.
@export var hardness := 35
##The amount of hp this block has.
@export var hitpoints := 50
##Tags are used for all sorts of functions.[br]
##An example is that a tile with the grass tag can have plants growing on them.
##Or a tile with the Mineable tag can be mined with a pickaxe.[br]
##Add your own tags to this list to easily categorize tiles for custom behaviour.
##Tags can also have values attached to them for even more customizability.
@export var tagList : Dictionary = {
	"Mineable": null,
}

func Compile() -> TileInfo:
	var newInfo = TileInfo.new()
	newInfo.id = tileId
	newInfo.tags = tagList
	newInfo.tags["Script"] = self.get_script().get_path()
	newInfo.resource_name = "Tile_"+str(tileId)
	return newInfo

func Destroy(player : Player, pos : Vector2i) -> void:
	Destroyed(player,pos)

##Called when block is destroyed.[br]
##Override this function to create a custom destroy behaviour
func Destroyed(player : Player, pos : Vector2i) -> void:
	Erase(player.world,pos)

func Damage(player : Player, pos : Vector2i, dmg : float) -> void:
	Damaged(player, pos, dmg)

func Damaged(_player : Player, _pos : Vector2i, _dmg : float) -> void:
	pass

##Delete tile from world and update surrounding tiles
func Erase(world : World, pos : Vector2i):
	world.erase_cell(0,pos)
	world._TileUpdate(pos,0,true)

func Update(world : World, pos : Vector2i) -> void:
	Updated(world,pos)

##Called when a block update is called.[br]
##Override this function to create a custom update behaviour
func Updated(world : World, pos : Vector2i) -> void:
	Connect(world,pos)

#Yandere dev moment comming up
#Protect you eyes before looking at the coming two functions will be rewriten once i've found the best way to go about it

#region horror
##Default connecting tile check code.[br]
##Checks for surrounding air to change tile atlas.
func Connect(world : World, pos : Vector2i) -> void:
	var surr = world.GetDaBois(pos,0)
	var id = tileId
	var rand = randi_range(0,2)
	var block = world.Bois(surr)
	#index 4 is current tile
	#0 1 2
	#3 4 5
	#6 7 8
	
	#No Connect
	if block[1] and block[3] and block[5] and block[7]: 
		world.set_cell(0,pos,id,Vector2i(1+rand,1))
	
	#NoTop
	elif !block[1] and block[3] and block[5] and block[7]: 
		world.set_cell(0,pos,id,Vector2i(1+rand,0))
	#NoBottom
	elif block[1] and block[3] and block[5] and !block[7]: 
		world.set_cell(0,pos,id,Vector2i(1+rand,2))
	#NoLeft
	elif block[1] and !block[3] and block[5] and block[7]: 
		world.set_cell(0,pos,id,Vector2i(0,0+rand))
	#NoRight
	elif block[1] and block[3] and !block[5] and block[7]: 
		world.set_cell(0,pos,id,Vector2i(4,0+rand))
	
	#CornerTopL
	elif !block[1] and !block[3] and block[5] and block[7]: 
		world.set_cell(0,pos,id,Vector2i(rand*2,3))
	#CornerTopR
	elif !block[1] and block[3] and !block[5] and block[7]: 
		world.set_cell(0,pos,id,Vector2i(1+rand*2,3))
	#CornerBottomL
	elif block[1] and !block[3] and block[5] and !block[7]: 
		world.set_cell(0,pos,id,Vector2i(rand*2,4))
	#CornerBottomR
	elif block[1] and block[3] and !block[5] and !block[7]: 
		world.set_cell(0,pos,id,Vector2i(1+rand*2,4))
	
	#Horizontal
	elif !block[1] and block[3] and block[5] and !block[7]:
		world.set_cell(0,pos,id,Vector2i(6+rand,4))
	#Vertical
	elif block[1] and !block[3] and !block[5] and block[7]:
		world.set_cell(0,pos,id,Vector2i(5,0+rand))
	
	elif block[1] and !block[3] and !block[5] and !block[7]:
		world.set_cell(0,pos,id,Vector2i(6+rand,3))
	elif !block[1] and block[3] and !block[5] and !block[7]:
		world.set_cell(0,pos,id,Vector2i(12,rand))
	elif !block[1] and !block[3] and block[5] and !block[7]:
		world.set_cell(0,pos,id,Vector2i(9,rand))
	elif !block[1] and !block[3] and !block[5] and block[7]:
		world.set_cell(0,pos,id,Vector2i(6+rand,0))
	
	#lonele
	elif !block[1] and !block[3] and !block[5] and !block[7]:
		world.set_cell(0,pos,id,Vector2i(9+rand,3))

##@experimental
##Default interconnecting tile check code.[br]
##Checks for surrounding tile of type to change tile atlas.
func InterConnect(world : World, pos : Vector2i, type : int) -> bool:
	var surr = world.GetDaBois(pos,0)
	var id = tileId
	var rand = randi_range(0,2)
	
	var block := world.Bois(surr) #true if block
	var alt := world.Bois(surr,type) #true if alt
	
	
	#index 4 is current tile
	#0 1 2
	#3 4 5
	#6 7 8
	
	#region WithoutAir
	#Full block BottomR alt
	if block[1] and block[3] and block[5] and block[7] \
	and block[0] and block[2] and block[6] and alt[8]:
		world.set_cell(0,pos,id,Vector2i(2,5+rand*2))
		return true
	#Full block BottomL alt
	if block[1] and block[3] and block[5] and block[7] \
	and block[0] and block[2] and alt[6] and block[8]:
		world.set_cell(0,pos,id,Vector2i(3,5+rand*2))
		return true
	#Full block TopL alt
	if block[1] and block[3] and block[5] and block[7] \
	and block[0] and alt[2] and block[6] and block[8]:
		world.set_cell(0,pos,id,Vector2i(2,6+rand*2))
		return true
	#Full block TopR alt
	if block[1] and block[3] and block[5] and block[7] \
	and alt[0] and block[2] and block[6] and block[8]:
		world.set_cell(0,pos,id,Vector2i(3,6+rand*2))
		return true
	
	#TopL alt BottomR block
	if alt[1] and alt[3] and block[5] and block[7]: 
		world.set_cell(0,pos,id,Vector2i(2,5+rand*2))
		return true
	#TopR alt BottomL block
	if alt[1] and block[3] and alt[5] and block[7]: 
		world.set_cell(0,pos,id,Vector2i(3,5+rand*2))
		return true
	#BottomL alt TopR block
	if block[1] and alt[3] and block[5] and alt[7]: 
		world.set_cell(0,pos,id,Vector2i(2,6+rand*2))
		return true
	#BottomR alt TopL block
	if block[1] and block[3] and alt[5] and alt[7]: 
		world.set_cell(0,pos,id,Vector2i(3,6+rand*2))
		return true
	
	#Full Same bottom alt
	if block[1] and block[3] and block[5] and alt[7]: 
		world.set_cell(0,pos,id,Vector2i(8+rand,5))
		return true
	#Full Same top alt
	if alt[1] and block[3] and block[5] and block[7]: 
		world.set_cell(0,pos,id,Vector2i(8+rand,6))
		return true
	#Full Same right alt
	if block[1] and block[3] and alt[5] and block[7]: 
		world.set_cell(0,pos,id,Vector2i(8,7+rand))
		return true
	#Full Same left alt
	if block[1] and alt[3] and block[5] and block[7]: 
		world.set_cell(0,pos,id,Vector2i(9,7+rand))
		return true
	
	#Same tops alt sides
	if block[1] and alt[3] and alt[5] and block[7]: 
		world.set_cell(0,pos,id,Vector2i(10,7+rand))
		return true
	#Alt tops same sides
	if alt[1] and block[3] and block[5] and alt[7]: 
		world.set_cell(0,pos,id,Vector2i(8+rand,10))
		return true
	
	#Full Alt bottom block
	if alt[1] and alt[3] and alt[5] and block[7]: 
		world.set_cell(0,pos,id,Vector2i(11,5+rand))
		return true
	#Full Alt top block
	if block[1] and alt[3] and alt[5] and alt[7]: 
		world.set_cell(0,pos,id,Vector2i(11,8+rand))
		return true
	#Full Alt right block
	if alt[1] and alt[3] and block[5] and alt[7]: 
		world.set_cell(0,pos,id,Vector2i(6+rand,11))
		return true
	#Full Alt left block
	if alt[1] and block[3] and alt[5] and alt[7]: 
		world.set_cell(0,pos,id,Vector2i(12,8+rand))
		return true
	
	#Full alt
	if alt[1] and alt[3] and alt[5] and alt[7]: 
		world.set_cell(0,pos,id,Vector2i(12,8+rand))
		return true
	#endregion
	
	#region WithAir
	#Top air Same sides bottom alt
	if !block[1] and block[3] and block[5] and alt[7]: 
		world.set_cell(0,pos,id,Vector2i(13+rand,0))
		return true
	#Bottom air Same sides top alt
	if alt[1] and block[3] and block[5] and !block[7]: 
		world.set_cell(0,pos,id,Vector2i(13+rand,1))
		return true
	#Left air Same tops right alt
	if block[1] and !block[3] and alt[5] and block[7]: 
		world.set_cell(0,pos,id,Vector2i(13+rand,2))
		return true
	#Right air Same tops left alt
	if block[1] and alt[3] and !block[5] and block[7]: 
		world.set_cell(0,pos,id,Vector2i(13+rand,3))
		return true
	
	#Left air top and right block 
	if block[1] and !block[3] and block[5] and alt[7]: 
		world.set_cell(0,pos,id,Vector2i(4,5+rand))
		return true
	#Right air top and left block 
	if block[1] and block[3] and !block[5] and alt[7]: 
		world.set_cell(0,pos,id,Vector2i(5,5+rand))
		return true
	
	#Left air bottom and left block 
	if alt[1] and !block[3] and block[5] and block[7]: 
		world.set_cell(0,pos,id,Vector2i(4,8+rand))
		return true
	#Right air bottom and left block 
	if alt[1] and block[3] and !block[5] and block[7]: 
		world.set_cell(0,pos,id,Vector2i(5,8+rand))
		return true
	
	#endregion
	
	return false
#endregion
