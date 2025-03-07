extends Node2D

func _ready():
	if Multiplayer.host:
		Multiplayer._host()
	elif Multiplayer.multi:
		Multiplayer._join()



func _on_music_finished():
	var rand = randi_range(1,2)
	if rand == 1:
		$Music.stream = load("res://Music/03 Overworld Day.wav")
	else:
		$Music.stream = load("res://Music/18 Alt Overworld Day.wav")
	$Music.play()
