extends Control

func _ready():
	visible = false

func _on_text_reader_reading_started(_raw_text, _stripped_text, _settings):
	visible = false

func _on_text_reader_reading_finished(_reason):
	visible = true
