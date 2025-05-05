extends TileMapLayer

@onready var build_preview: TileMap = $"../BuildPreview"
@export var preview_blocked_coords: Vector2i = Vector2i(1, 0) # red highlight
@export var preview_valid_coords: Vector2i = Vector2i(3, 0)   # green highlight
