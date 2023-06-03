extends Sprite2D

const BASE_ALPHA = 0.5

var _timer = 0.0
var _max_time = 1.0
var _max_size = 64.0
var _color = Color.WHITE

func setup(pos:Vector2, time:float, size:float, color:Color) -> void:
	position = pos
	_max_time = time
	_max_size = size
	_color = color
	scale = Vector2.ZERO

func _physics_process(delta: float) -> void:
	_timer += delta
	if _timer >= _max_time:
		# 終了.
		queue_free()
		return
	
	var rate = _timer / _max_time
	# 色を設定.
	modulate = _color
	modulate.a = BASE_ALPHA * (1 - rate)
	
	# サイズを決める.
	rate = Ease.expo_out(rate)
	var sc = _max_size * rate / 256.0 # テクスチサイズで割る.
	scale = Vector2(sc, sc)
