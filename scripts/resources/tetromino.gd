extends Resource
class_name Tetromino

@export var shape: Array[Vector2i] = []
@export_enum("red", "blue", "yellow", "orange", "green") var color: String = "red"
var position: Vector2i = Vector2i.ZERO

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
