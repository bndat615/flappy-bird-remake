extends Sprite2D

func _ready():
	GameState.is_night = randi() % 2 == 0
	
	var chosen = "background-night" if GameState.is_night else "background-day"
	texture = load("res://assets/sprites/%s.png" % chosen)
