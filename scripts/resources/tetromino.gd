extends Resource
class_name Tetromino

@export var shape: Array = []
@export_enum("red", "blue", "yellow", "orange", "green") var color: String = "red"
var position: Vector2i = Vector2i.ZERO

func get_size() -> Vector2i:
	assert(shape.size(), "shape is undefined")
	return Vector2i(shape[0].size(), shape.size())
