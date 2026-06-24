extends Node
class_name BaseTetris

@export var tetrominos: Array[Tetromino] = []

var columns: int = 10
var rows: int = 20

var field: Array = []

var spawn_height: float = 0.0
var border: float = 0.0
var current_tetromino: Tetromino = null
var tetromino_aabb: AABB

var tetromino_timer: Timer = Timer.new()

var new_x_pos: int = 0


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

#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("rotate"):
		#current_tetromino.rotate_z(deg_to_rad(90))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if current_tetromino:
		if Input.is_action_pressed("move_l"):
			new_x_pos = -1
		elif Input.is_action_pressed("move_r"):
			new_x_pos = 1
		else:
			new_x_pos = 0
	if Input.is_action_pressed("speed_up"):
		tetromino_timer.set_wait_time(0.2)
	elif Input.is_action_just_released("speed_up"):
		tetromino_timer.set_wait_time(1.0)

func p_get_field_point(pos: Vector2i) -> int:
	return field[clampi(pos.y, 0, rows - 1)][clampi(pos.x, 0, columns - 1)]

func p_move_tetromino() -> void:
	if !current_tetromino: return
	
	# Calculate new position
	var new_position: Vector2i = current_tetromino.position
	new_position.x = clampi(new_position.x + new_x_pos, 0, columns - 1)
	if current_tetromino.position.y + 1 < rows:
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
		var global_x: int = current_tetromino.position.x + offset.x
		var global_y: int = current_tetromino.position.y + offset.y
		field[clampi(global_y, 0, rows - 1)][clampi(global_x, 0, columns - 1)] = 0

	current_tetromino.position = new_position
	for offset in current_tetromino.shape:
		var global_x: int = new_position.x + offset.x
		var global_y: int = new_position.y + offset.y
		field[clampi(global_y, 0, rows -1)][clampi(global_x, 0, columns -1)] = 1
	p_debug_render_play_area()

func p_setup_play_area() -> void:
	for i in rows:
		var list: Array[int] = []
		for j in columns:
			list.push_back(0)
		field.push_back(list)

func p_setup_new_tetromino() -> void:
	var column_cleared: bool = false
	
	for row in field:
		var cols: Array[int] = row
		if cols.all(func(element): return element == 1):
			cols.fill(0)
			column_cleared = true
	
	if column_cleared:
		p_debug_render_play_area()
	
	current_tetromino = tetrominos[randi_range(0, tetrominos.size() - 1)].duplicate()
	current_tetromino.position = Vector2i(floori((columns - 1) * 0.5), 0)

	for offset in current_tetromino.shape:
		field[current_tetromino.position.y + offset.y][current_tetromino.position.x + offset.x] = 1

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
