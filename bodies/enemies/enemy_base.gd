@tool
class_name Enemy
extends Area2D

@export_group('state')
@export var polarity_w:bool = true :
    set(v):
        polarity_w = v
        _display_polarity()
@export var health:float = 25.0

@export_group('properties')
@export var size:float = 40 :
    set(v):
        size = v
        _update_appearance()
@export var point_value:int = 100
@export var weapon:Weapon = null

@export_group('colors')
@export var w_color:Color :
    set(v):
        if display: display.w_color = v
    get():
        if display: return display.w_color
        else: return Color.WHITE
@export var b_color:Color :
    set(v):
        if display: display.b_color = v
    get():
        if display: return display.b_color
        else: return Color.BLACK

@export_group('effects')
@export var death_effect:PackedScene = load('res://effects/pop_effect.tscn')
@export var effect_spawn_point:Node2D = null

@export_group('components')
@export var hurtbox:CollisionShape2D
@export var display:SpinningShape

func _ready() -> void:
    _update_appearance()
    _display_polarity()
    area_entered.connect(_handle_collision)

func _update_appearance():
    if display: display.size = Vector2.ONE * size
    if hurtbox: hurtbox.shape.radius = size * 1.41 / 2

func _display_polarity():
    if display: display.polarity_w = polarity_w

func in_play_area():
    for a in get_overlapping_areas():
        if a.is_in_group('PlayArea'): return true
    return false

func _handle_collision(a:Area2D):
    if a is Bullet:
        if in_play_area():
            health -= a.damage
            var matching = a.polarity_w == self.polarity_w
            a.destroy()
            if health < 0:
                die(matching)
        else:
            a.despawn()

func die(matching:bool, despawn:bool = false):
    if not despawn and death_effect:
        SignalBus.award_points.emit(point_value * (2 if matching else 1))
        var effect = death_effect.instantiate()
        effect.modulate = display.modulate
        if effect_spawn_point:
            effect.position = self.position + effect_spawn_point.position
        else:
            effect.position = self.position
        effect.radius = size / 2
        get_parent().add_child(effect)
    queue_free()   

func _handle_fire(_delta:float):
    pass # by default, do not fire.

func _physics_process(delta: float) -> void:
    if Engine.is_editor_hint(): return
    if not in_play_area(): return
    
    if weapon: weapon.handle_auto_fire(self, delta)
