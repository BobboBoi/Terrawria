extends Node
class_name WorldGenerator

@onready var world : Tilemap = get_parent()
var loadingHint := "HAHA I forgor to type text here"

func Start():
	world.bar.value += 1
	world.hint.text = "Addin Grass"
	await get_tree().create_timer(0.1).timeout
