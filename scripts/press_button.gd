extends TextureButton

@export var press_offset = 2.0

var original_y = 0.0

func _ready():
	original_y = position.y
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

func _on_button_down():
	var tween = create_tween()
	tween.tween_property(self, "position:y", original_y + press_offset, 0)

func _on_button_up():
	var tween = create_tween()
	tween.tween_property(self, "position:y", original_y, 0)
