extends Parallax2D

@onready var cloud = preload("res://Scenes/cloud.tscn")


func _physics_process(_delta):
	if randi_range(0, 200) == 50 and get_tree().get_nodes_in_group("Player").size() != 0:
		var i = cloud.instantiate()
		i.position.y = get_tree().get_nodes_in_group("Player")[0].global_position.y + randi_range(400,-300)
		i.position.x = get_tree().get_nodes_in_group("Player")[0].global_position.x - 800
		add_child(i)
