extends Node2D

@export var area_size: float = 60.0
@export var sparkle_count: int = 4
@export var interval: float = 0.5

var textures = [
	"res://assets/sprites/sparkle-small.png",
	"res://assets/sprites/sparkle-medium.png",
	"res://assets/sprites/sparkle-large.png",
]

var timer: Timer

func _ready():
	timer = Timer.new()
	timer.wait_time = interval
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

func start():
	stop_visuals()
	timer.start()
	_on_timer_timeout()

func stop():
	timer.stop()
	stop_visuals()

func stop_visuals():
	for child in get_children():
		if child is Sprite2D:
			child.queue_free()

func _on_timer_timeout():
	for i in range(sparkle_count):
		var sprite = Sprite2D.new()
		sprite.texture = load(textures[randi() % textures.size()])
		sprite.position = Vector2(
			randf_range(-area_size / 2.0, area_size / 2.0),
			randf_range(-area_size / 2.0, area_size / 2.0)
		)
		sprite.modulate.a = 0
		add_child(sprite)

		var tween = create_tween()
		tween.tween_property(sprite, "modulate:a", 1.0, 0.15)
		tween.tween_interval(0.1)
		tween.tween_property(sprite, "modulate:a", 0.0, 0.25)
		tween.tween_callback(sprite.queue_free)
