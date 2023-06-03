extends Area2D

class_name Enemy

const BULLET_OBJ = preload("res://src/Bullet.tscn")

const HIT_TIMER = 0.5

# --------------------------------
# class.
# --------------------------------
class DelayedBatteryInfo:
	var deg:float = 0
	var speed:float = 0
	var delay:float = 0
	var ax:float = 0
	var ay:float = 0
	func _init(_deg:float, _speed:float, _delay:float, _ax:float=0.0, _ay:float=0.0) -> void:
		deg = _deg
		speed = _speed
		delay = _delay
		ax = _ax
		ay = _ay
	func elapse(delta:float) -> bool:
		delay -= delta
		if delay <= 0:
			return true # 発射できる.
		return false


@onready var _spr = $Sprite

enum eType {
	AIM,
	ALL_RANGE,
	GRAVITY,
	GRAVITY2,
	NEEDLE,
	NEEDLE_3WAY,
	WHIP,
	NWAY,
	NWAY_4_5,
	NWAY_AND_MOVE,
	SIDE_WINDER,
	ROLLING_WINDER,
}
@export var type = eType.AIM

var _cnt = 0
var _timer = 0.0
var _batteries = [] # 弾のディレイ発射用配列.
var _cnt2 = 0
var _cnt3 = 0
var _target = Vector2.ZERO
var _start = Vector2.ZERO
var _hit_timer = 0.0
var _velocity = Vector2.ZERO

func get_velocity() -> Vector2:
	return _velocity
func set_velocity(v:Vector2) -> void:
	_velocity = v
func get_couunt() -> int:
	return _cnt

func hit(velocity:Vector2) -> void:
	# ヒット処理.
	_hit_timer = HIT_TIMER

func setup(pos:Vector2, deg:float, speed:float) -> void:
	position = pos
	var rad = deg_to_rad(deg)
	_velocity.x = speed * cos(rad)
	_velocity.y = speed * -sin(rad)

func _ready() -> void:
	_target = position
	_start = position
	_cnt = -1

func _physics_process(delta: float) -> void:
	_timer += delta
	_cnt += 1
	
	_update_batteies(delta)
	_update_hit(delta)
	
	# 移動処理.
	match type:
		eType.WHIP:
			# 移動する.
			if _cnt%120 == 0:
				if _cnt3%2 == 0:
					_target = _start + Vector2(120, 0)
				else:
					_target = _start + Vector2(-120, 0)
				_cnt3 += 1
		eType.NWAY_AND_MOVE:
			# 移動する.
			if _cnt%120 == 0:
				if _cnt3%2 == 0:
					_target = _start + Vector2(120, 0)
				else:
					_target = _start + Vector2(-120, 0)
				_cnt3 += 1
		_:
			_target = _start
	position += (_target - position) * 0.01
	
	var aim = _aim()
	# 弾を撃つ.
	match type:
		eType.AIM:
			if _cnt%60 == 0:
				_bullet(aim, 500)
		eType.ALL_RANGE:
			if _cnt%60 == 0:
				# 全方位弾
				var cnt = 60 # 発射する弾の数
				var d = 360 / cnt # 角度差を求める.
				for i in range(cnt):
					var deg = d * i # 発射角度を求める.
					_bullet(deg, 200)
		eType.GRAVITY:
			if _cnt%10 == 0:
				var deg = randf_range(60, 120)
				for i in range(3):
					_bullet(deg, 300, i*0.05, 0, 10)
		eType.GRAVITY2:
			if _cnt%4 == 0:
				if _cnt2 < 10:
					_bullet(220, 500, 0, 10, 0)
				elif _cnt2 < 20:
					_bullet(270, 500, 0, 0, 0)
				else:
					_bullet(320, 500, 0, -10, 0)
					if _cnt2 >= 30:
						_cnt2 = 0
				_cnt2 += 1
		eType.NEEDLE:
			if _cnt%60 == 0:
				# 針弾を発射.
				for i in range(5):
					var delay = i * 0.05
					_bullet(aim, 500, delay)
		eType.NEEDLE_3WAY:
			if _cnt%240 == 10:
				for j in range(3):
					for i in range(5):
						var delay = i * 0.05 + j * 1.0
						_nway(3+j, aim, 60, 200+j*20, delay)
		eType.WHIP:
			if _cnt%120 == 0:
				# ウィップ弾を発射
				for i in range(10):
					var deg = 300+50*i # 角度
					var delay = i * 0.05 # 遅延タイマー
					_bullet(aim, deg, delay)
		eType.NWAY:
			if _cnt%60 == 0:
				_nway(5, aim, 60, 300)
		eType.NWAY_4_5:
			if _cnt%20 == 0:
				if _cnt2%2 == 0:
					_nway(5, 270, 80, 200)
				else:
					_nway(4, 270, 80, 200)
				_cnt2 += 1
		eType.NWAY_AND_MOVE:
			if _cnt%60 == 0:
				var d = _cnt2%4
				if d < 3:
					for i in range(7):
						_nway(3+d, aim, 60+(d*8), 300+50*i, 0.1 * i)
				_cnt2 += 1
		eType.SIDE_WINDER:
			var t = _cnt%500
			if t%2 == 0:
				var spd = 1000
				if t == 0:
					var d2 = 70
					for d3 in [-d2, d2]:
						var tako = Common.add_tako(position, 90+d3, 800)
						tako.type = eType.SIDE_WINDER
				elif t < 380:
					# 針弾を発射.
					if t%20 == 0:
						for i in range(3):
							var d2 = 270 + 5 * sin(t*0.1)
							var sp = 300 + t
							var delay = i * 0.02
							_bullet(d2, sp, delay)
				else:
					pass
		eType.ROLLING_WINDER:
			var t = _cnt%500
			if t%2 == 0:
				var spd = 1000
				if t == 0:
					var d2 = 90
					for d3 in [-d2, d2]:
						var tako = Common.add_tako(position, 90+d3, 800)
						tako.type = eType.ROLLING_WINDER
				elif t < 460:
					# リング弾を発射.
					if t%60 == 0:
						var r = 16 + t * 0.2
						for i in range(16):
							var sp = 200 + t * 1
							var b = _bullet(aim, sp)
							var d = 2 * PI * i / 16
							b.position.x += r * cos(d)
							b.position.y += r * -sin(d)
							var dir = Common.get_target() - b.position
							var aim2 = rad_to_deg(atan2(-dir.y, dir.x))
							b.set_velocity(aim2, sp)
				else:
					pass
				
				

func _aim() -> float:
	return Common.get_aim(position)

## 弾を撃つ.
func _bullet(deg:float, speed:float, delay:float=0, ax:float=0, ay:float=0):
	if delay > 0.0:
		# 遅延発射なのでリストに追加するだけ.
		_add_battery(deg, speed, delay, ax, ay)
		return null
	
	# 発射する.
	var b = BULLET_OBJ.instantiate()
	b.position = position
	b.set_velocity(deg, speed)
	b.set_accel(ax, ay)
	var bullets = Common.get_layer("bullet")
	bullets.add_child(b)
	return b

## N-Wayを撃つ
## @param n 発射数.
## @param center 中心角度.
## @param wide 範囲.
## @param speed 速度.
## @param delay 遅延速度.
func _nway(n, center, wide, speed, delay=0) -> void:
	if n < 1:
		return
	
	var d = wide / n
	var a = center - (d * 0.5 * (n - 1))
	for i in range(n):
		_bullet(a, speed, delay)
		a += d

## 遅延発射リストに追加する.
func _add_battery(deg:float, speed:float, delay:float, ax:float, ay:float) -> void:
	var b = DelayedBatteryInfo.new(deg, speed, delay, ax, ay)
	_batteries.append(b)

## 遅延発射リストを更新する.
func _update_batteies(delta:float) -> void:
	var tmp = []
	for battery in _batteries:
		var b:DelayedBatteryInfo = battery
		if b.elapse(delta):
			# 発射する.
			_bullet(b.deg, b.speed, 0, b.ax, b.ay)
			continue
		
		# 発射できないのでリストに追加.
		tmp.append(b)
	
	_batteries = tmp

func _update_hit(delta:float) -> void:
	if _hit_timer <= 0:
		_spr.offset = Vector2.ZERO
		return
	
	_hit_timer -= delta
	var rate = _hit_timer / HIT_TIMER
	var dx = 24.0 * rate
	if _cnt%4 < 2:
		dx *= -1
	var dy = 24.0 * randf_range(-rate, rate)
	_spr.offset.x = dx
	_spr.offset.y = dy
