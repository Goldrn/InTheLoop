extends CharacterBody2D

@export var move_speed = 300;
@export var deadzone = 1;

var y_level;
var target_pos: Vector2

var view_to_world

var target_area: Area2D
var target_area_key = ""

var is_in_correct_area = false
var should_continue_dialogue = true

var should_switch_scene = false

var portrait_left_passer: Texture
var portrait_right_passer: Texture

var next_scene_holder

@onready var sprite = $main_character_sprite
@onready var dialogue_area = $dialogue_area

func _ready() -> void:
	view_to_world = self.get_canvas_transform().affine_inverse()
	target_pos = self.position
	y_level = self.position.y
	SignalBus.start_move.connect(set_target_pos)
	SignalBus.switch_scene.connect(scene_setter)
	
		
		
func  _process(delta: float) -> void:
	if self.position.x > target_pos.x - deadzone and self.position.x < target_pos.x + deadzone:
		sprite.play("default")
		if is_in_correct_area and should_continue_dialogue:
			SignalBus.emit_signal("display_dialog", target_area_key, portrait_left_passer, portrait_right_passer)
			should_continue_dialogue = false
			target_area = null
			target_area_key = ""
		if is_in_correct_area and should_switch_scene:
			get_tree().change_scene_to_file(next_scene_holder)
	else :
		self.position.x = self.position.move_toward(target_pos, move_speed * delta).x
		sprite.play("walk")
		if dialogue_area.overlaps_area(target_area):
			is_in_correct_area = true
		else:
			is_in_correct_area = false

func set_target_pos(area, text_key, portrait_left, portrait_right):
	if !Globals.in_progress:
		target_area = area
		portrait_left_passer = portrait_left
		portrait_right_passer = portrait_right
		target_area_key = text_key
		target_pos = area.position
		should_continue_dialogue = true
		player_flipper()
		

func _on_dialogue_area_area_entered(area: Area2D) -> void:
	if target_area == area:
		is_in_correct_area = true
		
func scene_setter(scene, area):
	if !Globals.in_progress:
		target_area = area
		next_scene_holder = scene
		target_pos = area.position
		should_switch_scene = true
		player_flipper()
		
func player_flipper():
	if self.position.x > target_pos.x - deadzone and self.position.x > target_pos.x + deadzone:
		sprite.flip_h = false
	elif self.position.x < target_pos.x - deadzone and self.position.x < target_pos.x + deadzone:
		sprite.flip_h = true
	else: 
		pass

	
	
