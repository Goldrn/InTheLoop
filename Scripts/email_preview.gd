extends TextureRect

@export var email_object_holder: Dictionary

var is_hovered = false

func _input(event: InputEvent) -> void:
	if is_hovered and event.is_action_pressed("Left_click"):
		SignalBus.emit_signal("open_email", email_object_holder)

func _on_mouse_entered() -> void:
	is_hovered = true
	self.modulate = Globals.unknown_word
	

func _on_mouse_exited() -> void:
	is_hovered = false
	self.modulate = Globals.white

func set_email_object(email_obj):
	return email_obj
	
