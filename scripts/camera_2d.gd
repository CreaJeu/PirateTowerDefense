extends Camera2D

# Edge scrolling settings
@export var edge_size: int = 50  # Size of screen edge that triggers movement
@export var edge_scroll_speed: float = 500.0
@export var enable_edge_scrolling: bool = true

func _process(delta: float) -> void:
	# Handle edge scrolling
	if enable_edge_scrolling:
		_handle_edge_scrolling(delta)


func _handle_edge_scrolling(delta: float) -> void:
	# Get mouse position and viewport size
	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_size = get_viewport_rect().size
	var move_vector = Vector2.ZERO
	
	# Check if mouse is near edges
	if mouse_pos.x < edge_size:
		move_vector.x = -1
	elif mouse_pos.x > viewport_size.x - edge_size:
		move_vector.x = 1
		
	if mouse_pos.y < edge_size:
		move_vector.y = -1
	elif mouse_pos.y > viewport_size.y - edge_size:
		move_vector.y = 1
	
	# Apply movement
	if move_vector != Vector2.ZERO:
		# Normalize for diagonal movement
		if move_vector.length() > 1.0:
			move_vector = move_vector.normalized()
		
		# Move camera
		global_position += move_vector * edge_scroll_speed * delta / zoom.x
