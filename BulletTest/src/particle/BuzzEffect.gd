extends Node2D

const TIMER_LIVE = 1.0 # 生存時間.

var _velocity = Vector2()
var _timer = 0.0

func setup(pos:Vector2, deg:float, speed:float) -> void:
	position = pos
	var rad = deg_to_rad(deg)
	_velocity.x = speed * cos(rad)
	_velocity.y = speed * -sin(rad)
	_timer = TIMER_LIVE - randf_range(0, 0.8)

func _process(delta: float) -> void:
	_velocity *= 0.97
	position += _velocity * delta
	_timer -= delta
	if _timer < 0.0:
		queue_free()
		return
		
	queue_redraw()
		
func _draw() -> void:
	var rate = _timer 
	var v = _velocity.normalized()
	var p1 = Vector2.ZERO
	var p2 = p1 + v * 16 * rate
	draw_line(p1, p2, Color.WHITE)
