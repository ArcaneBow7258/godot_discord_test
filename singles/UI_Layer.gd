extends CanvasLayer
class_name	inventory_manager
# God fucking damn it i need to remake inventories.
@onready var Inventory  : Inventory = %Inventory
#var local_inventory : Control
var managed_inventories : Dictionary = {}
@onready var inventory_template_view = preload("res://singles/ui/Inventory.tscn")
@onready var inventory_data_template = preload("res://singles/ui/inventory_resource.tres")
func _ready():
	
	pass	
# Create Inventory for server to manage
@rpc("authority", "call_local","reliable")
func add_inventory(multiplayer_id: int):
	print("Adding inventory for m_id ", multiplayer_id)
	var new_inv = inventory_data_template.duplicate()
	# load info probably goes here when save states exist for this game.
	managed_inventories[multiplayer_id] = new_inv
@rpc('authority',"call_local", "reliable")
func add_item(multiplayer_id: int, item_drop : RigidBody2D, item_dict:Dictionary):
	#print_debug("Pickup")
	#print_debug(item_dict)
	var item : item_template_res = item_template_res.new().from_dict(item_dict)
	print_debug(item)
	#print("Pickup")
	var remain = managed_inventories[multiplayer_id].pickup_item(item, multiplayer_id)	
	if remain: # logic should return false if item is consumed and placed into a slot
		item_drop.item =  remain
		item_drop.rpc("sync_texture")
		#print("Remain")
	else: # consumed, ala false
		if item_drop:
			item_drop.rpc("delete_drop")
	
		
# Allow players to send messages on what their inventory actions are?
# Also directs changes to said inventroy?
@rpc("authority", "call_local","reliable")
func change_auth(id: int):
	print("Changed inventory auth to ", id)
	Inventory.set_multiplayer_authority(id)
