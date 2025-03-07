extends CharacterBody2D
class_name Player

@onready var world : World = get_tree().get_first_node_in_group("World")
@onready var chat = get_tree().get_first_node_in_group("Chat")
@onready var animation := $AnimationPlayer
@onready var inventory := $Ui/Inventory
@onready var cam := $Camera2D

@export var speed : float = 200.0
@export var Name = "nan"

const jumpPower = -400.0

var usable = true
var inventoryInter := false
var item = 1
var currentItem : InventoryItem = null

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var maxFallSpeed = 400

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())
	if not is_multiplayer_authority():
		$Ui.queue_free()

func _ready():
	visible = false
	if is_multiplayer_authority():
		var skin = Saver._load("Player")
		if skin != null: SetSkin(skin)
		
		$Ui/Inventory/Crafting.refresh()
		Name = Global.Name
		cam.enabled = true
		
		if !world.done:
			set_physics_process(false)
			set_process(false)
			world.DoneGenerating.connect(Activate,CONNECT_ONE_SHOT)
		else:
			visible = true

func Activate():
	visible = true
	set_physics_process(true)
	set_process(true)

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	if not is_on_floor() and velocity.y < maxFallSpeed:
		velocity.y += gravity * delta
	
	$Label.text = "X"+str(roundi(global_position.x/8))+"-Y"+str(roundi(global_position.y/8))
	
	if !$Ui/Chat.visible:
			$Label.text = str(Vector2(roundi((global_position.x-8)/16),roundi((global_position.y-8)/16)))
			if Input.is_action_just_pressed("jump") and is_on_floor():
				velocity.y = jumpPower

			var direction = Input.get_axis("left", "right")
			if direction:
				animation.play("Walk")
				$AnimationPlayer.speed_scale = 2*velocity.x/speed*direction
				velocity.x = lerp(velocity.x, direction * speed,0.05)
				$Sprite.scale.x = direction
				TryStep(direction)
			else:
				animation.play("Idle")
				$AnimationPlayer.speed_scale = 2*velocity.x/speed*direction
				velocity.x = move_toward(velocity.x, 0, speed)
			
			if !is_on_floor():
				$AnimationPlayer.play("Air")
			
			
			if Input.is_action_just_pressed("Inventory"):
				$Ui/Inventory/Inventory.visible = !$Ui/Inventory/Inventory.visible
				$Ui/Inventory/Crafting.visible = !$Ui/Inventory/Crafting.visible
			#Swap Inventory
			if Input.is_action_just_pressed("Hot1"):
				HotbarSwap(1)
			elif Input.is_action_just_pressed("Hot2"):
				HotbarSwap(2)
			elif Input.is_action_just_pressed("Hot3"):
				HotbarSwap(3)
			elif Input.is_action_just_pressed("Hot4"):
				HotbarSwap(4)
			elif Input.is_action_just_pressed("Hot5"):
				HotbarSwap(5)
			
			
			if Input.is_action_just_pressed("Use"):
				if inventory.hoveredPanel != null: # block item usage if inventory is used
					inventoryInter = true
				
				if inventoryInter and currentItem == null: #Test if there really isn't a current Item
					HotbarSwap(item)
			elif  Input.is_action_just_released("Use") and inventoryInter:
				inventoryInter = false
			
			if !inventoryInter:
				if Input.is_action_pressed("Use") and usable and inventory.hoveredPanel == null:
						Use(currentItem)
			
			if Input.is_action_pressed("ZoomIn") and $Camera2D.zoom.x < 2:
				$Camera2D.zoom = Vector2($Camera2D.zoom.x+0.01,$Camera2D.zoom.y+0.01)
			elif Input.is_action_pressed("ZoomOut") and $Camera2D.zoom.x > 1:
				$Camera2D.zoom = Vector2($Camera2D.zoom.x-0.01,$Camera2D.zoom.y-0.01)

	if Input.is_action_just_pressed("Chat"):
		if $Ui/Chat.visible:
			Chat($Ui/Chat/Input.text)
		if !$Ui/Chat.visible:
			$Ui/Chat/Input.grab_focus()
		$Ui/Chat.visible = !$Ui/Chat.visible
	
	move_and_slide()

func HotbarSwap(index : int):
	if inventory.heldItem != null: return
	item = index
	currentItem = get_node("Ui/Inventory/Hotbar/Panel"+str(item)).GetItem()
	$Ui/Inventory/Selection.position.x = item*50-50

func TryStep(direction : int):
	if roundi((global_position.x-8+direction*16)/16) == roundi((global_position.x-8)/16)+direction and is_on_floor():
		if world.get_cell_source_id(0,Vector2(roundi((global_position.x-8)/16)+direction,roundi((global_position.y+26-8)/16)-1)) != -1:
			var data = world.get_cell_tile_data(0,Vector2(roundi((global_position.x-8)/16)+direction,roundi((global_position.y+26-8)/16)-1))
			if data != null:
				if data.get_custom_data("Type") == "Tile":
					data = world.get_cell_tile_data(0,Vector2(roundi((global_position.x-8)/16)+direction,roundi((global_position.y+26-8)/16)-2))
					if data != null:
						if data.get_custom_data("Type") != "Tile":
							position.y -= 16
							if !(velocity.x > 25 and velocity.x < -25):
								position.x += direction*4
					elif world.get_cell_source_id(0,Vector2(roundi((global_position.x-8)/16)+direction,roundi((global_position.y+26-8)/16)-2)) == -1:
						position.y -= 16
						if !(velocity.x > 25 and velocity.x < -25):
							position.x += direction*4

func Use(usedItem):
	if usedItem != null:
		if usedItem.get_child_count() > 1:
			var itemScript = usedItem.get_node("Script")
			itemScript.Use(self)

func Chat(new_text : String) -> void:
	if Multiplayer.multi:
		var function:Array = [Name,new_text]
		if !Multiplayer.host:
			function.append(false)
		
		for i in Multiplayer.players:
			multiplayer.rpc(i,chat,"Chat",function)
	else:
		chat.Chat(Name,new_text)
	$Ui/Chat/Input.text = ""

func _on_collection_field_body_entered(body):
	if body is DroppedItem:
		if body.target == null:
			body.collect(self)

func SetSkin(skin):
	if skin == null: return
	
	var hairAnim = $Sprite/Hair.get("sprite_frames")
	var sprite = load(skin.hair)
	var height = sprite.get_height()/56
	
	for i in range(height):
		var atlas = AtlasTexture.new()
		atlas.atlas = sprite
		atlas.region = Rect2(0,0,40,56)
		hairAnim.add_frame("default",atlas)
	
	$Sprite/Hair.modulate = skin.hairCol
	$Sprite/Head.modulate = skin.skinCol
	$Sprite/HandF.modulate = skin.skinCol
	$Sprite/HandB.modulate = skin.skinCol
	$Sprite/Pupil.modulate = skin.eyeCol
	$Sprite/Body.modulate = skin.clothesCol
	$Sprite/ArmF.modulate = skin.accentCol
	$Sprite/ArmB.modulate = skin.accentCol
	$Sprite/Legs.modulate = skin.pantsCol
	$Sprite/Shoes.modulate = skin.shoesCol
