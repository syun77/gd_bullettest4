extends Area2D

@onready var _spr = $Sprite2D

var _timer = 0.0

func _ready() -> void:
	#_spr.scale = Vector2(0.5, 0.5)
	pass

func _physics_process(delta: float) -> void:
	_timer += delta
	var t = delta * 4
	_spr.scale -= Vector2(t, t)
	var target = Common.get_target()
	var d = target - position
	position += d * _timer * 2

	if position.distance_to(target) < 4:
		Common.add_ring(target, 0.5, 96, Color.CYAN)
		queue_free()
