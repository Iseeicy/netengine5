extends RichTextLabel


func _on_text_reader_text_changed(raw_text, _stripped_text):
	text = raw_text

func _on_text_reader_visible_chars_changed(visible_count, _char):
	visible_characters = visible_count
