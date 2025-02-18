@tool
class_name IconCounter
extends VBoxContainer

@export var items:Array[CanvasItem] = []
@export var value:int = 0 :
    set(v):
        value = clampi(v, 0, len(items))
        _update_visible()
@export var global_signal:StringName = ''

func _ready() -> void:
    if not global_signal.is_empty() and SignalBus.has_signal(global_signal):
        SignalBus.connect(global_signal, func(v): value = v)

func _update_visible():
    for i in len(items):
        items[i].visible = i < value
