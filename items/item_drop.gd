extends RigidBody2D
class_name ItemDrop
@export var item :  item_template_res
#@export var stack_size = 1
@onready var sprite : Sprite2D  = $Sprite2D
@onready var collider : CollisionShape2D = $CollisionShape2D
var bodies_pulling = 0
var amp = 5.0
var freq = 2
var time = 0
@rpc("authority", "call_local")
func sync_texture(sprite_name:String):
	#print('sync texture', sprite_name)
	#print("syc texture, ", multiplayer.get_unique_id())
	sprite.set_texture(load(sprite_name))
func _ready():
	# Let server handle collisions
	#print("item_drop", multiplayer.is_server())
	#set_process(multiplayer.is_server())
	#set_physics_process(multiplayer.is_server())
	#if item:
		#sprite.set_texture(item.sprite_path)
		#sprite.visible = true
	#if !multiplayer.is_server():
		#collider.disabled = true
	
	#print(item.stack_limit)
	#
	#if item.image_path != null:
		#sprite.texture = item.sprite_path
	#else:
		#print("Missing Image Path... get that fixed")
	pass
	
func _process(delta):
	time += delta * freq
	if time > freq * 3:
		time = 0
	sprite.position.y = (amp * sin(time))
	collider.position.y =  (amp * sin(time))
@rpc("authority", "call_local", "reliable")
func delete_drop():
	queue_free()
func _physics_process(delta):
	
	move_and_collide(linear_velocity * delta)
	#for collider : CollisionObject2D in get_colliding_bodies():
		#pass
		#if collider.is_in_group("player"):
			#print(collider)
			#print(collider.get_multiplayer_authority())
			#UILayer.Inventory.rpc_id(collider.get_multiplayer_authority(), "pickup_item", self, item)
		
		#var collision = get_slide_collision(i)
		#var collider = collision.get_collider()
		
	#print(sprite.position.y)
	
func checkSleep(status: bool):
	
	if status:
		bodies_pulling +=1
	else:
		bodies_pulling -=1
	if bodies_pulling > 0:
		sleeping = false
	else:
		sleeping = true
	#print(bodies_pulling)
func _on_body_entered(body):
	#print(body)
	pass
