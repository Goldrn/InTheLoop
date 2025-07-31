extends Area2D

@export var object_name = ""
@export var image_base: Texture
@export var image_hovered: Texture

@onready var sprite = $Sprite
@onready var collision = $Collision

var is_hovered = false
var safe_to_send_dialogue_signal = true

func _ready():
	sprite.texture = image_base
	SignalBus.current_dialog_finished.connect(saftey_switcher)

func _input(event: InputEvent) -> void:
	if is_hovered and event.is_action_pressed("Left_click") and safe_to_send_dialogue_signal:
		SignalBus.emit_signal("start_move", self, object_name)
		safe_to_send_dialogue_signal = false

func _process(delta: float) -> void:
	if is_hovered == true:
		sprite.texture = image_hovered
	else:
		sprite.texture = image_base

func _on_mouse_entered() -> void:
	is_hovered = true

func _on_mouse_exited() -> void:
	is_hovered = false

func saftey_switcher():
	safe_to_send_dialogue_signal = true
