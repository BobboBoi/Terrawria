extends CanvasLayer



func _physics_process(delta):
	$Bar.position.x += 1
func update(world):
		$Bar/Progress.value = world.progress
		$Bar/DumbCrap.text = world.hint
