extends Node
class_name BaseTetris

@export var tetrominos: Array[Tetromino] = []
@export var enable_console_field: bool = false

var columns: int = 10
var rows: int = 20

var field: Array = []

var spawn_height: float = 0.0
var border: float = 0.0
var current_tetromino: Tetromino = null
var tetromino_aabb: AABB

var tetromino_timer: Timer = Timer.new()

var new_x_pos: int = 0

var can_rotate_tetromino: bool = false


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
	var norm_coords: Vector2 = Vector2(float(position.x) / float(columns), float(position.y) / float(rows))
	return norm_coords if use_normalized_range else Vector2(2 * norm_coords.x -1, 2 * norm_coords.y -1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if current_tetromino:
		if Input.is_action_pressed("move_l"):
			new_x_pos = -1
		elif Input.is_action_pressed("move_r"):
			new_x_pos = 1
		else:
			new_x_pos = 0
		if Input.is_action_pressed("rotate"):
			can_rotate_tetromino = true

	if Input.is_action_pressed("speed_up"):
		tetromino_timer.set_wait_time(0.2)
	elif Input.is_action_just_released("speed_up"):
		tetromino_timer.set_wait_time(1.0)

func p_get_field_point(pos: Vector2i) -> int:
	return field[clampi(pos.y, 0, rows - 1)][clampi(pos.x, 0, columns - 1)]

func p_set_field_point(pos: Vector2i, value: int) -> void:
	field[clampi(pos.y, 0, rows - 1)][clampi(pos.x, 0, columns - 1)] = value

func p_move_tetromino() -> void:
	if !current_tetromino: return
	
	# Calculate new position
	var new_position: Vector2i = current_tetromino.position
	new_position.x = clampi(new_position.x + new_x_pos, 0, columns - 1)
	new_position.y += 1
	
	var dir: Vector2i = new_position - current_tetromino.position
	var point_to_test: Vector2i = current_tetromino.point_to_test(dir)
	
	if dir == Vector2i(0, 1):
		if new_position.y + point_to_test.y > rows - 1 or p_get_field_point(point_to_test + new_position) == 1:
			p_setup_new_tetromino()
			return
	else:
		if  p_get_field_point(point_to_test + new_position) == 1:
			new_position.x = current_tetromino.position.x

	# Clear old position
	for offset in current_tetromino.shape:
		p_set_field_point(current_tetromino.position + offset, 0)
	
	if can_rotate_tetromino:
		current_tetromino.rotate_tetromino()
		can_rotate_tetromino = false

	current_tetromino.position = new_position
	for offset in current_tetromino.shape:
		p_set_field_point(current_tetromino.position + offset, 1)

	p_debug_render_play_area()

func p_setup_play_area() -> void:
	for i in rows:
		var list: Array[int] = []
		for j in columns:
			list.push_back(0)
		field.push_back(list)

func p_setup_new_tetromino() -> void:
	var column_cleared: bool = false
	
	while true:
		for row in field:
			var cols: Array[int] = row
			if cols.all(func(element): return element == 1):
				cols.fill(0)
				column_cleared = true
		
		if !column_cleared:
			break

		for col_idx in columns:
			var column_cells: Array = []
			# Collect the column cells
			for row_idx in range(field.size()):
				column_cells.append(field[row_idx][col_idx])
			
			# Count the number of empty cells below filled cells
			var empty_below = 0
			for row_idx in range(field.size() - 1, -1, -1):
				if column_cells[row_idx] == 0:
					empty_below += 1
				elif empty_below > 0:
					# Move the filled cell down by empty_below
					var new_row_idx = row_idx + empty_below
					if new_row_idx < field.size():
						field[new_row_idx][col_idx] = 1
						field[row_idx][col_idx] = 0
		column_cleared = false
	
	if column_cleared:
		p_debug_render_play_area()
	
	current_tetromino = tetrominos[randi_range(0, tetrominos.size() - 1)].duplicate()
	current_tetromino.position = Vector2i(floori((columns - 1) * 0.5), 0)

	for offset in current_tetromino.shape:
		field[current_tetromino.position.y + offset.y][current_tetromino.position.x + offset.x] = 1

func p_debug_render_play_area() -> void:
	if !enable_console_field: return
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
