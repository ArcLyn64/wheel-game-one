@tool
class_name ScoreMeter
extends Label

@export var value:int = 0 :
    set(v):
        value = v
        _update_display()

func _update_display():
    var score_str = str(value)
    while len(score_str) < 10:
        score_str = '0' + score_str
    score_str = '\n'.join(score_str.split())
    text = score_str

func _ready() -> void:
    SignalBus.award_points.connect(func(v): value += v)
    SignalBus.reset_score.connect(func(): value = 0)
    SignalBus.new_game.connect(func(): value = 0)
