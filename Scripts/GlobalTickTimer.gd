extends Node

const GAME_TICKS := 60
var tickTime := 0.

signal Tick

func Add(callable : Callable) -> void:
	Tick.connect(callable)

func _process(delta: float) -> void:
	tickTime += delta
	
	for t in range(floor(tickTime/(1./GAME_TICKS))):
		tickTime -= 1./GAME_TICKS
		Tick.emit()
