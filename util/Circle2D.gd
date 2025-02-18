@tool
extends Line2D
class_name Circle2D

## radius of the circle
@export var radius:float = 50 :
    set(value):
        radius = value
        _redraw()
## how many points make up the circle
@export var fidelity:int = 100 :
    set(value):
        fidelity = value
        _redraw()
## direction where the arc starts
@export var arc_start:Vector2 = Vector2.UP :
    set(value):
        arc_start = value
        _redraw()
## where the arc of the circle stops being drawn
@export var arc_end:float = 360 :
    set(value):
        arc_end = value
        _redraw()

# Called when the node enters the scene tree for the first time.
func _ready():
    _redraw()

func _redraw():
    clear_points()
    var pos: Vector2 = arc_start.normalized() * radius 
    for i in fidelity:
        add_point(pos)
        pos = pos.rotated(deg_to_rad(arc_end / (fidelity - 1)))