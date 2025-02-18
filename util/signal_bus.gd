extends Node

signal make_bullet(source:Node2D, bullet:Bullet, position:Vector2)
signal clear_all_bullets()

signal award_points(points:int)
signal reset_score()

signal lives_update(lives:int)
signal energy_update(energy:int)