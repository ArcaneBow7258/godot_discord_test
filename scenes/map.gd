extends TileMapLayer

	#print(basemap.get_cell_atlas_coords((Vector2i(33,77))))
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