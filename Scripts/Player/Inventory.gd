extends Control

var panels:Array = []
var recipes:Array = []
##The item the player is currently holding
var heldItem = null
##The visual representation of heldItem
var heldVis = null

var hoveredPanel : 
	set(value):
		hoveredPanel = value
		$Label.text = str(value)

@onready var crafter := $Crafting
@onready var player := $"../../"

func _ready():
	for i in $Hotbar.get_children():
		panels.append(i)
	for i in $Inventory.get_children():
		panels.append(i)
	$Crafting.start()

##Update recipes in inventory to add them to the hover check
func refreshRecipes():
	recipes = []
	for i in $Crafting/Cont.get_children():
		recipes.append(i)

func _physics_process(_delta):
	if Input.is_action_just_pressed("Use"):
		for i in panels:
			if i.hover:
				if heldVis != null:
					heldVis.queue_free()
					heldItem = i.SwapItem(heldItem.duplicate())
					player.HotbarSwap(player.item)
					$Crafting.refresh()
				else:
					heldItem = i.SwapItem(heldItem)
					$Crafting.refresh()
					
				heldVis = heldItem
				HeldItemUpdate()
		
		for i in recipes:
			if i != null:
				if i.hover:
					if heldVis == null:
						heldItem = i.GetItem()
						
						var newScript = Node.new()
						newScript.name = "Script"
						newScript.set_script(load(heldItem.itemScript))
						heldItem.add_child(newScript)
						
						heldVis = heldItem
						HeldItemUpdate()
					
					elif heldVis.stack < 9999  and heldVis.itemId == i.get_child(0).itemId:
						heldItem.stack += i.GetItem().stack
						heldVis = heldItem
	
	if heldItem != null:
		heldItem.position = get_local_mouse_position()
	
	if !$Inventory.visible:
		for i in panels:
			i._on_mouse_exited()

func HeldItemUpdate():
	if heldVis != null:
		add_child(heldVis)
		player.currentItem = heldItem
		heldVis.set_deferred("size",Vector2(40,40))

func addItem(item : InventoryItem):
	var empty = null
	for i in panels:
		var panelItem = i.GetItem()
		
		if panelItem != null:
			if panelItem.itemId == item.itemId:
				item = i.SwapItem(item)
				empty = null
				break
		elif panelItem == null and empty == null:
			empty = i
	
	if empty != null:
		item = empty.SwapItem(item)
	
	crafter.refresh()
