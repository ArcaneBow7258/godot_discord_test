extends CharacterBody2D

@onready  var  camera : Camera2D = $Camera 
@export var SPEED = 5.0
@onready var sprite = $Sprite
@onready var follower_mouse = $Follower_mouse
var animation_string = "down_s"
var placeable_select = true
var target_tile : Vector2i
@export var display_name : String
const JUMP_VELOCITY = -400.0
func _ready():
	#sprint("player", get_multiplayer_authority() , multiplayer.get_unique_id(), get_multiplayer_authority() == multiplayer.get_unique_id())
	set_multiplayer_authority(name.to_int())
	#print('Chacter ', name, ' in session ',  multiplayer.get_unique_id())
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	set_physics_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	# Only server moves items (gravity) and adds to inverntory
	$BarManager.set_multiplayer_authority(1)
	if !multiplayer.is_server():
		$Area_Attract.queue_free()
		$Area_Pickup.queue_free()
	#else:
	
	#$"BarManager/nametag".text = display_name 
	#print("=========================")
	#print("Ready player for: " + str(multiplayer.get_unique_id()))
	#print(name)
	#print("auth set to: " + str(get_multiplayer_authority()))
	#print($MultiplayerSynchronizer.get_multiplayer_authority())
	#print("=========================")
	
	if not is_multiplayer_authority(): return
	
	#camera.current = true
	
	camera.make_current()
	$"/root/UILayer".visible = true
#func _enter_tree():
	#set_multiplayer_authority(str(name).to_int())
@rpc("call_local", "any_peer")
func sync_data(disp_name: String):
	display_name = disp_name 
	#print('dd', multiplayer.get_unique_id(),'-', display_name)
	$"BarManager/nametag".text = display_name 
func _physics_process(delta):
	#if not is_multiplayer_authority(): return
	animation_string = move_mouse() +  move_wasd(delta)
	sprite.animation = animation_string
	move_and_slide()
	
			
		#print(i.name)
		#if(collider):
			##UILayer.Inventory.add_item("Test")
			##collider.queue_free()
			#UILayer.rpc_id(get_multiplayer_authority(), "pickup_item", collider.item)
			#collider.free()
func _process(delta):
	#target_tile = TileMaps.cropmap.local_to_map(get_global_mouse_position())
	if target_tile != TileMaps.cropmap.local_to_map(get_global_mouse_position()) and placeable_select:
		TileMaps.think_about.rpc(target_tile, Vector2i(-1,-1), true)
		target_tile = TileMaps.cropmap.local_to_map(get_global_mouse_position())
		TileMaps.think_about.rpc(target_tile)

	#target_tile  = get_node(%TileMaps).thinkabout

func move_mouse():
	#if not is_multiplayer_authority(): return
	var mousePos = get_viewport().get_mouse_position()
	var middle: Vector2 = get_viewport().size / 2
	#Cooridnates start at top left, so we need to flip it, since up and left are negative, while down an right is positve:
	var mousePosNormalized = ((mousePos - middle) / middle).normalized()
#	#Clockwise starting  at (1, 0)
	camera.draw
	var angle = mousePosNormalized.angle() * 180 / PI
	follower_mouse.rotation_degrees = angle
	#print(angle)
	if(45 > angle and angle > -45):
		return "right"
	if(135 > angle and angle > 45):
		return "down"
	if(-45 > angle and angle > -135):
		return "up"
	return "left"
func move_wasd(delta):
	#if not is_multiplayer_authority(): return
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (Vector2(input_dir.x,input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.y = direction.y * SPEED
		return "_m"
		#$Pivot.look_at(position + direction, Vector3.UP)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
		return "_s"


func _on_area_attract_body_entered(body: RigidBody2D):
	#print(body)
	if body.is_in_group("item_drop"):
		body.checkSleep(true)
#func _on_area_pickup_body_entered(body: RigidBody2D):
	#if body.is_in_group("item_drop"):
		#body.sleeping = false
	pass # Replace with function body.


func _on_area_attract_body_exited(body_rid, body, body_shape_index, local_shape_index):
	#print(body)
	if body and body.is_in_group("item_drop"):
		
		body.checkSleep(false)



func _on_area_pickup_body_entered(body):
	if body and body.is_in_group("item_drop"):
		#print(body)
		#print(multiplayer.get_unique_id())
		#print(get_multiplayer_authority())
		#print()
		UILayer.add_item.rpc(get_multiplayer_authority(), body, body.item.to_dict())
		
	pass # Replace with function body.


func _on_area_pickup_body_exited(body):
	pass # Replace with function body.


#func _on_area_attract_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	#pass # Replace with function body.
