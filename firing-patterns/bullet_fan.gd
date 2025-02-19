class_name BulletFan
extends Weapon

@export var bullet_scene:PackedScene = preload('res://bodies/bullets/ball.tscn')
@export var num_bullets:int = 3
@export_range(0.0, 360.0) var firing_cone:float = 0

## Override
func _instantiate_bullet(source:Node2D, _direction:Vector2):
    var bullet:Bullet = bullet_scene.instantiate()
    if 'polarity_w' in source:
        bullet.polarity_w = source.polarity_w
    bullet.direction = _direction
    SignalBus.make_bullet.emit(source, bullet, Vector2.ZERO)

## Override
func fire(source:Node2D):
    var target = PlayerInfo.player_location(source)
    var cone_rad = deg_to_rad(firing_cone)
    target = target.rotated(-cone_rad/2)
    for i in num_bullets:
        _instantiate_bullet(source, target)
        if num_bullets > 1: target = target.rotated(cone_rad / (num_bullets - 1))
