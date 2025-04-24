extends Control
class_name Inventory

@export var current_select = 1
@onready var box_cursor = $"Hotbar/Box1/Box Cursor"
@onready var inventory_screen = $InventoryScreen
@export var hotbar_nodes : Array[TextureButton]
@export var backpack_nodes : Array[TextureButton]
var relative_hotbar = "Hotbar/" # Relatvie path to access hotbar cursor
var swap_slot = null
var full = false
var inventory : inventory_data
func _ready():
	#print("inventory", get_multiplayer_authority())
	(get_node(relative_hotbar + "Box"+str(current_select))).disabled = true
	for i in range(2,5):
		(get_node(relative_hotbar + "Box"+str(i))).disabled = false
	box_cursor.visible = false
	pass

func _process(delta):
	pass
	
func _input(event):
	(get_node(relative_hotbar + "Box"+str(current_select))).disabled = false
	if event.is_action_pressed("slot1"): current_select = 1
	if event.is_action_pressed("slot2"): current_select = 2
	if event.is_action_pressed("slot3"): current_select = 3
	if event.is_action_pressed("slot4"): current_select = 4
	#box_cursor.reparent(get_node(relative_hotbar + "Box"+str(current_select)),false)
	var t :TextureButton = (get_node(relative_hotbar + "Box"+str(current_select)))
	t.disabled = true
	if event.is_action_pressed("Inventory"): $InventoryScreen.visible = !$InventoryScreen.visible
	#if event.is_action_pressed("debug"): 
		#$"%Box1".sprite.visible = !$"%Box1".sprite.visible
		#print($"%Box1".item.name)

func swap_item(node_box):
	if(not swap_slot): #selected 1
		swap_slot = node_box
	else: #selected a 2nd one
		var temp = node_box.item
		node_box.item = swap_slot.item
		swap_slot.item = temp
		print('Swapped', node_box.item, "And", swap_slot.item)
		node_box.set_pressed(false)
		swap_slot.set_pressed(false)
		#swap_slot = null
	print(swap_slot)
@rpc("any_peer", "call_local", 'reliable')
func pickup_item(item_dict: Dictionary, place: String, index: int):
	print("Registering item pickup on client")
	get_node("%" + place.capitalize()).get_child(index).add_item(item_dict)
@rpc("any_peer", "call_remote", "reliable")
func drop_item():
	pass
