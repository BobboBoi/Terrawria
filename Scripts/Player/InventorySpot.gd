extends Node

var hover = false

func SwapItem(heldItem):
	var item = null
	
	if get_child_count() != 0:
		item = get_child(0)
	
	if item != null and heldItem != null:
		if item.itemId == heldItem.itemId:
			item.stack += heldItem.stack
			heldItem.queue_free()
			heldItem = null
			
			return null
	
	if item != null:
		item = item.duplicate()
		get_child(0).queue_free()
	
	if heldItem != null:
		add_child(heldItem)
		heldItem.position = Vector2(0,0)
	
	return item

func GetItem():
	var item = null
	if get_child_count() != 0:
		item = get_child(0)
	return item

func _on_mouse_entered():
	hover = true
	get_node("../../../../").usable = false
	self.modulate = Color(0.5,0.5,0.5)

func _on_mouse_exited():
	hover = false
	get_node("../../../../").usable = true
	self.modulate = Color(1,1,1)
