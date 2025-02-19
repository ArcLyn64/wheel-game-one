extends Node

var player:Wheelkaruga = null

var lives:int = 5 :
    set(v):
        lives = clampi(v, 0, 5)
        SignalBus.lives_update.emit(lives)

func _ready() -> void:
    SignalBus.new_game.connect(func(): lives = 5)

func attach_player(p:Wheelkaruga):
    player = p

func player_location(relative:Node2D = null) -> Vector2:
    if not player: return Vector2.DOWN
    elif relative: return player.global_position - relative.global_position
    else: return player.global_position

func init_player(enable:bool):
    player.initialize(enable)
