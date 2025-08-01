extends Area2D

@export var image_base: Texture
@export var image_hovered: Texture
@export_file("*.tscn") var next_scene

@onready var sprite = $Sprite
@onready var collision = $Collision

var is_hovered = false

func _ready():
	sprite.texture = image_base

func _input(event: InputEvent) -> void:
	if is_hovered and event.is_action_pressed("Left_click"):
		Globals.safe_to_send_dialog_signal = false
		SignalBus.emit_signal("switch_scene", next_scene, self)
		

func _process(delta: float) -> void:
	if is_hovered == true:
		sprite.texture = image_hovered
	else:
		sprite.texture = image_base

func _on_mouse_entered() -> void:
	is_hovered = true


func _on_mouse_exited() -> void:
	is_hovered = false
