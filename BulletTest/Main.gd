extends Node2D


@onready var _camera = $MainCamera

@onready var _player = $MainLayer/Player
@onready var _enemy = $MainLayer/Enemy
@onready var _main_layer = $MainLayer

@onready var _shot_layer = $ShotLayer
@onready var _bullet_layer = $BulletLayer
@onready var _particle_layer = $ParticleLayer
## UI
@onready var _checkbox_destroy = $UILayer/CheckBoxDestroy
@onready var _checkbox_absorb = $UILayer/CheckBoxAbsorb
@onready var _checkbox_reflect = $UILayer/CheckBoxReflect
@onready var _checkbox_buzz = $UILayer/CheckBoxBuzz
@onready var _checkbox_push = $UILayer/CheckBoxPush
@onready var _checkbox_guard = $UILayer/CheckBoxGuard
@onready var _optionbtn_enemy = $UILayer/OptionButtonEnemy

func _ready() -> void:
	DisplayServer.window_set_size(Vector2i(1024*2, 600*2))
	
	var layers = {
		"main": _main_layer,
		"shot": _shot_layer,
		"bullet" : _bullet_layer,
		"particle": _particle_layer,
	}
	Common.setup(layers, _player)
	
	for key in Enemy.eType.keys():
		_optionbtn_enemy.add_item(key)
	
	_optionbtn_enemy.select(_enemy.type)

func _process(delta: float) -> void:
	_update_ui()

func _update_ui() -> void:
	Common.is_destroy = _checkbox_destroy.button_pressed
	Common.is_absorb = _checkbox_absorb.button_pressed
	Common.is_reflect = _checkbox_reflect.button_pressed
	Common.is_buzz = _checkbox_buzz.button_pressed
	Common.is_guard = _checkbox_guard.button_pressed
	Common.is_push = _checkbox_push.button_pressed
	
	_enemy.type = _optionbtn_enemy.selected
