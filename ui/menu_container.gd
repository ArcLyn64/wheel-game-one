@tool
extends MarginContainer

@export_group('state')
@export var selected:int = 0:
    set(v):
        selected = clampi(v, 0, len(options) - 1)
        _update_appearance()
@export var menu_active:bool = true

@export_group('components')
@export var options:Array[MenuOption] = []

@onready var select_sfx:AudioStream = preload('res://assets/sfx/select_sfx.wav')
@onready var start_sfx:AudioStream = preload("res://assets/sfx/enemy_death.wav")

func _ready() -> void:
    SignalBus.game_over.connect(_fade_in)

func _fade_in():
    selected = 0
    await get_tree().create_timer(1.0).timeout
    var tween = create_tween()
    self.modulate.a = 0.0
    show()
    tween.tween_property(self, "modulate:a", 1.0, 2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
    await tween.finished
    menu_active = true

func _update_appearance():
    for i in len(options):
        options[i].selected = i == selected

func get_selected_action() -> String:
    return options[selected].value

func _handle_select():
    menu_active = false
    AudioManager.play_sound(start_sfx)
    match get_selected_action():
        'start':
            _handle_start_game()
        'quit':
            get_tree().quit()

func _handle_start_game():
    hide()
    SignalBus.new_game.emit()

func _unhandled_input(_event: InputEvent) -> void:
    if Engine.is_editor_hint(): return
    if not menu_active: return

    var prev_selected = selected

    if Input.is_action_just_pressed('move_down'): selected += 1
    if Input.is_action_just_pressed('move_up'): selected -= 1
    if Input.is_action_just_pressed('fire'): _handle_select()
    
    if prev_selected != selected:
        AudioManager.play_sound(select_sfx)
