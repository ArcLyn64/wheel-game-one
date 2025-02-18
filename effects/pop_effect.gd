@tool
extends Node2D

const ANIM_TIME = 0.4

@export var radius:float = 30:
    set(v):
        radius = v
        if circle_2d: 
            circle_2d.radius = radius
            circle_2d.width = 2*radius
            circle_2d.fidelity = int(radius / 2)

@onready var circle_2d = $Circle2D

func _ready() -> void:
    radius = radius # update circle2d
    if not Engine.is_editor_hint():
        call_deferred('_animate')

func _animate():
    var tween = create_tween()
    tween.tween_property(circle_2d, 'width', 0, ANIM_TIME).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
    await tween.finished
    queue_free()