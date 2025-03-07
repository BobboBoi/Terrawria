extends Node2D

@onready var player = preload("res://player.tscn")

func SpawnNewPlayer(id : int):
	var playerI = player.instantiate()
	playerI.name = str(id)
	add_child(playerI,true)
