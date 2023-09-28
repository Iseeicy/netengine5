extends Control
class_name TextWindow

#
#	Exported
#

signal speaker_changed(new_speaker: String)
signal reader_settings_changed(new_reader_settings: TextReaderSettings)

#
#	Variables
#

var _speaker: String = ""
var _reader_settings: TextReaderSettings = null

#
#	Functions
#

func set_speaker(new_speaker: String) -> void:
	_speaker = new_speaker
	speaker_changed.emit(new_speaker)

func get_speaker() -> String:
	return _speaker

func set_reader_settings(settings: TextReaderSettings) -> void:
	_reader_settings = settings
	reader_settings_changed.emit(settings)

func get_reader_settings() -> TextReaderSettings:
	return _reader_settings

func show_text(new_text: String) -> void:
	return

func show_choices(choices: Array[String]) -> void:
	return
