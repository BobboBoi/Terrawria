extends CharacterBody2D
class_name Player

@onready var world : World = get_tree().get_first_node_in_group("World")
@onready var chat = get_tree().get_first_node_in_group("Chat")
@onready var sprite : PlayerSprite = %Sprite
@onready var animation := %PlayerAnimation
@onready var swingAnimation := %SwingAnimation
@onready var inventory := $Ui/Inventory
@onready var cam := %Camera

@export var speed : float = 200.0
@export var Name = "nan"

const jumpPower = -400.0

var itemCooldown := 0

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
	GameTime.Add(TickUpdate)
	if is_multiplayer_authority():
		var skin = Saver._load("Player")
		if skin != null: sprite.SetSkin(skin)
		
		$Ui/Inventory/Crafting.refresh()
		Name = Global.Name
		cam.enabled = true
		
		if !world.worldLoaded:
			set_physics_process(false)
			set_process(false)
			world.DoneGenerating.connect(Activate,CONNECT_ONE_SHOT)
		else:
			visible = true

func _unhandled_input(event: InputEvent) -> void:
	for i in range(1,6):
		if event.is_action_pressed("Hot"+str(i)):
			HotbarSwap(i)
			get_window().set_input_as_handled()
			return

func TickUpdate() -> void:
	if itemCooldown > 0:
		itemCooldown -= 1

func _process(_delta: float) -> void:
	if itemCooldown <= 0:
		swingAnimation.current_animation = animation.current_animation
		swingAnimation.seek(animation.current_animation_position)

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
				animation.speed_scale = 2*velocity.x/speed*direction
				
				velocity.x = lerp(velocity.x, direction * speed,0.05)
				$Sprite.scale.x = direction
				TryStep(direction)
			else:
				animation.play("Idle")
				animation.speed_scale = 2*velocity.x/speed*direction
				velocity.x = move_toward(velocity.x, 0, speed)
			
			if !is_on_floor():
				animation.play("Air")
			
			if Input.is_action_just_pressed("Inventory"):
				inventory.ToggleVisible()
			
			#Swap Inventory
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
			
			if Input.is_action_pressed("ZoomIn") and cam.zoom.x < 2:
				cam.zoom = Vector2(cam.zoom.x+0.01,cam.zoom.y+0.01)
			elif Input.is_action_pressed("ZoomOut") and cam.zoom.x > 1:
				cam.zoom = Vector2(cam.zoom.x-0.01,cam.zoom.y-0.01)
	
	if Input.is_action_just_pressed("Chat"):
		if $Ui/Chat.visible:
			Chat($Ui/Chat/Input.text)
		if !$Ui/Chat.visible:
			$Ui/Chat/Input.grab_focus()
		$Ui/Chat.visible = !$Ui/Chat.visible
	
	move_and_slide()

func Activate():
	visible = true
	set_physics_process(true)
	set_process(true)

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
	if usedItem == null: return
	if itemCooldown > 0: return
	
	if usedItem.get_child_count() > 1:
		var itemScript = usedItem.get_node("Script")
		itemScript.Use(self)
		itemCooldown = itemScript.useTime
		swingAnimation.play("Swing", -1, float(GameTime.GAME_TICKS)/itemScript.useTime)

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
