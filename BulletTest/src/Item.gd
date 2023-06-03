extends Area2D

const GRAVITY = 8.0

@onready var _spr = $Sprite

var _velocity = Vector2.ZERO

func vanish() -> void:
	queue_free()

func setup(pos:Vector2, deg:float, speed:float) -> void:
	position = pos
	var rad = deg_to_rad(deg)
	_velocity.x = speed * cos(rad)
	_velocity.y = speed * -sin(rad)
	_spr.rotation = randf_range(-PI, PI)
	
func _physics_process(delta: float) -> void:
	_velocity.y += GRAVITY
	_velocity *= 0.97
	
	if _check_absorb(delta) == false:
		position += _velocity * delta
	if position.y > 640:
		queue_free()

func _check_absorb(delta:float) -> bool:
	if _velocity.y > 0:
		_spr.rotation += delta * 8
		var target = Common.get_target()
		var dist = Common.get_dist(position)
		if dist < 256:
			var rate = 0.01 + 0.1 * (1.0 - dist / 256.0)
			position = position.lerp(target, rate)
			return true
	return false

func _on_area_entered(area: Area2D) -> void:
	if area is Player:
		# プレイヤーと接触したら消える.
		vanish()
