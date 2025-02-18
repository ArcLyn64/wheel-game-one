@tool
class_name SpinningSquare
extends Polygon2D

@export_group('state')
@export var polarity_w:bool = true :
    set(v):
        polarity_w = v
        _display_polarity()

@export_group('properties')
@export var size:Vector2 = Vector2.ONE * 40 :
    set(v):
        size = v
        _update_points()
@export var spin_speed:float = 0.1

@export_group('colors')
@export var w_color:Color 
@export var b_color:Color 

func _update_points():
    var _offset = -size / 2
    polygon = [
        _offset + Vector2.ZERO,
        _offset + Vector2(size.x, 0),
        _offset + size,
        _offset + Vector2(0, size.y)
    ]

func _display_polarity():
    if polarity_w:
        self.modulate = w_color    
    else:
        self.modulate = b_color

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    _update_points()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    self.rotate(spin_speed * delta)
