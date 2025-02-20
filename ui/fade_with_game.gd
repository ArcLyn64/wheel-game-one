extends Node

var _tween:Tween

func _ready() -> void:
    SignalBus.new_game.connect(fade_in)
    SignalBus.game_over.connect(fade_out)

func fade_in():
    if _tween and _tween.is_running():
        _tween.finished.emit()
        _tween.kill()
    _tween = create_tween()
    _tween.tween_property(self, "modulate:a", 1.0, 2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func fade_out():
    if _tween and _tween.is_running():
        _tween.finished.emit()
        _tween.kill()
    _tween = create_tween()
    _tween.tween_property(self, "modulate:a", 0.0, 2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)