extends CanvasLayer

@export_file("*.json") var scene_text_file

var scene_text = {}
var selected_text = []
var can_click = false

var fade_in_tween: Tween
var pull_tween: Tween
var portraits_tween: Tween

@onready var background = $Background
@onready var text_label = $Background/TextLabel
@onready var portraits = $portraits
@onready var portraits_modulator = $"portraits/portraits modulator"
@onready var portrait_left_visualizer = $"portraits/portraits modulator/portrait left"
@onready var portrait_right_visualizer = $"portraits/portraits modulator/portrait right"
@onready var grey_overlay = $grey_overlay

func _ready():
	background.visible = false
	scene_text = load_scene_text()
	SignalBus.display_dialog.connect(on_display_dialog)
	
func load_scene_text():
	if FileAccess.file_exists(scene_text_file):
		var file = FileAccess.open(scene_text_file, FileAccess.READ)
		return JSON.parse_string(file.get_as_text())
		
func show_text():
	can_click = false
	if fade_in_tween != null:
		fade_in_tween.kill()
	text_label.visible_characters = 0
	text_label.text = selected_text.pop_front()
	fade_in_tween = create_tween()
	fade_in_tween.tween_property(text_label, "visible_characters", text_label.get_total_character_count(), text_label.get_total_character_count() * 0.075)
	await fade_in_tween.finished
	can_click = true
	

func next_line():
	if selected_text.size() > 0:
		show_text()
	else:
		finish()

func finish():
	can_click = false
	if portraits_tween != null and portraits_tween.is_running():
			await portraits_tween.finished
	portraits_tween = create_tween()
	portraits_tween.tween_property(portraits_modulator, "color", Globals.transparent, 0.25)
	if pull_tween != null and pull_tween.is_running():
		await pull_tween.finished
	pull_tween = create_tween()
	pull_tween.tween_property(background, "position", Vector2(0, 1400), 0.5).set_trans(Tween.TRANS_SPRING)
	#pull_tween.parallel().tween_property(text_label, "position", Vector2(96, 1440), 0.5).set_trans(Tween.TRANS_SPRING)
	await pull_tween.finished
	grey_overlay.visible = false
	Globals.in_progress = false
	text_label.text = ""
	background.visible = false
	SignalBus.emit_signal("current_dialog_finished")
	get_tree().paused = false

func on_display_dialog(text_key, portrait_left, portrait_right):
	if Globals.in_progress:
		next_line()
	else:
		get_tree().paused = true
		background.visible = true
		portrait_left_visualizer.texture = portrait_left
		portrait_right_visualizer.texture = portrait_right
		Globals.in_progress = true
		grey_overlay.visible = true
		if pull_tween != null and pull_tween.is_running():
			await pull_tween.finished
		pull_tween = create_tween()
		pull_tween.tween_property(background, "position", Vector2(0, 700), 0.5).set_trans(Tween.TRANS_SPRING)
		#pull_tween.parallel().tween_property(text_label, "position", Vector2(96, 720), 0.5).set_trans(Tween.TRANS_SPRING)
		await pull_tween.finished
		if portraits_tween != null and portraits_tween.is_running():
			await portraits_tween.finished
		portraits_tween = create_tween()
		portraits_tween.tween_property(portraits_modulator, "color", Globals.white, 0.25)
		selected_text = scene_text[text_key].duplicate()
		show_text()
		
		
func _input(event: InputEvent) -> void:
	if can_click == true and event.is_action_pressed("Left_click"):
		next_line()
