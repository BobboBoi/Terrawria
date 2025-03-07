extends Node

func GoToScene(scene):
	var loader = ResourceLoader.load("res://Generation.tscn")
	
	while true:
		if loader is Resource:
			get_tree().get_root().call_deferred("add_child",loader.instance())
			break
		if loader == OK:
			
