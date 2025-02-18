@tool
class_name PlayAreaBorder
extends StaticBody2D

@export var determines_size:Control :
    set(v):
        determines_size = v
        if determines_size != null:
            _update_size()
            if not determines_size.resized.is_connected(_update_size):
                determines_size.resized.connect(_update_size)

@export_group('components')
@export var border_l:CollisionShape2D
@export var border_t:CollisionShape2D
@export var border_b:CollisionShape2D
@export var border_r:CollisionShape2D
@export var area:Area2D
@export var area_shape:CollisionShape2D

func _update_size():
    var borders = determines_size.size
    border_t.position = Vector2(0, 0)
    border_l.position = Vector2(0, 0)
    border_b.position = Vector2(0, borders.y)
    border_r.position = Vector2(borders.x, 0)
    
    area.position = borders / 2
    area_shape.shape.size = borders

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if determines_size:
        if not determines_size.resized.is_connected(_update_size):
            determines_size.resized.connect(_update_size)
        _update_size()
