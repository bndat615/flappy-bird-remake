extends Node2D

const SPEED = 120.0
const GROUND_WIDTH = 336.0

var is_moving = true

func _process(delta):
	if not is_moving:
		return
	for sprite in [$Sprite1, $Sprite2]:
		sprite.position.x -= SPEED * delta
		if sprite.position.x <= -GROUND_WIDTH / 2.0:
			sprite.position.x += GROUND_WIDTH * 2

func stop():
	is_moving = false

func reset():
	is_moving = true

func _on_ground_body_entered(body):
	if body.is_in_group("player"):
		get_tree().call_group("game", "game_over")
