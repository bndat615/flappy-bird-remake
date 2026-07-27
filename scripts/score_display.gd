extends Node2D

@export var digit_prefix = "digit-big"
@export var gap = 0.0
@export_enum("left", "center", "right") var alignment = "center"

func set_score(score: int):
	for child in get_children():
		child.queue_free()

	var score_str = str(score)
	var textures = []
	for c in score_str:
		textures.append(load("res://assets/sprites/%s-%s.png" % [digit_prefix, c]))

	var total_width = 0.0
	for tex in textures:
		total_width += tex.get_width()
	total_width += gap * (textures.size() - 1)

	var start_x: float
	match alignment:
		"left":
			start_x = 0.0
		"right":
			start_x = -total_width
		_:
			start_x = -total_width / 2.0

	var x = start_x
	for tex in textures:
		var sprite = Sprite2D.new()
		sprite.texture = tex
		sprite.position = Vector2(x + tex.get_width() / 2.0, 0)
		add_child(sprite)
		x += tex.get_width() + gap
