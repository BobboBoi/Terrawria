extends Node2D

@onready var cam := get_viewport().get_camera_2d()

@export var scrollScale := 0.5
@export var repeatSize := Vector2(256,192)
@export var limitStart := Vector2(-10000000,-10000000)
@export var limitEnd := Vector2(10000000,10000000)

func _process(_delta) -> void:
	if cam == null:
		cam = get_viewport().get_camera_2d()
		if cam == null: return
	
	var targetPos := cam.get_screen_center_position()
	targetPos.x = clampf(cam.get_screen_center_position().x - 1920/2 - repeatSize.x,limitStart.x,limitEnd.x)
	if repeatSize.y != 0.0:
		targetPos.y = clampf(cam.get_screen_center_position().y - 1080/2 - repeatSize.y,limitStart.y,limitEnd.y)
	else:
		targetPos.y = clampf(limitStart.y,limitStart.y,limitEnd.y)
	global_position = targetPos
	
	get_child(0).position = Vector2(wrapf(targetPos.x*-scrollScale,0.0,repeatSize.x),wrapf(targetPos.y*-scrollScale,0.0,repeatSize.y))
