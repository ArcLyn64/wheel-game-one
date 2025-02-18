@tool
class_name SquareEnemy
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

@export_group('components')
@export var display:SpinningSquare
@export var hurtbox:CollisionShape2D

@onready var bullet_scene:PackedScene = preload('res://bodies/bullets/ball.tscn')

var _fire_rate_timer = fire_rate

func _ready() -> void:
    _update_appearance()
    _display_polarity()
    area_entered.connect(_handle_collision)

func _update_appearance():
    if display: display.size = Vector2.ONE * size
    if hurtbox: hurtbox.shape.radius = size * 1.41 / 2

func _display_polarity():
    if display: display.polarity_w = polarity_w

func _in_play_area():
    for a in get_overlapping_areas():
        if a.is_in_group('PlayArea'): return true
    return false

func _handle_collision(a:Area2D):
    if a is Bullet:
        if _in_play_area():
            health -= a.damage
            a.destroy()
        else:
            a.despawn()

func _instantiate_bullet(_direction:Vector2):
    var bullet:Bullet = bullet_scene.instantiate()
    bullet.polarity_w = self.polarity_w
    bullet.direction = _direction
    SignalBus.make_bullet.emit(self, bullet, Vector2.ZERO)

func _fire():
    var target = PlayerInfo.player_location(self)
    _instantiate_bullet(target)
    _instantiate_bullet(target.rotated(deg_to_rad(30)))
    _instantiate_bullet(target.rotated(deg_to_rad(-30)))


func _handle_fire(delta:float):
    _fire_rate_timer -= delta
    if _fire_rate_timer <= 0:
        _fire()
        _fire_rate_timer = fire_rate

func _physics_process(delta: float) -> void:
    if Engine.is_editor_hint(): return
    if not _in_play_area(): return
    
    _handle_fire(delta)

