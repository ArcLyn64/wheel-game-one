@tool
class_name SpinningSquare
extends SpinningShape

func _update_points():
    var _offset = -size / 2
    polygon = [
        _offset + Vector2.ZERO,
        _offset + Vector2(size.x, 0),
        _offset + size,
        _offset + Vector2(0, size.y)
    ]