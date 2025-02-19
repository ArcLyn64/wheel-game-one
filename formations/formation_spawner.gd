extends Node2D

@export var spawn_time:float = 5

@onready var formations = [
    preload("res://formations/left_curve_formation.tscn"),
    preload("res://formations/right_curve_formation.tscn"),
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    randomize()
    get_tree().create_timer(5.0).timeout.connect(send_formation)

func send_formation():
    var formation = formations[randi() % len(formations)].instantiate()
    add_child(formation)
    get_tree().create_timer(spawn_time).timeout.connect(send_formation)

