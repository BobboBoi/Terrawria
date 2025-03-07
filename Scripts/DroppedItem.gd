extends CharacterBody2D
class_name DroppedItem

var target : Player = null
@onready var item = $Item

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var maxFallSpeed = 400
var exiting = false

func _physics_process(_delta):
	if target != null:
		velocity = self.global_position.direction_to(target.global_position) * 200
	
	elif !is_on_floor() and velocity.y < maxFallSpeed:
		velocity.y += gravity
	
	elif is_on_floor() and velocity.y != 0:
		velocity.y = 0
	
	move_and_slide()

func collect(newTarget : Player):
	target = newTarget

func SetData(id,stack,itemScript = ""):
	item.itemId = id
	item.stack = stack
	item.itemScript = itemScript

func SetTexture(texture : String):
	var loaded = load(texture)
	if loaded == null: return
	item.texture = loaded

func _on_player_contact_body_entered(body):
	if exiting: return
	if body == target: #TODO This can be improved so that it doesn't load the script when it stacks
		item.get_node("Label").visible = true
		
		var newScript = Node.new()
		newScript.name = "Script"
		newScript.set_script(load(item.itemScript))
		item.add_child(newScript)
		
		body.inventory.addItem(item.duplicate())
		queue_free()
	
	elif body is DroppedItem and body != self:
		if body.item.itemId == item.itemId:
			item.stack += body.item.stack
			body.Exiting()
			body.queue_free()

func setItem(itemID : int, tileID : int = -1):
	get_child(0).itemID = itemID
	get_child(0).tileID = tileID

func Exiting() -> void:
	exiting = true
