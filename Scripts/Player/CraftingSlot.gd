extends Node

var hover = false
var ingredients : Array = []

@onready var inventory = $"../../.."
@onready var crafter = $"../.."

func GetItem():
	for i in ingredients:
		for j in inventory.panels:
			if j.get_child_count() != 0:
				var ci = j.get_child(0)
				
				if ci.itemId == i[0]:
					if ci.stack > 0:
						ci.stack -= i[1]
					else:
						j.SwapItem(null)
					break
	
	var item = null
	if get_child_count() != 0:
		item = get_child(0).duplicate()
	
	get_node("../../").setIngredients([])#empty current ingredients
	crafter.refresh()
	return item


func _on_mouse_entered():
	hover = true
	get_node("../../").setIngredients(ingredients)
	inventory.hoveredPanel = self
	self.modulate = Color(0.5,0.5,0.5)

func _on_mouse_exited():
	hover = false
	if inventory.hoveredPanel == self:
		inventory.hoveredPanel = null
	
	self.modulate = Color(1,1,1)
