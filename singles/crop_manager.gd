extends TileMapLayer

var plants :  Array[GenericPlant]
# Called when the node enters the scene tree for the first time.
func _ready():
	if !multiplayer.is_server():
		return
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _test():
	_add_plant(Vector2i(1,1))
	
	
func _add_plant(cords: Vector2i):
	var p = GenericPlant.new()
	plants.append(p)
	set_cell(cords, p.origin_tilemap_cords + (Vector2i(p.current_stage, 0)))
