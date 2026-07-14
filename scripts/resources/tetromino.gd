extends Resource
class_name Tetromino

@export var shape: Array[Vector2i] = []
@export_enum("red", "blue", "yellow", "orange", "green") var color: String = "red"
var position: Vector2i = Vector2i.ZERO
var rotation: int = 0
var rotated_shape: Array[Vector2i] = []

func get_shape() -> Array[Vector2i]:
	if rotated_shape.is_empty():
		rotated_shape.resize(shape.size())
		for i in shape.size(): 
			rotated_shape[i] = shape[i]
	return rotated_shape

func rotate_tetromino() -> void:
	rotation += 90
	if rotation == 360:
		rotation = 0
	
	var angle_rad: float = deg_to_rad(rotation)
	var cos_angle: float = cos(angle_rad)
	var sin_angle: float = sin(angle_rad)
	
	for i in shape.size():
		var original_offset: Vector2i = shape[i]
		var new_rotation: Vector2 = Vector2(original_offset.x * cos_angle - original_offset.y * sin_angle, original_offset.x * sin_angle + original_offset.y * cos_angle)

		rotated_shape[i] = Vector2i(roundi(new_rotation.x), roundi(new_rotation.y))
