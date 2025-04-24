extends TextureButton
class_name Slot
var item : Dictionary
@onready var sprite : Sprite2D = $Sprite2D
@onready var text : Label  = $RichTextLabel
#var item = Item("Test")
func _ready():
	#sprite = $Sprite2D
	# edge case if item is already in slot for osmre reason.
	if item:
		add_item(item)
	else:
		#pass
		sprite.visible = false
		text.visible = false
	pass
func _process(delta):
	pass
	
#@rpc("call_local", "reliable")
func add_item(new_item_dict: Dictionary):
	
	item = new_item_dict
	sprite.texture=load(item['sprite_path'])
	sprite.visible = true
	if item['stack_limit'] > 1:
		text.visible = true
		text.text = str(item['stack'])
	else:
		text.visible = false
	#sprite.update()
#@rpc("call_local", "reliable")
func remove_item():
	var pop = item.duplicate()
	item = {}
	sprite.visible = false
	#return pop # repalce with rpc return later
	
func _toggled(toggled):
	if(toggled):
		if(not UILayer.get_node("%Inventory").swap_slot):
			UILayer.get_node("%Inventory").swap_slot = self
		else:
			var temp = item
			item = UILayer.get_node("%Inventory").swap_slot.item
			UILayer.get_node("%Inventory").swap_slot.item = temp
			print('Swapped', item, "And", UILayer.get_node("%Inventory").swap_slot.item)
			UILayer.get_node("%Inventory").swap_slot.set_pressed(false)
			self.set_pressed(false)
			UILayer.get_node("%Inventory").swap_slot = null
	else:
		UILayer.get_node("%Inventory").swap_slot = null
	


func _on_area_2d_input_event(viewport, event, shape_idx):
	pass # Replace with function body.
