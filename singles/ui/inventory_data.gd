extends Resource
class_name inventory_data

@export var hotbar_size : int = 4
var hotbar : Array[item_template_res]
@export var backpack_size : int = 3
@export var backpack_max_size : int = 9 
var backpack : Array[item_template_res]
var location : Dictionary = {"hotbar" : hotbar, "backpack": backpack}
func _init():
	for i in range(hotbar_size):
		hotbar.append(null)
	for i in range(backpack_size):
		backpack.append(null)
func find_next_empty():
	for i in range(len(hotbar)):
		if not hotbar[i]:
			return [i, "hotbar"] # Retruning strings to interact with dispay inventory
	for i in range(len(backpack)):
		if not backpack[i]:
			return [i, "backpack"]
	return [false]
func find_next_matching(item:item_template_res):
	for i in range(len(hotbar)):
		if hotbar[i] and hotbar[i].name == item.name and  hotbar[i].stack <  hotbar[i].stack_limit:
			return [i, "hotbar"]
	for i in range(len(backpack)):
		if backpack[i] and backpack[i].name == item.name:
			return [i, "backpack"]
	return [null, null]
func pickup_item(item: item_template_res,  multiplayer_id):
	print_debug(multiplayer_id, item)
	if item.stack_limit > 1:
		var res = find_next_matching(item)
		if res[0] != null: # Found matching, do rest of logic
			var t :item_template_res = location[res[1]][res[0]]
			t.stack += item.stack # cull down to stack_limit
			if t.stack > t.stack_limit:
				var extra = t.duplicate()
				extra.stack = t.stack - t.stack_limit
				t.stack = t.stack_limit
				# Match to inventory display
				location[res[1]][res[0]] = t
				UILayer.Inventory.pickup_item.rpc_id(multiplayer_id,t.to_dict(), res[1], res[0])
				return pickup_item(item, multiplayer_id)
			return false # false ala no extra
		else: # No matching, find an empty slot to fill
			res = find_next_empty()
			#print(res)
			if res[0] != null:
				#print(location[res[1]])
				#print(location[res[1]][res[0]])
				location[res[1]][res[0]] = item
				UILayer.Inventory.pickup_item.rpc_id(multiplayer_id, item.to_dict(), res[1], res[0])
				return false
			return item # return item to fill into drop_item scene
	else:
		var res = find_next_empty()
		if res[0] != null:
			location[res[1]][res[0]] = item
			return false
		return item
func drop_item():
	pass
