extends Node2D

@export var width = 64;
@export var height = 64;
@export var percent_fill = 0.2;
@export var smooths = 1
@export var seed = 0;
@export var random_seed = false;
@export var draw_size = 4
@export var basemap : TileMapLayer
@export var cropmap : TileMapLayer
@export var debug = false;
@export var noise : NoiseTexture2D
@export var use_noise = true
var map = []
var map_invert = []

func _ready():
	noise.width = width
	noise.height = height
	noise.noise.seed =  seed
	pass
	
func make_map():
	
	if multiplayer.is_server():
		print('Making map')
		generate_map()
		#map_invert = map.map(func(x): return (x + 1) % 2)
		make_tiles.rpc_id(1, map)
func generate_map():
	
	fill()
	smooth()
	if not use_noise:
		for s in smooths:
			smooth()
func generate_noise():
	pass

# Create map for server
# Will be sent to users
func fill():
	var rng = RandomNumberGenerator.new()
	if use_noise:
		for y in height:
			for x in width:
				map.append(noise.noise.get_noise_2d(x, y))
				#print(noise.noise.get_noise_2d(x, y))
		var min = map.min()
		var max = map.max()
		var map_range = max - min
		for y in height:
			for x in width:
				var normal = (map[x + y*width] - min) / map_range
				#print(normal)
				map[x + y*width] = 1 if normal > 0.4 else 0
				
		print('size of map', len(map))
	else:
		if(!random_seed): rng.seed = seed
		for x in width:
			for y in height:
				if(x == 0 || x == width - 1 || y == 0 || y == height - 1):
					map.append(1)
					continue
				map.append(1 if rng.randf() < percent_fill else 0)
			
			
func smooth():
	for x in width:
		for y in height:
			var walls = get_surrounding(x, y)
			if(walls > 4):
				map[x + y*width] = 1
			elif (walls <= 4):
				map[x + y*width] = 0

func get_surrounding(x, y):
	var walls = 0
	for xl in range (x-1, x+2):
		for yl in range (y-1, y+2):
			if(xl >= 0 && xl < width && yl >= 0 && yl < height): 
				#if(xl != x || yl != y):
					walls += map[xl + yl*height]
			else: 
				walls += 1
	return walls
	
func _draw():
	if debug:
		for x in width:
			for y in height:
				var cell = map[x + y*width]
				var col =  Color.BLACK
				if(cell == 0):
					col = Color.WHITE
				draw_rect(Rect2(x * draw_size, y * draw_size,draw_size, draw_size),col, true)
@rpc("authority", "call_local","reliable")
func make_tiles(cells):
	print("make_tiles: ", map.max(), '',map.min())
	var map_fill = []
	var map_empty = []
	print(cells[0])
	for x in width:
		for y in height:
			if(cells[x + y*width] == 1):
				map_fill.append(Vector2i(x,y))
			else:
				map_empty.append(Vector2i(x,y))
	#print(map_fill)
	basemap.set_cells_terrain_connect(map_fill,0,0, false)
	#print(basemap.get_cell_atlas_coords((Vector2i(33,77))))
	#set_cells_terrain_connect(2,map_invert,0,2, false)
@rpc("authority", "call_local","reliable")
func make_crops(cells, cords):
	#print("Updating crops from server:")
	#print(cells)
	#print(cords)
	
	for i in range(len(cells)):
		
		cropmap.set_cell(cells[i], 0, cords[i])
	
@rpc('any_peer', 'call_local')
func think_about(target: Vector2i, atlas_cords = Vector2i(0,0), clear = false):
	#var target = cropmap.local_toM(mousePos) 
	#print(cropmap.get_cell_atlas_coords(target))
	if cropmap.get_cell_atlas_coords(target) == Vector2i(-1,-1) and not clear:
			%ThinkMap.set_cell(target, 0, atlas_cords)
			#print(target)
	elif clear:
			%ThinkMap.erase_cell(target)
