extends Resource
class_name item_template_res

@export var name : String # needed a backened name too... i guess it bets the sprietFrames
@export var display_name : String
@export var stack_limit : int
@export var stack : int
@export var sprite_path : Texture2D
@export var placeable : bool
@export var type : Enum.item_type
@export var strength : int

func to_dict():
	return {'name' : name,
			'display_name': display_name,
			'stack_limit':stack_limit,
			"stack":stack,
			"sprite_path":sprite_path.resource_path,
			"placeable":placeable,
			"type":type,
			"strength":strength}

func from_dict(data_dict:Dictionary):
	name = data_dict['name']
	display_name = data_dict['display_name']
	stack_limit = data_dict['stack_limit']
	stack = data_dict['stack']
	sprite_path = load(data_dict['sprite_path'])
	placeable = data_dict['placeable']
	type = data_dict['type']
	strength = data_dict['strength']
	return self
