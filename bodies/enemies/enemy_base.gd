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
@export var fire_rate:float = 3.0
@export var point_value:int = 100

@export_group('colors')
@export var w_color:Color = Color.WHITE
@export var b_color:Color = Color.BLACK

@export_group('effects')
@export var death_effect:PackedScene = load('res://effects/pop_effect.tscn')
@export var effect_spawn_point:Node2D = null

func _ready() -> void:
    _update_appearance()
    _display_polarity()
    area_entered.connect(_handle_collision)

func _update_appearance():
    print_debug("this enemy did not implement _update_appearance: " + str(self))

func _display_polarity():
    if polarity_w:
        self.modulate = w_color    
    else:
        self.modulate = b_color

func _in_play_area():
    for a in get_overlapping_areas():
        if a.is_in_group('PlayArea'): return true
    return false

func _handle_collision(a:Area2D):
    if a is Bullet:
        if _in_play_area():
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
        effect.modulate = w_color if polarity_w else b_color
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
    if not _in_play_area(): return
    
    _handle_fire(delta)
