extends Node2D

@export var spawn_time:float = 5

@onready var formations = [
    preload("res://formations/left_curve_formation.tscn"),
    preload("res://formations/right_curve_formation.tscn"),
    preload("res://formations/vertical_black_formation.tscn"),
    preload("res://formations/vertical_white_formation.tscn"),
    preload("res://formations/vertical_zebra_formation.tscn"),
    preload("res://formations/vthrough_center_formation.tscn"),
    preload("res://formations/vthrough_left_formation.tscn"),
    preload("res://formations/vthrough_right_formation.tscn"),
    preload("res://formations/vthrough_horizontal_formation.tscn"),
    preload("res://formations/double_midboss_formation.tscn"),
]

var game_over:bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    randomize()
    SignalBus.game_over.connect(func(): game_over = true)
    SignalBus.new_game.connect(func():
        game_over = false
        get_tree().create_timer(spawn_time).timeout.connect(send_formation)
    )

func send_formation():
    if game_over: return
    self.show()
    var formation = formations[randi() % len(formations)].instantiate()
    add_child(formation)
    get_tree().create_timer(spawn_time).timeout.connect(send_formation)

