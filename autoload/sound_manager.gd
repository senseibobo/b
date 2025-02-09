extends Node


@export var dealing_sound_player: AudioStreamPlayer
@export var flick_sound_player: AudioStreamPlayer


func play_dealing_sound():
	dealing_sound_player.play()


func play_flick_sound():
	if not flick_sound_player.get_playback_position() < 0.05 or not flick_sound_player.is_playing():
		flick_sound_player.play()
	
