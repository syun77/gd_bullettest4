extends Node

const PARTICLE_OBJ = preload("res://src/particle/Particle.tscn")
const PARTICLE_RING_OBJ = preload("res://src/particle/ParticleRing.tscn")
const TAKO_OBJ = preload("res://src/enemy/Tako.tscn")

const TIMER_SCREEN_SHAKE = 1.0

# 画面のサイズ.
const SCREEN_W = 1024.0
const SCREEN_H = 600.0

# 画面の中央.
const CENTER_X = SCREEN_W / 2
const CENTER_Y = SCREEN_H / 2

var _layers = null
var _player:Player = null
var _prev_target_pos = Vector2.ZERO

func setup(layers, player) -> void:
	_layers = layers
	_player = player

func is_in_screen(pos:Vector2) -> bool:
	if pos.x < 0 or pos.y < 0:
		return false
	if pos.x > SCREEN_W or pos.y > SCREEN_H:
		return false
	return true

func get_layer(name:String) -> CanvasLayer:
	return _layers[name]

func get_player() -> Player:
	if is_instance_valid(_player) == false:
		return null
	return _player

func get_target() -> Vector2:
	var player = get_player()
	var target = _prev_target_pos
	if player != null:
		target = player.position
	# ターゲットの座標を保存しておく.
	_prev_target_pos = target
	return target

func get_aim(pos:Vector2) -> float:
	var target = get_target()
	var d = target - pos
	var aim = rad_to_deg(atan2(-d.y, d.x))
	
	return aim

func get_dist(pos:Vector2) -> float:
	var target = get_target()
	var d = target - pos
	return d.length()

func add_particle(pos:Vector2, t:float, deg:float, speed:float):
	var p = PARTICLE_OBJ.instantiate()
	p.position = pos
	p.start(t, deg, speed)
	get_layer("particle").add_child(p)
	return p
	
func add_ring(pos:Vector2, t:float, size:float, color:Color) -> void:
	var p = PARTICLE_RING_OBJ.instantiate()
	p.position = pos
	p.setup(pos, t, size, color)
	get_layer("particle").add_child(p)

func add_tako(pos:Vector2, deg:float, speed:float):
	var tako = TAKO_OBJ.instantiate()
	Common.get_layer("main").add_child(tako)
	tako.setup(pos, deg, speed)
	return tako


## 角度差を求める.
func diff_angle(now:float, next:float) -> float:
	# 角度差を求める.
	var d = next - now
	# 0.0〜360.0にする.
	d -= floor(d / 360.0) * 360.0
	# -180.0〜180.0の範囲にする.
	if d > 180.0:
		d -= 360.0
	return d


var is_destroy = false
var is_absorb = false
var is_reflect = false
var is_buzz = false
var is_guard = false
var is_push = false
