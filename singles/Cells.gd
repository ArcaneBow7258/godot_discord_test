extends TileMapLayer

@export var width = 64;
@export var height = 64;
@export var percent_fill = 0.2;
@export var smooths = 1
@export var seed = 0;
@export var random_seed = false;
@export var draw_size = 4
@export var debug = true;
var map = []
var map_invert = []

func _ready():
	pass
	
func make_map():
	
	if multiplayer.is_server():
		print('Making map')
		generate_map()
		#map_invert = map.map(func(x): return (x + 1) % 2)
		make_tiles.rpc(map)
func generate_map():
	random_fill()
	for s in smooths:
		smooth()
		
func random_fill():
	var rng = RandomNumberGenerator.new()
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
@rpc("authority", "call_local")
func make_tiles(cells):
	var map_fill = []
	var map_empty = []
	for x in width:
		for y in height:
			if(cells[x + y*width] == 1):
				map_fill.append(Vector2i(x,y))
			else:
				map_empty.append(Vector2i(x,y))
	#print(map_fill)
	set_cells_terrain_connect(map_fill,0,0, false)
	#set_cells_terrain_connect(2,map_invert,0,2, false)
	
	#
	### Making things look pretty
	#var tiles_ignore = [Vector2i(1,1), Vector2i(1,4)]
	#var test = get_navigation_map(3)
	##upper, genearte floor?
	#var tiles_used = []
	#for x in 4+1:
		#for y in 5+1:
			#if(Vector2i(x,y) in tiles_ignore): continue
			#tiles_used.append_array(get_used_cells_by_id(0, 0, Vector2i(x,y)))
	##print("Found tiles: ", len(tiles_used))
	#for cords in tiles_used:
		#set_cell(3, cords, 0, Vector2i(1,1), 1)
			##erase_cell(0, cords)
	#tiles_used = []
	##ground, generate water
	#for x in 4+1:
		#for y in 5+1:
			#if(Vector2i(x,y) in tiles_ignore): continue
			#tiles_used.append_array(get_used_cells_by_id(1, 0, Vector2i(x,y)))
			#
	#print("Found tiles: ", len(tiles_used))
	#for cords in tiles_used:
		#set_cell(3, cords, 1, Vector2i(1,0), 0)
			#erase_cell(0, cords)
