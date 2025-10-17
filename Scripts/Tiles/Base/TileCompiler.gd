extends WorldGenerator

var tileData : Array[TileInfo] = []

func GetHint(_w : World) -> String:
	return "Compiling Tiles :)..... (Fuuuuucucucuuckckckckc)"

func Start(w : World):
	super(w)
	
	var dir = DirAccess.open("res://Scripts/Tiles/")
	var tiles = []
	
	dir.list_dir_begin() 
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif file.ends_with(".gd"):
			tiles.append("res://Scripts/Tiles/"+file)
	
	dir.list_dir_end()
	
	tileData.resize(99)
	
	for i in tiles:
		var tile = load(i).new()
		tile = tile.Compile()
		tileData[tile.id] = tile
