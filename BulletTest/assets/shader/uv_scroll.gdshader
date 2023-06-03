// CanvasItemのシェーダーであることを宣言
shader_type canvas_item;

// UV値のオフセット値
uniform float scroll_speed = 0.05;

// フラグメントシェーダー
void fragment() {
    // 色を取得
    vec4 color = texture(TEXTURE, vec2(UV.x+TIME*scroll_speed, UV.y));
	color *= 0.5;
	color.x *= 1.1;
	color.z *= 1.1;
    // 反映
    COLOR = color;
}