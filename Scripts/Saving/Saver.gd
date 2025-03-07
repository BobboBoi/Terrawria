extends Node

const saveLocation = "user://SaveData/Save"
var saveFile = 0

func _save(saveLoc,item,fullPath = false):
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("user://SaveData"):
		dir.make_dir_recursive("user://SaveData")
	if not dir.dir_exists(saveLocation+str(saveFile)):
		dir.make_dir_recursive(saveLocation+str(saveFile))
	
	var path = ""
	if !fullPath:
		path += saveLocation+str(saveFile)+"/"
	path += saveLoc+".tres"
	
	ResourceSaver.save(item,path)

func _load(loadLoc,fullPath = false):
	var path := ""
	if !fullPath:
		path += saveLocation+str(saveFile)+"/"
	path += loadLoc+".tres"
	if !ResourceLoader.exists(path): return null
	
	var loaded = ResourceLoader.load(path)
	if loaded  != null:
		return loaded
