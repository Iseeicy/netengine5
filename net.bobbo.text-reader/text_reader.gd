extends Node
class_name TextReader

enum State {
	Empty,		# There is no text being show
	Reading,	# Text is actively being read
	Paused,		# Text was being read, but is now paused
	HasRead		# Text has finished being read and is on screen
}

enum ReadFinishReason {
	EndOfText,
	Skipped,
	Canceled
}

#
#	Exported
#

# Called when the state of the text reader is updated
signal state_changed(new_state: State)

# Called whenever the text being read is changed
signal text_changed(raw_text: String, stripped_text: String)

# Called whenever the number of visible characters changed
signal visible_chars_changed(visible_count: int, char: String)

# Called when the text is now being read
signal reading_started(raw_text: String, stripped_text: String, settings: TextReaderSettings)

# Called when reading is completed
signal reading_finished(reason: ReadFinishReason)

# Values to use when no settings are provided
@export var default_settings: TextReaderSettings

#
#	Variables
#

var _state: State
var time_until_next_char: float = 0
var current_settings: TextReaderSettings = null
var _text_raw: String = ""
var _text_stripped: String = ""
var _max_visible_chars: int = 0
var _visible_chars: int = 0
var _visible_char: String = ''

#
#	Godot Functions
#

func _process(delta):
	if _state == State.Reading:
		_handle_show_sequence(delta)
#
#	Functions
#

func start_reading(new_text: String, settings: TextReaderSettings = null) -> void:
	# Check if we need to use default values, then apply the settings
	if settings == null:
		if default_settings != null:
			settings = default_settings
		else:
			settings = TextReaderSettings.new()
	current_settings = settings
	
	# Check if we need to set the sounds too
	if current_settings.sounds == null:
		if default_settings != null and default_settings.sounds != null:
			current_settings.sound = default_settings.sounds
	
	_set_text(new_text)		# Update what the text actually is
	_set_state(State.Reading)
	reading_started.emit(get_raw_text(), get_stripped_text(), current_settings)
	
func skip_to_reading_end() -> void:
	_set_state(State.HasRead)	
	reading_finished.emit(ReadFinishReason.Skipped)	# Report finished
	
func cancel_reading() -> void:
	_set_state(State.Empty)
	reading_finished.emit(ReadFinishReason.Canceled)	# Report finihsed
	
func set_show_paused(should_pause: bool) -> bool:
	if _state != State.Reading:
		return false
	
	_set_state(State.Paused)
	return true
	
func is_show_paused() -> bool:
	return _state == State.Paused

func get_raw_text() -> String:
	return _text_raw
	
func get_stripped_text() -> String:
	return _text_stripped
	
func get_visible_characters() -> int:
	return _visible_chars

func get_visible_char() -> String:
	return _visible_char
	
func get_state() -> State:
	return _state

#
#	Private Functions
#

func _set_state(new_state: State) -> void:
	_state = new_state
	
	match(new_state):
		State.Empty:
			_set_visible_chars(0)	# Hide all text
			_set_text("")			# Reset our text field
		State.Reading:
			_set_visible_chars(0)	# Hide all text
			time_until_next_char = 0
		State.Paused:
			pass
		State.HasRead:
			_set_visible_chars(-1)	# Reveal ALL TEXT
	
	state_changed.emit(new_state)

func _handle_show_sequence(delta: float) -> void:
	time_until_next_char -= delta	# Count down the timer...
	
	# If we should display the next character NOW...
	if time_until_next_char <= 0:
		# Display the char & reset timer, then address end of dialog if needed
		_handle_show_next_char()
		if get_visible_characters() >= _max_visible_chars:
			_handle_reached_end_of_dialog()
			
func _handle_show_next_char() -> void:
	if get_stripped_text().length() <= 0:
		return
	
	# Visibly show the next character
	_set_visible_chars(get_visible_characters() + 1)
	
	# Reset the character timer
	time_until_next_char = _get_char_display_speed(
		get_visible_char(), 
		get_stripped_text(), 
		get_visible_characters() - 1
	)
	
func _handle_reached_end_of_dialog() -> void:
	_set_state(State.HasRead)
	reading_finished.emit(ReadFinishReason.EndOfText)
	
func _get_char_display_speed(char: String, dialog_text: String, index: int) -> float:
	# If there's multiple characters in a row, then treat this as a normal char
	if index + 1 < dialog_text.length():
		if char == dialog_text[index + 1]:
			return current_settings.char_show_delay
	
	match char:
		' ':
			return 0
		'.', '!', ',', '?', '-', ':', ';', '\n':
			return current_settings.punctuation_show_delay
		_:
			return current_settings.char_show_delay

func _strip_bbcode(source: String) -> String:
	# Thanks to https://github.com/godotengine/godot-proposals/issues/5056#issuecomment-1203033323!
	var regex = RegEx.new()
	regex.compile("\\[.+?\\]")
	return regex.sub(source, "", true)
	
	
	
func _set_text(new_text: String) -> void:
	_text_raw = new_text
	_text_stripped = _strip_bbcode(new_text)
	_max_visible_chars = get_stripped_text().length()
	text_changed.emit(_text_raw, _text_stripped)
	
func _set_visible_chars(new_count: int) -> void:
	# If we set to a negative value, we want to show all chars
	if new_count < 0:
		new_count = get_stripped_text().length()
	# If we set to a value too large, cap it
	elif new_count > get_stripped_text().length():
		new_count = get_stripped_text().length()
		
	_visible_chars = new_count
	var actual_char = ''
	
	# If we are actually displaying a character, then cache it
	# so that we can emit it below
	if get_stripped_text().length() > 0:
		actual_char = get_stripped_text()[get_visible_characters() - 1]
	
	_visible_char = actual_char
	visible_chars_changed.emit(new_count, actual_char)
