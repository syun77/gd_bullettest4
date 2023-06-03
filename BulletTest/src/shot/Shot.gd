extends Area2D

class_name Shot

@onready var _spr = $Sprite
@onready var _line = $Line2D

var _velocity = Vector2()
var _is_accel = false
var _deg = 0.0
var _speed = 0.0

var _spr_list = []

func is_erase_bullet() -> bool:
	return Common.is_destroy

func vanish() -> void:
	# 逆方向にパーティクルを発生させる.
	var v = _velocity * -1
	var spd = v.length()
	for i in range(4):
		var rad = atan2(-v.y, v.x)
		var deg = rad_to_deg(rad)
		deg += randf_range(-30, 30)
		var speed = spd * randf_range(0.1, 0.5)
		Common.add_particle(position, 1.0, deg, speed)
	queue_free()

func _ready() -> void:
	
	for i in range(8):
		var rate = 1.0 - ((i+1) / 8.0)
		var spr:Sprite2D = get_node("./Sprite%d"%i)
		spr.texture = _spr.texture
		spr.scale.x = rate
		spr.scale.y = rate
		spr.modulate.a = rate
		spr.rotation_degrees = _spr.rotation_degrees
		_spr_list.append(spr)
		
func setup(pos:Vector2, deg:float, speed:float, is_accel:bool = false) -> void:
	position = pos
	set_velocity(deg, speed)
	_is_accel = is_accel

func set_velocity(deg:float, speed:float) -> void:
	_deg = deg
	_speed = speed
	
	var rad = deg_to_rad(deg)
	_velocity.x = cos(rad) * speed
	_velocity.y = -sin(rad) * speed
	_spr.rotation_degrees = deg * -1
	for spr in _spr_list:
		spr.rotation_degrees = _spr.rotation_degrees

func _physics_process(delta: float) -> void:
	var d = _velocity * delta
	position += d
	
	# 残像の更新.
	# positionに追従してしまうので逆オフセットが必要となる.
	for spr in _spr_list:
		spr.position -= d # すべてのLine2Dの位置を移動量で逆オフセットする.
	_spr_list[0].position = Vector2.ZERO # 先頭は0でよい.
	_update_blur()
	
	# 画面外に出たら消す.
	if position.x < 0 or position.y < 0:
		queue_free()
	if position.x > 1024 or position.y > 600:
		queue_free()
	
	if _is_accel:
		if _speed < 1500:
			_speed += delta * 2000;
			set_velocity(_deg, _speed)

## 残像の更新.
func _update_blur() -> void:
	for i in range(_spr_list.size()-1):
		var a = _spr_list[i].position
		var b = _spr_list[i+1].position
		# 0.7の重みで線形補間します
		_spr_list[i+1].position = b.lerp(a, 0.7)

func _on_Shot_area_entered(area: Area2D) -> void:
	# 何かに衝突したら消える.
	vanish()
	
	if area is Enemy:
		# 敵だったらヒット処理.
		area.hit(_velocity)
