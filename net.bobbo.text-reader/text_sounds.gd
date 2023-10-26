@tool
extends Resource
class_name TextSounds

enum SoundType {
	None,
	Default,
	Period,
	Comma,
	Question,
	Exclam
}

#
#	Exported
#

@export var default: AudioStream
@export var period: AudioStream
@export var exclam: AudioStream
@export var comma: AudioStream
@export var question: AudioStream

#
#	Functions
#

func get_stream(sound_type: SoundType) -> AudioStream:
	match sound_type:
		SoundType.Default:
			return default
		SoundType.Period:
			return period
		SoundType.Comma:
			return comma
		SoundType.Question:
			return question
		SoundType.Exclam:
			return exclam
		_:
			return null

