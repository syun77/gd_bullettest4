extends Area2D


func _on_area_entered(area: Area2D) -> void:
	if area is Bullet:
		# 逆方向にパーティクルを発生させる.
		var pos = area.position
		var v = area._velocity * -1
		var spd = v.length()
		for i in range(4):
			var rad = atan2(-v.y, v.x)
			var deg = rad_to_deg(rad)
			deg += randf_range(-30, 30)
			var speed = spd * randf_range(0.1, 0.5)
			Common.add_particle(pos, 1.0, deg, speed)
			
		area.queue_free()
