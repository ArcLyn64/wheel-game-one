class_name Weapon
extends Resource

@export_group("Autofire Properties")
@export var fire_auto:bool = true
@export var fire_rate:float = 3.0
@export var init_timer:float = 0.5

var _fire_rate_timer:float = 0.0
var _has_fired:bool = false

@warning_ignore("unused_parameter")
func _instantiate_bullet(source:Node2D, _direction:Vector2):
    print_debug("this bullet has not implemented _instantiate_bullet(): " + str(self))

@warning_ignore("unused_parameter")
func fire(source:Node2D):
    print_debug("this bullet has not implemented fire(): " + str(self))

func handle_auto_fire(source:Node2D, delta:float):
    if not fire_auto: return
    _fire_rate_timer += delta
    var timer_threshold = fire_rate if _has_fired else init_timer
    if _fire_rate_timer >= timer_threshold:
        fire(source)
        _fire_rate_timer = 0
        _has_fired = true

