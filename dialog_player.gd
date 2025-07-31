extends CanvasLayer

@export_file("*.json") var scene_text_file

var scene_text = {}
var selected_text = []
var in_progress = false
var can_click = false

var fade_in_tween: Tween
var pull_tween: Tween

@onready var background = $Background
@onready var text_label = $TextLabel
@onready var click_delay = $ClickDelay

func _ready():
	background.visible = false
	scene_text = load_scene_text()
	SignalBus.display_dialog.connect(on_display_dialog)
	
func load_scene_text():
	if FileAccess.file_exists(scene_text_file):
		var file = FileAccess.open(scene_text_file, FileAccess.READ)
		return JSON.parse_string(file.get_as_text())
		
func show_text():
	if fade_in_tween != null:
		fade_in_tween.kill()
	text_label.visible_characters = 0
	text_label.text = selected_text.pop_front()
	fade_in_tween = create_tween()
	fade_in_tween.tween_property(text_label, "visible_characters", text_label.get_total_character_count(), text_label.get_total_character_count() * 0.075)
	

func next_line():
	if selected_text.size() > 0:
		show_text()
		can_click = false
		click_delay.start()
	else:
		finish()

func finish():
	if pull_tween != null:
		pull_tween.kill()
	pull_tween = create_tween()
	pull_tween.tween_property(background, "position", Vector2(0, 1400), 0.5).set_trans(Tween.TRANS_SPRING)
	pull_tween.parallel().tween_property(text_label, "position", Vector2(96, 1440), 0.5).set_trans(Tween.TRANS_SPRING)
	await pull_tween.finished
	text_label.text = ""
	background.visible = false
	in_progress = false
	can_click = false
	SignalBus.emit_signal("current_dialog_finished")
	get_tree().paused = false

func on_display_dialog(text_key):
	if in_progress:
		next_line()
	else:
		get_tree().paused = true
		background.visible = true
		if pull_tween != null:
			pull_tween.kill()
		pull_tween = create_tween()
		pull_tween.tween_property(background, "position", Vector2(0, 700), 0.5).set_trans(Tween.TRANS_SPRING)
		pull_tween.parallel().tween_property(text_label, "position", Vector2(96, 720), 0.5).set_trans(Tween.TRANS_SPRING)
		await pull_tween.finished
		selected_text = scene_text[text_key].duplicate()
		show_text()
		in_progress = true
		can_click = false
		click_delay.start()
		
		
func _input(event: InputEvent) -> void:
	if can_click == true and event.is_action_pressed("Left_click"):
		next_line()


func _on_click_delay_timeout() -> void:
	can_click = true
