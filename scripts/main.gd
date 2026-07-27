extends Node

const PIPE_SCENE = preload("res://scenes/pipe.tscn")
const SAVE_PATH = "user://highscore.save"

enum State { START, GAMEPLAY_WAITING, PLAYING, GAME_OVER }

var score = 0
var high_score = 0
var state = State.START

const BIRD_START_POS = Vector2(144, 256)
const BIRD_GAMEPLAY_POS = Vector2(89, 250)

func _ready():
	$PipeSpawner.timeout.connect(_on_spawn_timer)
	load_high_score()
	$UI/ScoreDisplay.visible = false
	$UI/GamePlayScreen.visible = false
	$UI/GameOverScreen.visible = false
	$Bird.start_idle(BIRD_START_POS)

func _unhandled_input(event):
	if state == State.GAMEPLAY_WAITING and event.is_action_pressed("jump"):
		begin_playing()

func _on_play_button_pressed():
	if state != State.START:
		return
	$SwooshSound.play()
	await fade_to_black(0.35)
	enter_gameplay_waiting()
	await fade_from_black(0.35)

func enter_gameplay_waiting():
	state = State.GAMEPLAY_WAITING
	$UI/StartScreen.visible = false
	$UI/GamePlayScreen.visible = true
	$UI/ScoreDisplay.visible = true
	$UI/ScoreDisplay.set_score(0)
	$Bird.start_idle(BIRD_GAMEPLAY_POS)

func begin_playing():
	state = State.PLAYING
	$UI/GamePlayScreen.visible = false
	$Bird.start_playing()
	$PipeSpawner.start()

func _on_spawn_timer():
	var pipe = PIPE_SCENE.instantiate()
	pipe.position = Vector2(320, randi_range(122, 282))
	$PipeContainer.add_child(pipe)

func game_over():
	if state == State.GAME_OVER:
		return
	state = State.GAME_OVER

	flash_screen()
	$HitSound.play()
	$DieSound.play()

	$Bird.die()
	$PipeSpawner.stop()
	$Ground.stop()
	for pipe in $PipeContainer.get_children():
		pipe.stop()

	await get_tree().create_timer(0.5).timeout

	var is_new_record = score > high_score
	if is_new_record:
		high_score = score
		save_high_score()

	play_game_over_sequence(is_new_record)

func flash_screen():
	var overlay = $UI/FlashOverlay
	overlay.color = Color.WHITE
	overlay.color.a = 1.0
	var tween = create_tween()
	tween.tween_property(overlay, "color:a", 0.0, 0.3)

func fade_to_black(duration: float = 0.4) -> void:
	var overlay = $UI/FlashOverlay
	overlay.color = Color.BLACK
	overlay.color.a = 0.0
	var tween = create_tween()
	tween.tween_property(overlay, "color:a", 1.0, duration)
	await tween.finished

func fade_from_black(duration: float = 0.4) -> void:
	var overlay = $UI/FlashOverlay
	var tween = create_tween()
	tween.tween_property(overlay, "color:a", 0.0, duration)
	await tween.finished

func play_game_over_sequence(is_new_record: bool):
	var screen = $UI/GameOverScreen

	var go_sprite = screen.get_node("GameOverSprite")
	var panel = screen.get_node("ScoreboardPanel")
	var final_score_display = screen.get_node("FinalScoreDisplay")
	var high_score_display = screen.get_node("HighScoreDisplay")
	var medal = screen.get_node("MedalSprite")
	var new_badge = screen.get_node("NewBadgeSprite")
	var restart_btn = screen.get_node("RestartButton")

	var final_y = go_sprite.position.y
	go_sprite.position.y = final_y + 20
	go_sprite.modulate.a = 0

	var panel_final_y = panel.position.y
	panel.position.y = panel_final_y + 400

	final_score_display.modulate.a = 0
	high_score_display.modulate.a = 0
	medal.modulate.a = 0
	new_badge.visible = false
	restart_btn.modulate.a = 0

	$UI/ScoreDisplay.visible = false
	$UI/GameOverScreen.visible = true
	
	$SwooshSound.play()
	var tween1 = create_tween()
	tween1.parallel().tween_property(go_sprite, "modulate:a", 1.0, 0.12)
	tween1.parallel().tween_property(go_sprite, "position:y", final_y - 4, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween1.tween_property(go_sprite, "position:y", final_y, 0.06).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween1.finished
	
	await get_tree().create_timer(0.8).timeout
	
	$SwooshSound.play()
	var tween2 = create_tween()
	tween2.tween_property(panel, "position:y", panel_final_y, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween2.finished
	
	final_score_display.modulate.a = 1
	await count_up_score(final_score_display, score, 0.5)

	var medal_tex = get_medal_texture(score)
	medal.texture = medal_tex
	if medal_tex != null:
		medal.modulate.a = 1
		medal.get_node("MedalSparkle").start()
	else:
		medal.modulate.a = 0

	high_score_display.set_score(high_score)
	high_score_display.modulate.a = 1

	new_badge.visible = is_new_record
	new_badge.modulate.a = 1

	restart_btn.modulate.a = 1

func get_medal_texture(s: int) -> Texture2D:
	if s >= 40:
		return load("res://assets/sprites/medal-diamond.png")
	elif s >= 30:
		return load("res://assets/sprites/medal-gold.png")
	elif s >= 20:
		return load("res://assets/sprites/medal-silver.png")
	elif s >= 10:
		return load("res://assets/sprites/medal-copper.png")
	else:
		return null

func add_score():
	score += 1
	$UI/ScoreDisplay.set_score(score)

func restart_game():
	for pipe in $PipeContainer.get_children():
		pipe.queue_free()

	score = 0
	$UI/GameOverScreen.visible = false
	$UI/GameOverScreen/MedalSprite/MedalSparkle.stop()
	$Bird.reset()
	$Ground.reset()

	enter_gameplay_waiting()

func _on_restart_button_pressed():
	$SwooshSound.play()
	await fade_to_black(0.35)
	restart_game()
	await fade_from_black(0.35)

func save_high_score():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(high_score)
	file.close()

func load_high_score():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		high_score = file.get_var()
		file.close()

func count_up_score(display: Node, target: int, duration: float) -> void:
	if target <= 0:
		display.set_score(0)
		return
	var interval = duration / target
	for i in range(target + 1):
		display.set_score(i)
		if i < target:
			await get_tree().create_timer(interval).timeout
