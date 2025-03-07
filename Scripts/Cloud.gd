extends Sprite2D

var speed:float

func _ready():
	var dir = DirAccess
	
	var styles = dir.get_files_at("res://Sprites/Backgrounds/")
	var options:Array = []
	var number = 0
	
	for i in styles:
		if !i.ends_with(".import") and i.begins_with("Cloud_") and number < 22:
			options.append(i)
			number += 1
	
	texture = load("res://Sprites/Backgrounds/"+options[randi_range(0,21)])
	speed = randf_range(0.2,0.5)
	
	var rand = randf_range(1,3)
	
	scale.x = rand
	scale.y = rand

func _physics_process(_delta):
	position.x += speed
