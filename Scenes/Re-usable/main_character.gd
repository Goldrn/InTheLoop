extends CharacterBody2D

@export var move_speed = 200;
@export var deadzone = 1;

var y_level;
var target_pos: Vector2

var view_to_world

var target_area: Area2D
var target_area_key = ""

var is_in_correct_area = false
var should_continue_dialogue = true


@onready var sprite = $main_character_sprite
@onready var dialogue_area = $dialogue_area

func _ready() -> void:
	view_to_world = self.get_canvas_transform().affine_inverse()
	target_pos = self.position
	y_level = self.position.y
	SignalBus.start_move.connect(set_target_pos)
	
		
		
func  _process(delta: float) -> void:
	if self.position.x > target_pos.x - deadzone and self.position.x < target_pos.x + deadzone:
		sprite.play("default")
		if is_in_correct_area and should_continue_dialogue:
			SignalBus.emit_signal("display_dialog", target_area_key)
			should_continue_dialogue = false
			target_area = null
			target_area_key = ""
	else :
		self.position.x = self.position.move_toward(target_pos, move_speed * delta).x
		sprite.play("walk")

func set_target_pos(area, text_key):
	if !Globals.in_progress:
		target_area = area
		target_area_key = text_key
		target_pos = area.position
		should_continue_dialogue = true

func _on_dialogue_area_area_entered(area: Area2D) -> void:
	if target_area == area:
		is_in_correct_area = true
		
func _on_dialogue_area_area_exited(area: Area2D) -> void:
	is_in_correct_area = false
	
