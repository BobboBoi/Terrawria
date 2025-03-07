extends Label

@onready var world = get_tree().get_first_node_in_group("World")

@rpc("any_peer","call_local")
func Chat(player:String,message:String,com = true):
	if com and message.begins_with("/"):
		if message.begins_with("/noClip "):
			var tar = Target("noClip",message,player)
			if tar:
				tar.set_collision_layer_value(1,false)
				tar.set_collision_mask_value(1,false)
		elif message.begins_with("/clip "):
			var tar = Target("clip",message,player)
			if tar:
				tar.set_collision_layer_value(1,true)
				tar.set_collision_mask_value(1,true)
	else:
		text = player+": "+message+"\n"+text

func Target(command:String,full:String, player:String):
	for i in world.players:
		if full.begins_with("/"+command+" self"):
			var p = get_node("../../../"+str(i))
			if p.Name == player:
				return p
		
		elif full.begins_with("/"+command+" "+get_node("../../../"+str(i)).Name):
			return get_node("../../../"+str(i))
	
	return false
