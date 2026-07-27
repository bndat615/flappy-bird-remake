extends Area2D

const SPEED = 120.0
var is_moving = true

func _ready():
	setup_random_color()

func setup_random_color():
	var chosen: String
	if GameState.is_night:
		chosen = "pipe-red" if GameState.is_night else "pipe-green"
	else:
		chosen = "pipe-green"

	var texture = load("res://assets/sprites/%s.png" % chosen)
	$PipeTop.texture = texture
	$PipeBottom.texture = texture

func _process(delta):
	if not is_moving:
		return
	position.x -= SPEED * delta
	if position.x < -100:
		queue_free()

func stop():
	is_moving = false

func _on_body_entered(body):
	if body.is_in_group("player"):
		get_tree().call_group("game", "game_over")

func _on_score_zone_body_entered(body):
	if body.is_in_group("player"):
		$PointSound.play()
		get_tree().call_group("game", "add_score")
