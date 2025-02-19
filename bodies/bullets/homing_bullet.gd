@tool
class_name HomingBullet
extends Bullet

@export_group('properties')
@export var target:Node2D

@export_group('components')
@export var display:SpinningShape

func _display_polarity():
    if display:
        display.w_color = w_color
        display.b_color = b_color
        display.polarity_w = polarity_w

## Override
func _handle_motion(delta: float):
    _time_passed += delta
    if speed_curve and _time_passed < speed_curve_time:
        speed = initial_speed * speed_curve.sample(_time_passed / speed_curve_time)
    var target_point = (Vector2.ZERO if not target else target.global_position - self.global_position).normalized()
    var interpolated_target_point = lerp(direction.normalized(), target_point, _time_passed / speed_curve_time)
    direction = interpolated_target_point
    self.position += direction.normalized() * speed * delta