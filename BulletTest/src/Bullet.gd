extends Area2D

class_name Bullet

const ITEM_OBJ = preload("res://src/Item.tscn")
const BUZZ_OBJ = preload("res://src/particle/BuzzEffect.tscn")

const BUZZ_SIZE = 40.0

@onready var _spr = $Sprite

var _velocity = Vector2.ZERO # 速度.
var _accel = Vector2.ZERO # 加速度.
var _push_velocity = Vector2.ZERO
var _push_start_pos = Vector2.ZERO # 打ち返し開始時の座標.
var _push_start_speed = 0.0

## 消滅.
func vanish() -> void:
	queue_free()

## 押し返し開始.
func push() -> void:
	var spd = _velocity.length()
	var push_spd = _push_velocity.length()
	if push_spd - spd > 0:
		return # 押し返しは動かない.
	
	var v = _velocity.normalized() * -1
	if spd < 1500:
		spd = (1500 - spd)
	_push_velocity = v * spd
	_push_start_pos = position
	_push_start_speed = spd

## 移動方向を取得する.
func get_direction() -> float:
	return rad_to_deg(atan2(-_velocity.y, _velocity.x))
func get_speed() -> float:
	return _velocity.length()

## アイテム登場.
func add_item() -> void:
	var item = ITEM_OBJ.instantiate()
	Common.get_layer("main").add_child(item)
	var d = 40
	var deg = randf_range(90-d, 90+d)
	var speed = 300
	item.setup(position, deg, speed)

## 速度を設定する.
func set_velocity(deg:float, speed:float) -> void:
	var rad = deg_to_rad(deg)
	_velocity.x = cos(rad) * speed
	_velocity.y = -sin(rad) * speed

## 加速度を設定する.
func set_accel(ax:float, ay:float) -> void:
	_accel.x = ax
	_accel.y = ay

## 更新
func _physics_process(delta: float) -> void:
	_velocity += _accel
	_push_velocity *= 0.97
	if (_velocity.length() - _push_velocity.length()) < 0:
		modulate = Color.AQUA
	else:
		modulate = Color.WHITE
	position += (_velocity + _push_velocity) * delta
	
	if Common.is_in_screen(position) == false:
		queue_free()
	
	# カスリ判定.
	if _check_buzz():
		is_buzz = true
		var buzz = BUZZ_OBJ.instantiate()
		Common.get_layer("particle").add_child(buzz)
		var d = position - Common.get_target()
		var deg = rad_to_deg(atan2(-d.y, d.x))
		deg += randf_range(-10, 10)
		buzz.setup(position, deg, 1000)
	
	_spr.modulate = Color.WHITE
	if is_buzz:
		_spr.modulate = Color.RED
	is_buzz = false
	
	queue_redraw()

func _check_buzz() -> bool:
	if Common.is_buzz == false:
		return false
	
	var dist = Common.get_dist(position)
	if dist < BUZZ_SIZE:
		return true
	return false

func _draw() -> void:
	var spd = _velocity.length()
	var push_spd = _push_velocity.length()
	var d = push_spd - spd
	if d <= 0:
		return
	
	var rate = d / _push_start_speed
	var p1 = Vector2.ZERO
	var p2 = _push_start_pos - position
	var color = Color.WHITE
	color.a = rate
	var width = 8 * rate
	if width < 2:
		width = 2
	draw_line(p1, p2, color, width)
	

func _on_area_entered(area: Area2D) -> void:
	if area is Shot:
		if area.is_erase_bullet():
			add_item()
			vanish()

## カスリ状態かどうか.
var is_buzz = false:
	set(b):
		is_buzz = b
	get:
		return is_buzz 
