extends Node2D

@export var spawn_time:float = 5

@onready var formations = [
    preload("res://formations/left_curve_formation.tscn"),
    preload("res://formations/right_curve_formation.tscn"),
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

