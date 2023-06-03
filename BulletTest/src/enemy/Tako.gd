extends Enemy

class_name Tako

var _is_left = false

func _physics_process(delta: float) -> void:
	_update_hit(delta)
	_is_left = position.x < 1024/2
	var mod = 1
	if _is_left == false:
		mod = -1
	
	_cnt += 1
	_velocity *= 0.93
	position += _velocity * delta
	
	
	if _cnt < 60:
		return
	
	match type:
		eType.SIDE_WINDER:
			# ワインダー攻撃する.
			var t = (_cnt-60)%500
			if t%2 == 0:
				var range = 90
				var spd = 1000
				if t < 60:
					_nway(3, 270+20*mod, range, spd)
				elif t < 380:
					t -= 60
					var d2 = 20 * sin(t*0.03)
					_nway(3, 270+20*mod+d2, range, spd)
				else:
					# 消滅する.
					queue_free()
		eType.ROLLING_WINDER:
			# ワインダー攻撃する.
			var t = (_cnt)%700
			if t%2 == 0:
				var spd = 250
				if t < 380:
					if t%10 < 1:
						var d = 0
						if _is_left:
							d = 180
						for i in range(2):
							for j in range(3):
								_bullet(t * 2 * mod + i * 180 + j*1, spd+j*10, j*0.05)
				else:
					# 消滅する.
					queue_free()
		
	_update_batteies(delta)
