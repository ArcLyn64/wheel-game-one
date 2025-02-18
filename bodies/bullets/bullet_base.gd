@tool
class_name Bullet
extends Area2D

@export_group('state')
@export var polarity_w:bool = true :
    set(v):
        polarity_w = v
        _display_polarity()

@export_group('travel')
@export var direction:Vector2 = Vector2.UP :
    set(v):
        direction = v
        look_at(position + direction)
@export var initial_speed:float = 1200.0
@export var acceleration_curve:Curve = null

@export_group('colors')
@export var w_color:Color 
@export var b_color:Color 

@export_group('effects')
@export var death_effect:PackedScene = load('res://effects/pop_effect.tscn')

var speed:float = initial_speed
var _time_passed:float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

func _display_polarity():
    if polarity_w:
        self.modulate = w_color    
    else:
        self.modulate = b_color

func _handle_motion(delta: float):
    _time_passed += delta
    if acceleration_curve and acceleration_curve.min_value > _time_passed and acceleration_curve.max_value < _time_passed:
        speed += acceleration_curve.sample(_time_passed)
    self.position += direction.normalized() * speed * delta

func destroy(despawn:bool = false):
    if not despawn and death_effect:
        var effect = death_effect.instantiate()
        effect.modulate = self.modulate
        effect.position = self.position
        effect.radius = 10
        get_parent().add_child(effect)
    queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
    if not Engine.is_editor_hint():
        _handle_motion(delta)