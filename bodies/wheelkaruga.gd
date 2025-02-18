@tool class_name Wheelkaruga extends CharacterBody2D

@export_group('state')
@export var polarity_w:bool = false :
    set(v):
        polarity_w = v
        if polarity_w:
            if body: body.modulate = b_color
            if wheel: wheel.modulate = w_color
        else:
            if body: body.modulate = w_color
            if wheel: wheel.modulate = b_color
        polarity_update.emit(polarity_w)
@export_range(0, 9) var charge:int = 0 :
    set(v):
        charge = min(max(0, v), 9)
        SignalBus.energy_update.emit(charge)
@export_range(1, 4) var fire_power:int = 2 :
    set(v):
        fire_power = v
        firepower_update.emit(v)

@export_group('control')
@export var speed:float = 300.0
@export var skew_on_move_deg:float = 10.0
@export var skew_per_frame_deg:float = 0.1
@export var offset_on_move:float = 10.0
@export var offset_per_frame_deg:float = 5.0
@export var fire_rate:float = 0.05

@export_group('effects')
@export var death_effect:PackedScene = load('res://effects/pop_effect.tscn')
@export var effect_spawn_point:Node2D = null

@export_group('colors')
@export var w_color:Color 
@export var b_color:Color 

@export_group('components')
@export var wheel:Wheel
@export var body:Node2D
@export var small_hurtbox:Area2D
@export var large_hurtbox:Area2D

signal polarity_update(is_white:bool)
signal firepower_update(power:int)

@onready var bullet_scene:PackedScene = preload('res://bodies/bullets/needle.tscn')

var enabled:bool = true :
    set(v):
        if v and enabled != v:
            enabled = v
            enable()
        elif not v and enabled != v:
            enabled = v
            disable()

var _fire_rate_timer = 0.0

func _ready() -> void:
    PlayerInfo.attach_player(self)
    if wheel:
        wheel.new_dir_chosen.connect(_handle_wheel_input)
        wheel.puzzle_finished.connect(_handle_wheel_full)
    if small_hurtbox: small_hurtbox.area_entered.connect(_handle_collision_small_area)
    if large_hurtbox: small_hurtbox.area_entered.connect(_handle_collision_large_area)

func _handle_movement():
    var direction := Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
    velocity = direction * speed
    body.skew = move_toward(body.skew, direction.x * deg_to_rad(skew_on_move_deg), skew_per_frame_deg)
    body.position.y = move_toward(body.position.y, -direction.y * offset_on_move, offset_per_frame_deg)

func _mega_laser(_strength:int):
    pass # TODO

func _instantiate_bullet(_position:Vector2):
    var bullet:Bullet = bullet_scene.instantiate()
    bullet.polarity_w = self.polarity_w
    SignalBus.make_bullet.emit(self, bullet, _position)

func _fire():
    match fire_power:
        1:
            _instantiate_bullet(Vector2(0, -65))
        2:
            _instantiate_bullet(Vector2(10, -65))
            _instantiate_bullet(Vector2(-10, -65))
        3:
            _instantiate_bullet(Vector2(0, -65))
            _instantiate_bullet(Vector2(20, -60))
            _instantiate_bullet(Vector2(-20, -60))
        4:
            _instantiate_bullet(Vector2(10, -65))
            _instantiate_bullet(Vector2(-10, -65))
            _instantiate_bullet(Vector2(20, -60))
            _instantiate_bullet(Vector2(-20, -60))

func _charge(strength:int):
    match strength:
        1:
            charge -= 2
        2:
            charge -= 1
        3:
            charge += 1
        4:
            charge += 2

func _set_polarity(is_w:bool, strength:int):
    polarity_w = is_w
    fire_power = strength

func _handle_wheel_input(_wheel_value):
    var strength = _wheel_value.slice_value
    match wheel.current_direction:
        Wheel.DIRECTIONS[0]: # up
            _mega_laser(strength)
        Wheel.DIRECTIONS[1]: # right
            _set_polarity(true, strength)
        Wheel.DIRECTIONS[2]: # down
            _charge(strength)
        Wheel.DIRECTIONS[3]: # left
            _set_polarity(false, strength)

func _handle_fire_input(delta:float):
    _fire_rate_timer -= delta
    if Input.is_action_pressed("fire") and _fire_rate_timer <= 0:
        _fire()
        _fire_rate_timer = fire_rate

func _handle_wheel_full():
    wheel.reset()
    wheel.rotate_slices()

# destroy matching bullets and add their damage to score
func _handle_collision_large_area(area:Area2D):
    if area is Bullet and area.polarity_w == self.polarity_w:
        SignalBus.award_points.emit(area.damage)
        area.destroy()

# die to mismatched bullets or intersecting with craft
func _handle_collision_small_area(area:Area2D):
    if area is Bullet and area.polarity_w != self.polarity_w:
        die()
    if area is Enemy:
        area.die()
        die()

func disable():
    enabled = false
    small_hurtbox.monitorable = false
    small_hurtbox.monitoring = false
    large_hurtbox.monitorable = false
    large_hurtbox.monitoring = false

func enable():
    enabled = true
    small_hurtbox.monitorable = true
    small_hurtbox.monitoring = true
    large_hurtbox.monitorable = true
    large_hurtbox.monitoring = true

func die():
    # do the death effect
    if not enabled: return
    var effect = death_effect.instantiate()
    effect.modulate = w_color if polarity_w else b_color
    if effect_spawn_point:
        effect.position = self.position + effect_spawn_point.position
    else:
        effect.position = self.position
    effect.radius = 50
    get_parent().add_child(effect)

    # hide ourselves
    hide()
    disable()
    
    # wait a sec
    await get_tree().create_timer(2.0).timeout
    
    # return us to the middle center and respawn us
    show()
    position = Vector2.ZERO
    self.modulate.a = 0.5

    # wait a sec
    await get_tree().create_timer(2.0).timeout
    
    # become hittable again
    self.modulate.a = 1
    enable()


func _physics_process(delta: float) -> void:
    if Engine.is_editor_hint(): return

    _handle_movement()
    _handle_fire_input(delta)

    move_and_slide()
