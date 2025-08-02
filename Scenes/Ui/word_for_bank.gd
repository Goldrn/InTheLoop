extends TextureButton

@export var text: String

func _on_pressed() -> void:
	SignalBus.emit_signal("word_button_pressed", text)
