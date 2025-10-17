extends TileMap
class_name World

@onready var dropItem = preload("res://InheritedScenes/DroppedItem.tscn")
@onready var generation = %Generation
@onready var hint = %DumbCrap
@onready var bar = %Progress
@onready var tileData = %TileComp
@onready var playerController = $PlayerController

@export var worldSeed := 0
@export var curve : Curve
@export var width := 60
@export var worldHeight := 90
@export var hillHeight := 30

var thread = Thread.new()
var progress = 0

var tileDamage : Dictionary[Vector2i, float] = { }

#var doIt = 0
var worldLoaded = false

signal DoneGenerating()

func _ready() -> void:
	set_process_unhandled_input(false)
	
	if Multiplayer.host:
		Multiplayer.Sync(SendWorldToClient)
	else:
		tileData.Start(self)
	hint.text = ""
	bar.value = 0
	
	if Global.load:
		var function = LoadWorld.bind("World",bar,hint)
		thread.start(function)
		thread.wait_to_finish()
	else:
		thread.start(GenerateWorld.bind(generation.get_children()))
		thread.wait_to_finish()
	
	set_process_unhandled_input(true)

func GenerateWorld(gens : Array):
	randomize()
	worldSeed = randi()
	seed(worldSeed)
	
	bar.call_deferred_thread_group("set","max_value",gens.size()+1)
	
	bar.value = 0
	
	for i in gens:
		if i is WorldGenerator:
			bar.call_deferred_thread_group("set","value",bar.value + 1)
			hint.call_deferred_thread_group("set","text",i.GetHint(self))
			hint.call_deferred_thread_group("queue_redraw")
			i.call_deferred_thread_group("Start",self)
			await get_tree().process_frame
	
	#Done
	bar.call_deferred_thread_group("set","value",bar.value + 1)
	hint.call_deferred_thread_group("set","text","Done! But I would recommend you just stop playing...")
	hint.call_deferred_thread_group("queue_redraw")
	await get_tree().create_timer(0.5).timeout
	
	#Start the world
	Start()
	playerController.SpawnNewPlayer(1)

func _unhandled_input(event: InputEvent) -> void:
	if Multiplayer.host or !Multiplayer.multi:
		if event.is_action_pressed("QuickSave"):
			SaveWorld()

#Spawn Player And Load
@rpc("authority","call_local")
func Start():
	$LoadingScreen.queue_free()
	worldLoaded = true
	
	get_tree().paused = false
	get_node("../Music").stream = load("res://Music/03 Overworld Day.wav")
	get_node("../Music").play()
	
	DoneGenerating.emit()

#region TilePlacing
##Place tile at mouse Position on all clients
func Place(pos : Vector2i, id, layer, atlas := Vector2i.ONE, update := true):
	if Multiplayer.multi:
		for i in Multiplayer.players:
			multiplayer.rpc(i,self,"_PlaceInWorld",[pos,id,layer,atlas,update])
	else:
		_PlaceInWorld(pos,id,layer,atlas,update)

##Place a tile of provided parameters if there's no tile at that position
func ControlledPlace(layer, pos, id, at, vari, ret = false):
	if get_cell_tile_data(layer,pos) == null:
		set_cell(layer,pos,id,at,vari)
		if ret:
			return true
	elif ret:
		return false

##Only place tile if another tile is present without update.
##This is mainly used for worldGen.
func ReplaceForced(layer : int, pos : Vector2, id :int, atlas : Vector2i):
	if get_cell_source_id(layer,pos) == -1: return
	set_cell(layer,pos,id,atlas)

##Only place tile if another tile is present with the given tag without update.
##This is mainly used for worldGen.
func ReplaceForcedTag(layer : int, pos : Vector2i, id :int, atlas : Vector2i, tag : String):
	if !HasTileTag(layer,pos,tag): return
	set_cell(layer,pos,id,atlas)

@rpc("any_peer","call_local")
##Place a tile of provided parameters on all clients.
##This function is usually called directly.
##Use Place instead.
func _PlaceInWorld(pos : Vector2i, id : int, layer : int, atlas := Vector2i.ONE, update := true):
	if layer != 0: #Change this when walls have been moved to a seperate map
		id += 400
	if get_cell_source_id(layer,pos) != id:
		set_cell(layer,pos,id,atlas)
		if !update: return
		_TileUpdate(pos,layer,true)

##Deal damage to the tile at [param pos].
##When enough damage is dealt the block will be destroyed.
func Mine(pos : Vector2i, layer : int, player : Player, item : Item):
	var id := get_cell_source_id(layer,pos)
	
	if id == -1: return
	if IdHasTileTag(id,"Mineable"):
		var script = load(IdGetTileTagValue(id,"Script"))
		script = script.new()
		
		if item is Pickaxe:
			if script.hardness <= item.power:
				if tileDamage.has(pos):
					tileDamage[pos] += item.power
				else:
					tileDamage[pos] = item.power
				
				script.Damage(player, pos, item.power)
				%DigSound.play() # temporary
				if tileDamage[pos] >= script.hitpoints:
					script.Destroy(player, pos)
		
		script.queue_free()

##Destroy with provided parameters
func Erase(pos : Vector2i, layer : int, player : Player):
	if Multiplayer.multi:
		var arr := [pos,layer,player.name]
		print("Destroy on all clients")
		for i in Multiplayer.players:
			multiplayer.rpc(i,self,"_EraseInWorld",arr)
	else:
		_EraseInWorld(pos,layer,player.name)

##Destroy with provided parameters on all clients
##This function is usually called directly.
##Use Erase instead.
@rpc("any_peer","call_local")
func _EraseInWorld(pos : Vector2i, layer : int, playerName : String):
	var id := get_cell_source_id(layer,pos)
	
	if id == -1: return
	var topTile = get_cell_source_id(layer,Vector2i(pos.x,pos.y-1))
	
	if topTile != -1:
		if IdHasTileTag(topTile,"Floored") and !IdHasTileTag(topTile,"Tree"): return
		elif IdHasTileTag(topTile,"Tree") and topTile != id: return
	
	var player : Player = playerController.get_node(playerName)
	var script = load(IdGetTileTagValue(id,"Script"))
	script = script.new()
	script.Destroy(player,pos)
	script.queue_free()
	
	player.world.tileDamage.erase(pos)

@rpc("any_peer","call_local")
func _TileUpdate(pos : Vector2i,layer : int,center = false):
	var id = get_cell_source_id(layer,pos)
	#index 4 is current tile
	#0 1 2
	#3 4 5
	#6 7 8
	
	if id != -1 and id != 666: #This should be changed when tree tops have been removed from the tilemap
		var script = load(IdGetTileTagValue(id,"Script"))
		script = script.new()
		script.Update(self,pos)
		script.queue_free()
	
	if !center: return
	
	var origin = pos
	pos.x -= 1
	pos.y -= 1
	for i in range(9):
		# Haha big stupid l L+ratio monkey donkeys real true fr i mean it yep here big dumdum skill issue (I forgor why I typed this)
		if pos != origin:
			_TileUpdate(pos,layer)
		pos.x += 1
		if pos.x >= origin.x+2:
			pos.y += 1
			pos.x = origin.x-1 
#endregion

#region TileData
##Check if tile specified at coordinates has tag
func HasTileTag(layer : int, pos : Vector2i, tag : String) ->bool:
	var id = get_cell_source_id(layer,pos)
	if id > tileData.tileData.size() or tileData.tileData[id] == null: return false
	return tileData.tileData[id].tags.has(tag)

##Check if the tile id has tag
func IdHasTileTag(id : int,tag : String) ->Variant:
	if id > tileData.tileData.size() or tileData.tileData[id] == null: return null
	return tileData.tileData[id].tags.has(tag)

##Returns the value assigned to a tag
func GetTileTagValue(layer : int, pos : Vector2i, tag : String) ->Variant:
	var id = get_cell_source_id(layer,pos)
	if id > tileData.tileData.size() or tileData.tileData[id] == null\
	or !tileData.tileData[id].tags.has(tag): return null
	return tileData.tileData[id].tags.get(tag)

##Returns the value assigned to a tag from the tile Id
func IdGetTileTagValue(id : int,tag : String) ->Variant:
	if id > tileData.tileData.size() or tileData.tileData[id] == null\
	or !tileData.tileData[id].tags.has(tag): return null
	return tileData.tileData[id].tags.get(tag)

##Returns the tags for tile at pos on layer
func GetTileTags(layer : int, pos : Vector2i) -> Dictionary:
	var id = get_cell_source_id(layer,pos)
	if id == -1: return { }
	if id > tileData.tileData.size() or tileData.tileData[id] == null: return { }
	return tileData.tileData[id].tags

##Get all surrounding tiles
##All my homies Love getDaBois
func GetDaBois(pos : Vector2i,layer : int):
	var arr := []
	var origin := pos.x
	pos.x -= 1
	pos.y -= 1
	
	for i in range(9):
		var arr2:Array = []
		arr2.append(get_cell_atlas_coords(layer,pos))
		arr2.append(get_cell_source_id(layer,pos))
		arr2.append(get_cell_tile_data(layer,pos))
		arr.append(arr2)
		pos.x += 1
		if pos.x >= origin+2:
			pos.y += 1
			pos.x = origin-1
	
	return arr

##Get if tile is valid tile for connecting
##N should be source Id
##Returns true if type is -1(default) and n is not -1[br]
##Returns true if type is anyother value and n is equal[br]
func Boi(n,type := -1) -> bool:
	if type == -1:
		if n[1] == -1: return false
		elif IdHasTileTag(n[1],"Plant") or IdHasTileTag(n[1],"Furniture"): return false
		return true
	else:
		return n[1] == type

##Get if tiles are valid tiles for connecting
##N should be source Id
##Returns true if type is n and not -1[br]
##Returns true if type is another value and n is equal[br]
func Bois(list : Array,type := -1) -> Array[bool]:
	var val : Array[bool] = []
	for n in list:
		val.append(Boi(n,type))
	return val
#endregion

func DropItem(item : Item,pos : Vector2i,stack := 1):
	var it = dropItem.instantiate()
	it.global_position = pos*16.0
	self.add_child(it)
	
	it.SetData(item.itemId,stack,item.get_script().get_path())
	
	if item.texture == "": return
	it.SetTexture("res://Sprites/"+item.texture)

#region World Save
##Save the current world
func SaveWorld():
	var pos := Vector2(0 - float(width)/2,-hillHeight)
	var arr := []
	var arrW := []
	var world := WorldSave.new()
	
	world.width = width
	world.height = worldHeight+hillHeight
	
	#X pos
	for i in range(width):
		var arr2 := []
		var arr2W := []
		#Y pos
		for j in range(worldHeight+hillHeight):
			var arr3 := []
			arr3.append(get_cell_atlas_coords(0,pos))
			arr3.append(get_cell_source_id(0,pos))
			arr2.append(arr3)
			
			var arr3W := []
			arr3W.append(get_cell_atlas_coords(1,pos))
			arr3W.append(get_cell_source_id(1,pos))
			arr2W.append(arr3W)
			pos.y+= 1
		
		arr.append(arr2)
		arrW.append(arr2W)
		pos.x += 1
		pos.y = -hillHeight
	
	world.world = arr
	world.wall = arrW
	
	Saver._save("World",world)

##Check for save file
##If found load the world
func LoadWorld(map):
	hint.text = "Why did you return?"
	await get_tree().process_frame
	var world : WorldSave = Saver._load(map)
	print("Looking For Save")
	await get_tree().process_frame
	
	if world == null:
		print("Load failed: Save doesn't exist")
		return
	
	bar.max_value = width
	bar.value = 0
	var half := false
	var pos := Vector2i(roundi(0. - float(world.width) / 2.), -hillHeight)
	
	for i in world.world:
		for j in i:
			set_cell(0,pos,j[1],j[0])
			pos.y += 1
		pos.x += 1
		pos.y = -hillHeight
		bar.value += 1
		
		if bar.value > bar.max_value/2 and !half:
			hint.text ="No seriously WHY!?"
			half = true
			await get_tree().process_frame
	
	pos = Vector2(0. - float(world.width) / 2., -hillHeight)
	
	for i in world.wall:
		for j in i:
			set_cell(1,pos,j[1],j[0])
			pos.y += 1
		pos.x += 1
		pos.y = -hillHeight
		bar.value += 1
	
	Start()
#endregion

#region Multiplayer

#Send world to new client and spawn a new player
func SendWorldToClient(id : int):
	var thread2 = Thread.new()
	var function = ServerSendWorld.bind(id,multiplayer)
	thread2.start(function,Thread.PRIORITY_LOW)
	thread2.wait_to_finish()
	
	playerController.SpawnNewPlayer(id)

@warning_ignore("narrowing_conversion")
func ServerSendWorld(id,multibind):
	print("Sending World to client")
	if id != 1:
		var pos := Vector2i(roundi(0 - float(width) / 2),-30)
		var update := 0
		for i in range(width):
			if update >= 10:
				await get_tree().process_frame
				update = 0
			for j in range(120):
				var arr := []
				arr.append(get_cell_atlas_coords(0,pos))
				arr.append(get_cell_source_id(0,pos))
				arr.append(pos)
				arr.append(width*120)
				multibind.call_deferred("rpc",id,self,"LoadServerWorld",arr)
				pos.y += 1
			pos.y = -30
			pos.x += 1
			update += 1
		multiplayer.rpc(id,self,"Start")
	else:
		print("Sending Cancelled Client is the Host")

@rpc("any_peer","call_local")
func LoadServerWorld(atl,source,pos,max):
	set_cell(0,pos,source,atl)
	if bar == null: return
	bar.max_value = max
	bar.value += 1
	if bar.value < bar.max_value / 2:
		hint.text = "Seriously now your with more than one?"
	else:
		hint.text = "How bad is your mental state if you want to go through this with friends?"
#endregion
