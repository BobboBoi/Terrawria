extends Node2D

var music := {
	"Overworld Day": preload("res://Music/03 Overworld Day.wav"),
	"Alt Overworld Day": preload("res://Music/18 Alt Overworld Day.wav")
}

func _ready():
	if Multiplayer.host:
		Multiplayer._host()
	elif Multiplayer.multi:
		Multiplayer._join()

func _on_music_finished():
	var rand = randi_range(1,2)
	if rand == 1:
		$Music.stream = music["Overworld Day"]
	else:
		$Music.stream = music["Alt Overworld Day"]
	
	$Music.play()
