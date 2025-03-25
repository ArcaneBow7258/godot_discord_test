extends Node2D
class_name  GenericPlant
@export var plant_data : crop_template_res
@export var anim : AnimationPlayer
var current_stage = 0
signal growth_trigger
func _init():
	pass
# Called when the node enters the scene tree for the first time.
func _ready():
	anim = %AnimationPlayer
	anim.play(plant_data.name + "/growing" )
	anim.speed_scale
	anim.animation_finished.connect(_itemize)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
func _itemize():
	anim.play(plant_data.name + "/item" )
	anim.speed_scale = 0.35
func _on_grow():
	current_stage += 1
	if current_stage < plant_data.n_stages:
		# Any processing 
		await get_tree().create_timer(plant_data.time_per_stage).timeout
func _on_harvest():
	pass
