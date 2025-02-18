@tool
class_name SquareEnemy
extends Enemy

@onready var bullet_scene:PackedScene = preload('res://bodies/bullets/ball.tscn')

var _fire_rate_timer = 0.5

func _instantiate_bullet(_direction:Vector2):
    var bullet:Bullet = bullet_scene.instantiate()
    bullet.polarity_w = self.polarity_w
    bullet.direction = _direction
    SignalBus.make_bullet.emit(self, bullet, Vector2.ZERO)

func _fire():
    var target = PlayerInfo.player_location(self)
    _instantiate_bullet(target)
    _instantiate_bullet(target.rotated(deg_to_rad(20)))
    _instantiate_bullet(target.rotated(deg_to_rad(-20)))

func _handle_fire(delta:float):
    _fire_rate_timer -= delta
    if _fire_rate_timer <= 0:
        _fire()
        _fire_rate_timer = fire_rate
