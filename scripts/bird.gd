extends CharacterBody2D

const GRAVITY = 900.0
const JUMP_FORCE = -300.0

const TILT_UP = -0.3
const TILT_DOWN_MAX = PI / 2
const ROTATE_SPEED = 10.0

var can_move = false
var is_alive = true
var is_idle = false
var idle_time = 0.0
var idle_base_y = 0.0

func _ready():
	setup_random_color()
	$AnimatedSprite2D.play("fly")

func setup_random_color():
	var colors = ["yellowbird", "bluebird", "redbird"]
	var chosen = colors[randi() % colors.size()]

	var frames = SpriteFrames.new()
	frames.add_animation("fly")
	frames.set_animation_speed("fly", 12.0)
	frames.set_animation_loop("fly", true)

	for suffix in ["-upflap", "-midflap", "-downflap", "-midflap"]:
		var path = "res://assets/sprites/%s%s.png" % [chosen, suffix]
		frames.add_frame("fly", load(path))

	$AnimatedSprite2D.sprite_frames = frames

func start_idle(idle_position: Vector2):
	position = idle_position
	idle_base_y = idle_position.y
	is_idle = true
	can_move = false
	rotation = 0.0
	setup_random_color()
	$AnimatedSprite2D.play("fly")

func start_playing():
	is_idle = false
	can_move = true

func die():
	is_alive = false
	$AnimatedSprite2D.stop()

func reset():
	is_alive = true
	can_move = false
	rotation = 0.0
	velocity = Vector2.ZERO

func _process(delta):
	if is_idle:
		idle_time += delta
		position.y = idle_base_y + sin(idle_time * 8.0) * 4.0

func _physics_process(delta):
	if not can_move:
		return

	velocity.y += GRAVITY * delta

	if is_alive and Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_FORCE
		$WingSound.play()

	move_and_slide()
	
	if position.y < 0:
		position.y = 0
		velocity.y = 0

	update_rotation(delta)

func update_rotation(delta):
	var target_rotation: float
	if velocity.y < 0:
		target_rotation = TILT_UP
	else:
		target_rotation = clamp(velocity.y / 400.0, 0.0, TILT_DOWN_MAX)

	rotation = lerp_angle(rotation, target_rotation, delta * ROTATE_SPEED)

	if not is_alive and is_on_floor():
		rotation = TILT_DOWN_MAX
