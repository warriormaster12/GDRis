extends Resource
class_name Tetromino

@export var shape: Array[Vector2i] = []
@export_enum("red", "blue", "yellow", "orange", "green") var color: String = "red"
var position: Vector2i = Vector2i.ZERO
var rotation: int = 0

func get_size() -> Vector2i:
	assert(!shape.is_empty(), "shape is undefined")
	var x: int = 0
	var y: int = 0
	for i in shape:
		x += i.x
		y += i.y
	return Vector2i(x, y)

func point_to_test(direction: Vector2i) -> Vector2i:
	var out: Vector2i = Vector2i.ZERO
	for offset in shape:
		if direction.x == -1:
			out.x = min(out.x, offset.x)
		elif direction.x == 1:
			out.x = max(out.x, offset.x)
		if direction.y == -1:
			out.y = min(out.y, offset.y)
		elif direction.y == 1:
			out.y = max(out.y, offset.y)
		
	return out

func rotate_tetromino() -> void:
	rotation += 90
	if rotation == 360:
		rotation = 0
	
	var angle_rad: float = deg_to_rad(rotation)
	var cos_angle: float = cos(angle_rad)
	var sin_angle: float = sin(angle_rad)
	
	for i in shape.size():
		var original_offset: Vector2i = shape[i]
		var rotated_x: int = absi(round(original_offset.x * cos_angle - original_offset.y * sin_angle))
		var rotated_y: int = absi(round(original_offset.x * sin_angle + original_offset.y * cos_angle))

		shape[i] = Vector2i(rotated_x, rotated_y)
		print(shape[i], rotation)
