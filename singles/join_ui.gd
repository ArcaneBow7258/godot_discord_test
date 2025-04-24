extends CanvasLayer
func _ready():
	# Wrapper for singletons
	var t : Button =  $VBoxContainer/Host
	t.pressed.connect(MultiplayerMain.create_game)
	t = $VBoxContainer/Join
	t.pressed.connect(MultiplayerMain.join_game)
	$"/root/UILayer".visible = false
	
