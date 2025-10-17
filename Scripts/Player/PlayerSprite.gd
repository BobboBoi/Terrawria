extends Node2D
class_name PlayerSprite

@onready var handFront : AnimatedSprite2D = %HandF
@onready var handBack : AnimatedSprite2D = %HandB
@onready var armFront : AnimatedSprite2D = %ArmF
@onready var armBack : AnimatedSprite2D = %ArmB
@onready var hair : AnimatedSprite2D = %Hair
@onready var head : AnimatedSprite2D = %Head
@onready var pupil : AnimatedSprite2D = %Pupil
@onready var eye : AnimatedSprite2D = %Eye
@onready var body : AnimatedSprite2D = %Body
@onready var legs : AnimatedSprite2D = %Legs
@onready var shoes : AnimatedSprite2D = %Shoes

func SetSkin(skin):
	if skin == null: return
	
	var hairAnim = hair.get("sprite_frames")
	var sprite = load(skin.hair)
	var height = sprite.get_height()/56
	
	for i in range(height):
		var atlas = AtlasTexture.new()
		atlas.atlas = sprite
		atlas.region = Rect2(0,0,40,56)
		hairAnim.add_frame("default",atlas)
	
	armFront.modulate = skin.accentCol
	armBack.modulate = skin.accentCol
	handFront.modulate = skin.skinCol
	handBack.modulate = skin.skinCol
	hair.modulate = skin.hairCol
	head.modulate = skin.skinCol
	pupil.modulate = skin.eyeCol
	body.modulate = skin.clothesCol
	legs.modulate = skin.pantsCol
	shoes.modulate = skin.shoesCol
