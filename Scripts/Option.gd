extends Panel

var mouseOver = false
var hairStyle:String

signal Select

func _gui_input(event):
	if mouseOver and event is InputEventMouseButton:
		if event.button_index== 1:
			emit_signal("Select",hairStyle)


func _on_mouse_entered():
	mouseOver = true


func _on_mouse_exited():
	mouseOver = false
