extends Panel

@onready var option = preload("res://Scenes/Option.tscn")
@onready var preview = get_node("../PlayerPre")
var selection:String

#Looks
@export var hair:String

#Colors
@export var hairCol:Color
@export var skinCol:Color
@export var eyeCol:Color
@export var clothesCol:Color
@export var accentCol:Color
@export var pantsCol:Color
@export var shoesCol:Color


func _ready():
	var dir = DirAccess
	
	var styles = dir.get_files_at("res://Sprites/Player/")
	
	for i in styles:
		if i.ends_with(".import") and i.begins_with("Player_Hair_"):
			var optionInst = option.instantiate()
			optionInst.get_node("Hair").add_to_group("Hair")
			optionInst.get_node("Head").add_to_group("Skin")
			optionInst.get_node("Pupil").add_to_group("Eye")
			optionInst.get_node("Hair").texture = load("res://Sprites/Player/"+i.replace(".import",""))
			optionInst.hairStyle = "res://Sprites/Player/"+i.replace(".import","")
			$ScrollContainer/GridContainer.add_child(optionInst)
			optionInst.connect("Select",Select)
	
	var skin = Saver._load("Player")
	if skin != null:
		var sprite = load(skin.hair)
		preview.get_node("Hair").texture = sprite
		hair = skin.hair
		for i in get_tree().get_nodes_in_group("Hair"):
			i.modulate = skin.hairCol
		for i in get_tree().get_nodes_in_group("Skin"):
			i.modulate = skin.skinCol
		for i in get_tree().get_nodes_in_group("Eye"):
			i.modulate = skin.eyeCol
		for i in get_tree().get_nodes_in_group("Clothes"):
			i.modulate = skin.clothesCol
		for i in get_tree().get_nodes_in_group("Accent"):
			i.modulate = skin.accentCol
		for i in get_tree().get_nodes_in_group("Legs"):
			i.modulate = skin.pantsCol
		for i in get_tree().get_nodes_in_group("Shoes"):
			i.modulate = skin.shoesCol
	
	get_node("../AnimationPlayer").play("Title")
func Select(style):
	selection = style
	hair = style
	Refresh()

func Refresh():
	preview.get_node("Hair").texture = load(selection)


func _on_color_picker_button_color_changed(color):
	var group = get_tree().get_nodes_in_group("Hair")
	hairCol = color
	for i in group:
		i.modulate = color


func _on_skin_color_color_changed(color):
	var group = get_tree().get_nodes_in_group("Skin")
	skinCol = color
	for i in group:
		i.modulate = color


func _on_eye_color_color_changed(color):
	var group = get_tree().get_nodes_in_group("Eye")
	eyeCol = color
	for i in group:
		i.modulate = color


func _on_clothes_color_color_changed(color):
	var group = get_tree().get_nodes_in_group("Clothes")
	clothesCol = color
	for i in group:
		i.modulate = color


func _on_accent_color_color_changed(color):
	var group = get_tree().get_nodes_in_group("Accent")
	accentCol = color
	for i in group:
		i.modulate = color


func _on_pants_color_color_changed(color):
	var group = get_tree().get_nodes_in_group("Legs")
	pantsCol = color
	for i in group:
		i.modulate = color


func _on_shoes_color_color_changed(color):
	var group = get_tree().get_nodes_in_group("Shoes")
	shoesCol = color
	for i in group:
		i.modulate = color

func _on_button_pressed():
	var save = load("res://Scripts/Saving/PlayerSaver.gd")
	save = save.new()
	save.hair = hair
	save.hairCol = get_tree().get_nodes_in_group("Hair")[0].modulate
	save.skinCol = get_tree().get_nodes_in_group("Skin")[0].modulate
	save.eyeCol = get_tree().get_nodes_in_group("Eye")[0].modulate
	save.clothesCol = get_tree().get_nodes_in_group("Clothes")[0].modulate
	save.accentCol = get_tree().get_nodes_in_group("Accent")[0].modulate
	save.pantsCol = get_tree().get_nodes_in_group("Legs")[0].modulate
	save.shoesCol = get_tree().get_nodes_in_group("Shoes")[0].modulate
	
	Saver._save("Player",save)
	if get_node("../Name").text != "":
		Global.Name = get_node("../Name").text
	Global.load = get_node("../Load").button_pressed
	get_tree().change_scene_to_file("res://Generation.tscn")
	


func _on_host_pressed():
	Multiplayer.host = true
	Multiplayer.multi = true
	_on_button_pressed()


func _on_join_pressed():
	Multiplayer._address(get_node("../Address").text)
	Multiplayer.multi = true
	_on_button_pressed()
