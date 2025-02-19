class_name Formation
extends Path2D

@export_group('properties')
@export var traversal_time:float = 10.0
@export var member_offset_seconds:float = 1.0
@export var progress_curve:Curve = null

@export_group('components')
@export var members:Array[PathFollow2D] = []

func _ready() -> void:
    if not Engine.is_editor_hint():
        call_deferred('march')

func _determine_progress(progress:float, member:PathFollow2D):
    if not progress_curve:
        member.progress_ratio = progress
    else:
        member.progress_ratio = progress_curve.sample(progress)

func march():
    for member in members:
        var _tween = create_tween()
        _tween.tween_method(_determine_progress.bind(member), 0.0, 1.0, traversal_time)
        await get_tree().create_timer(member_offset_seconds).timeout
    await get_tree().create_timer(traversal_time).timeout
    queue_free()
