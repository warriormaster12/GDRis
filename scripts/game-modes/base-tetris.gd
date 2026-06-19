extends Node
class_name BaseTetris

@export var tetrominos: Array[Tetromino] = []

var columns: float = 10
var rows: float = 20

var field: Array = []

var spawn_height: float = 0.0
var border: float = 0.0
var current_tetromino: Tetromino = null
var tetromino_aabb: AABB

var tetromino_timer: Timer = Timer.new()

var new_x_pos: int = -1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	p_setup_play_area()
	
	tetromino_timer.set_name("Tetromino Timer")
	tetromino_timer.set_autostart(true)
	tetromino_timer.set_wait_time(1.0)
	tetromino_timer.timeout.connect(p_move_tetromino)
	add_child(tetromino_timer)
	
	p_setup_new_tetromino()
	p_debug_render_play_area()

func convert_to_world_coords(position: Vector2i, use_normalized_range: bool = false) -> Vector2:
	var norm_coords: Vector2 = Vector2(position.x / columns, position.y / rows)
	return norm_coords if use_normalized_range else Vector2(2 * norm_coords.x -1, 2 * norm_coords.y -1)

func _input(event: InputEvent) -> void:
	if !current_tetromino: return

	if event.is_action_pressed("move_l"):
		new_x_pos = maxi(current_tetromino.position.x - 1, 0)
	if event.is_action_pressed("move_r"):
		new_x_pos = min(current_tetromino.position.x + 1, columns - current_tetromino.get_size().x)
	#if event.is_action_pressed("rotate"):
		#current_tetromino.rotate_z(deg_to_rad(90))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_pressed("speed_up"):
		tetromino_timer.set_wait_time(0.2)
	elif Input.is_action_just_released("speed_up"):
		tetromino_timer.set_wait_time(1.0)

func p_move_tetromino() -> void:
	if !current_tetromino: return
	
	# Calculate new position
	var new_position: Vector2i = current_tetromino.position
	if new_x_pos > -1:
		new_position.x = new_x_pos
		new_x_pos = -1
	new_position.y += 1
	
	if new_position.y + current_tetromino.get_size().y > rows:
		p_setup_new_tetromino()
		return

	if new_position.x < 0 or new_position.x >= columns or new_position.y >= rows:
		return
	
	# Clear old position
	for offset_y in current_tetromino.shape.size():
		for offset_x in current_tetromino.shape[offset_y].size():
			var global_x = current_tetromino.position.x + offset_x
			var global_y = current_tetromino.position.y + offset_y
			field[global_y][global_x] = 0


	current_tetromino.position = new_position
	for offset_y in range(current_tetromino.shape.size()):
		for offset_x in range(current_tetromino.shape[offset_y].size()):
			var global_x: int = new_position.x + offset_x
			var global_y: int = new_position.y + offset_y
			if global_y >= 0 and global_y < rows and global_x >= 0 and global_x < columns:
				field[global_y][global_x] = current_tetromino.shape[offset_y][offset_x]
	p_debug_render_play_area()

func p_setup_play_area() -> void:
	for i in rows:
		var list: Array[int] = []
		for j in columns:
			list.push_back(0)
		field.push_back(list)

func p_setup_new_tetromino() -> void:
	current_tetromino = tetrominos[randi_range(0, tetrominos.size() - 1)].duplicate()
	current_tetromino.position = Vector2i(floori((columns - 1) * 0.5), 0)

	for offset_y in current_tetromino.shape.size():
		for offset_x in current_tetromino.shape[offset_y].size():
			field[current_tetromino.position.y + offset_y][current_tetromino.position.x + offset_x] = current_tetromino.shape[offset_y][offset_x]

func p_debug_render_play_area() -> void:
	for row in field:
		var row_str: String = "| "
		for column in row:
			if column == 1:
				row_str += "[color=yellow]" + str(column) + "[/color]" + " "
			else:
				row_str += str(column) + " "
		row_str += "|"
		print_rich(row_str)
	var bottom: String = ""
	for column in columns * 2.3:
		bottom += "-"
	print(bottom)
