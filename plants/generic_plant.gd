extends Node
class_name  GenericPlant
@export var time_per_stage = 15
@export var n_stages = 4
@export var crop  : Node
@export var origin_tilemap_cords :Vector2
var current_stage = 0
signal growth_trigger
func _init():
	pass
# Called when the node enters the scene tree for the first time.
func _ready():
	growth_trigger.connect(_on_grow)
	set_process(false) # dont need to run process for right now...
	await get_tree().create_timer(time_per_stage).timeout
	_on_grow()
	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_grow():
	current_stage += 1
	if current_stage < n_stages:
		# Any processing 
		await get_tree().create_timer(time_per_stage).timeout
func _on_harvest():
	pass
