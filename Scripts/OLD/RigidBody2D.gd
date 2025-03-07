extends RigidBody2D

func _process(_delta):
	if Input.is_action_pressed("left"):
		apply_impulse(Vector2(-5,0))
	elif Input.is_action_pressed("right"):
		apply_impulse(Vector2(5,0))
	
	if Input.is_action_just_pressed("jump"):
		apply_impulse(Vector2(linear_velocity.x,-250))
