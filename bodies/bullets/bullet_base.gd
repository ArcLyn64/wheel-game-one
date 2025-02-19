@tool
class_name Bullet
extends Area2D

@export_group('state')
@export var polarity_w:bool = true :
    set(v):
        polarity_w = v
        _display_polarity()

@export_group('properties')
@export var damage:float = 1.0

@export_group('travel')
@export var direction:Vector2 = Vector2.UP :
    set(v):
        direction = v
        look_at(position + direction)
@export var initial_speed:float = 1200.0
@export var speed_curve:Curve = null
@export var speed_curve_time:float = 1

@export_group('colors')
@export var w_color:Color 
@export var b_color:Color 

@export_group('effects')
@export var death_effect:PackedScene = load('res://effects/pop_effect.tscn')
@export var effect_spawn_point:Node2D = null

var speed:float = initial_speed
var _time_passed:float = 0.0

func _ready() -> void:
    area_exited.connect(_check_exited_play_area)

func _check_exited_play_area(area:Area2D):
    if area.is_in_group('PlayArea'):
        get_tree().create_timer(1.0).timeout.connect(func(): if not in_play_area(): destroy.bind(true))

func in_play_area():
    for a in get_overlapping_areas():
        if a.is_in_group('PlayArea'): return true
    return false

func _display_polarity():
    if polarity_w:
        self.modulate = w_color    
    else:
        self.modulate = b_color

func _handle_motion(delta: float):
    _time_passed += delta
    if speed_curve and _time_passed < speed_curve_time:
        speed = initial_speed * speed_curve.sample(_time_passed / speed_curve_time)
    self.position += direction.normalized() * speed * delta

func destroy(_despawn:bool = false):
    if not _despawn and death_effect:
        var effect = death_effect.instantiate()
        effect.modulate = self.modulate
        if effect_spawn_point:
            effect.position = self.position + effect_spawn_point.position
        else:
            effect.position = self.position
        effect.radius = 10
        get_parent().add_child(effect)
    queue_free()

## alias for destroy(true)
func despawn(): destroy(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
    if not Engine.is_editor_hint():
        _handle_motion(delta)