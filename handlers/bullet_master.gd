class_name BulletMaster
extends Node2D

func _ready() -> void:
    SignalBus.make_bullet.connect(_make_bullet)
    SignalBus.clear_all_bullets.connect(_clear_all_bullets)

## clears all the bullets on the screen
func _clear_all_bullets():
    for child in get_children():
        if child is Bullet:
            child.destroy()

## source: the node creating the bullet. This is needed to determine where to place it.
## bullet: the bullet object being created. It should not be in the tree yet, but should have any necessary adjustments to its parameters.
## position: where the bullet will be spawned, relative to source.
func _make_bullet(source:Node2D, bullet:Bullet, _position:Vector2):
    bullet.global_position = source.global_position + _position - self.global_position
    add_child(bullet)
