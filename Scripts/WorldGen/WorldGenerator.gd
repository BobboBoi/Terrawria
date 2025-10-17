extends Node
class_name WorldGenerator

var world : World
var loadingHint := "HAHA I forgor to type text here"


func GetHint(_w : World) -> String:
	return ""

func Start(w : World):
	world = w
