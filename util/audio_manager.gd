extends Node

# Credit to the whole LT.bat team for this file
# thanks Justin, Connor, Brian.
# naturally modified for this game

# applied to all played music tracks
const MUSIC_VOLUME_MODIFIER:float = -5.0
# applied to all played sound effects
const SFX_VOLUME_MODIFIER:float = 10.0

# Min and Max volumes by db
@export var MAXVOLUME:float = 0.0
@export var MINVOLUME:float = -50.0
# Whether or not to loop BGM
@export var LOOP_MUSIC = true


var music_volume = -25 :
    set(value):
        music_volume = clampf(value, MINVOLUME, MAXVOLUME)
        _update_musicplayer_volumes()

var sound_volume = -25:
    set(value):
        sound_volume = clamp(value, MINVOLUME, MAXVOLUME)
        _update_soundplayer_volumes()

var sound_players:Array = []


@onready var music_player_1:AudioStreamPlayer = $BGMPlayer1
@onready var music_player_2:AudioStreamPlayer = $BGMPlayer2
# active music player
@onready var music_player:AudioStreamPlayer = music_player_1
@onready var sounds = $Sounds

func _ready() -> void:
    _update_musicplayer_volumes()
    _update_soundplayer_volumes()

func _update_musicplayer_volumes():
    if music_volume > MINVOLUME:
        if music_player_1: music_player_1.volume_db = music_volume + MUSIC_VOLUME_MODIFIER
        if music_player_2: music_player_2.volume_db = music_volume + MUSIC_VOLUME_MODIFIER
    else:
        if music_player_1: music_player_1.volume_db = -80
        if music_player_2: music_player_2.volume_db = -80

func _update_soundplayer_volumes():
    for sound_player in sounds.get_children() :
        if sound_volume > MINVOLUME:
            sound_player.volume_db = sound_volume + SFX_VOLUME_MODIFIER
        else:
            sound_player.volume_db = -100


func play_music(file, play_at:float=0.0):
    if music_volume == MINVOLUME: return
    if music_player.is_playing and music_player.stream == file: return
    music_player.stream = file;
    # music_player.volume_db = music_volume;
    music_player.play(play_at);


func stop_music():
    music_player.stop();


func fade_music_in(time:float):
    var tween = create_tween();
    tween.tween_property(music_player, "volume_db", music_volume, time).from(music_volume-30);


func fade_music_out(time:float):
    var player = music_player # in case we switch which is the active player
    var tween = create_tween();
    tween.tween_property(player, "volume_db", music_volume-30, time).from_current();


func crossfade(next_track:AudioStream, time:float=1.0, match_playback=false):
    if not music_player.is_playing() or music_player.get_stream() == null:
        play_music(next_track)
        return
    if next_track == music_player.get_stream():
        return
    var play_percentage = 0.0
    if match_playback:
        var play_position = music_player.get_playback_position()
        var track_length = music_player.get_stream().get_length()
        play_percentage = play_position / track_length
    fade_music_out(time)
    music_player = music_player_2 if music_player == music_player_1 else music_player_1 # swap the active player
    fade_music_in(time)
    var next_play_position = next_track.get_length() * play_percentage
    play_music(next_track, next_play_position)


func play_sound(file, volume_modifier:float = 1.0):
    if sound_volume == MINVOLUME or volume_modifier <= 0.01:
        return
    var sound_player = AudioStreamPlayer.new()
    sound_players.append(sound_player)
    sound_player.bus = "SFX"
    sound_player.stream = file

    # do calculations to find the correct volume value
    var volume_pct = ((sound_volume - MINVOLUME) / (MAXVOLUME - MINVOLUME)) * volume_modifier
    var target_volume = MINVOLUME + ((MAXVOLUME - MINVOLUME) * volume_pct) + SFX_VOLUME_MODIFIER
    sound_player.volume_db = target_volume

    sounds.add_child(sound_player)
    sound_player.play()
    await sound_player.finished
    sound_player.queue_free();

func stop_sounds():
    for player in sounds.get_children():
        player.stop();


func resume_sounds():
    for player in sounds.get_children():
        player.play();


func clear_sounds():
    for player in sounds.get_children():
        player.stop();
        player.queue_free();


## listener for BGM players
func _on_music_finished():
    if LOOP_MUSIC:
        music_player.play()
